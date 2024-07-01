import efetch/internal/fetch/error.{
  type ConnectError, type DNSError, type TLSError,
}
import gleam/dynamic.{type Dynamic}
import gleam/erlang/atom
import gleam/result

pub type HttpError {
  DNSError(DNSError)
  ConnectError(ConnectError)
  TLSError(TLSError)
  UnknownNetworkError(String)
  InvalidUtf8Response
  UnableToReadBody
  InvalidJsonBody
  Other(Dynamic)
}

pub type FailedToConnect {
  FailedToConnect(List(#(List(Int), Int)))
}

@external(javascript, "../../unimplemented_ffi.mjs", "unimplemented")
pub fn http_err_from_httpc_err(err: Dynamic) -> HttpError {
  err
  |> dynamic.element(1, dynamic.list(dynamic.dynamic))
  |> result.try(fn(list) {
    case list {
      [_, t] -> {
        t
        |> dynamic.element(2, atom.from_dynamic)
        |> result.try_recover(fn(_) {
          t |> dynamic.element(2, dynamic.element(0, atom.from_dynamic))
        })
        |> result.map(fn(a) {
          atom.to_string(a)
          |> httpc_connect_err()
        })
      }
      _ -> Other(err) |> Ok()
    }
  })
  |> result.lazy_unwrap(fn() {
    case dynamic.string(err) {
      Ok("Response body was not valid UTF-8") -> {
        InvalidUtf8Response
      }
      _ -> Other(err)
    }
  })
}

pub fn httpc_connect_err(kind: String) -> HttpError {
  let kind = case kind {
    "eacces" -> error.EAcces
    "eperm" -> error.EPerm
    "eaddinuse" -> error.EAddrinuse
    "eaddrnotavail" -> error.Eddrnotavail
    "eafnosupport" -> error.EAfnosupport
    "eagain" -> error.EAgain
    "ealready" -> error.EAlready
    "ebadf" -> error.EBadF
    "econnrefused" -> error.EConnrefused
    "efault" -> error.EFault
    "einprogress" -> error.EInProgress
    "eintr" -> error.EIntr
    "eisconn" -> error.EIsConn
    "enetunreach" -> error.ENetUnreach
    "enotsock" -> error.ENotSock
    "eprototype" -> error.EPrototype
    "etimeout" -> error.ETimeout
    "enodev" -> error.ENoDev
    "enodata" -> error.ENoData
    _ -> error.UnknownConnectError(kind)
  }
  case kind {
    error.UnknownConnectError(kind) -> {
      let kind = case kind {
        "nxdomain" -> error.NotFound
        "formerr" -> error.Formerr
        "qfmterr" -> error.BadQuery
        "servfail" -> error.ServerFail
        "notimp" -> error.NotImplemented
        "timeout" -> error.Timeout
        "badvers" -> error.BadFamily
        // what does "badvers" even mean?
        _ -> error.UnknownDNSError(kind)
      }
      case kind {
        error.UnknownDNSError(kind) -> {
          case kind {
            "tls_alert" -> error.InvalidTLSCertAltName
            _ -> error.UnknownTLSError(kind)
          }
          |> TLSError
        }
        _ -> DNSError(kind)
      }
    }
    _ -> ConnectError(kind)
  }
}

pub fn http_res_from_httpc_res(res: Result(a, Dynamic)) -> Result(a, HttpError) {
  use err <- result.map_error(res)
  http_err_from_httpc_err(err)
}
