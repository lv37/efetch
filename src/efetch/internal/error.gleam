import efetch/internal/fetch/error.{
  type ConnectError, type DNSError, type TLSError,
}
import gleam/dynamic.{type Dynamic}
import gleam/httpc
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
pub fn http_err_from_httpc_err(err: httpc.HttpError) -> HttpError {
  case err {
    httpc.InvalidUtf8Response -> InvalidUtf8Response
    httpc.FailedToConnect(ip, httpc.Posix("nxdomain"))
    | httpc.FailedToConnect(_, ip) -> {
      case ip {
        httpc.TlsAlert(_, _) -> error.InvalidTLSCertAltName |> TLSError
        httpc.Posix(kind) -> httpc_connect_err(kind)
      }
    }
  }
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

pub fn http_res_from_httpc_res(
  res: Result(a, httpc.HttpError),
) -> Result(a, HttpError) {
  use err <- result.map_error(res)
  http_err_from_httpc_err(err)
}
