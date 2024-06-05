import classify.{type Field, CustomValue, classify}
import efetch/internal/fetch/error.{
  type ConnectError, type DNSError, type TLSError,
}
import gleam/dynamic.{type Dynamic}
import gleam/list
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

pub fn http_err_from_httpc_err(err: Dynamic) -> HttpError {
  let typ = classify(err)
  case typ {
    CustomValue("FailedConnect", info) -> httpc_connect_err(info)
    _ -> Other(err)
  }
}

pub fn httpc_connect_err(info: List(Field)) -> HttpError {
  case list.map(info, fn(field) { classify(field.value) }) {
    [classify.ListValue([_, kind])] -> {
      case classify(kind) {
        CustomValue(_, [_, kind]) -> {
          case classify(kind.value) {
            CustomValue(kind, _) -> Ok(kind)
            _ -> Error(Nil)
          }
        }
        _ -> Error(Nil)
      }
    }
    _ -> Error(Nil)
  }
  |> result.map(fn(kind) {
    let kind = case kind {
      "Eacces" -> error.EACCES
      "Eperm" -> error.EPERM
      "Eaddinuse" -> error.EADDRINUSE
      "Eaddrnotavail" -> error.EADDRNOTAVAIL
      "Eafnosupport" -> error.EAFNOSUPPORT
      "Eagain" -> error.EAGAIN
      "Ealready" -> error.EALREADY
      "Ebadf" -> error.EBADF
      "Econnrefused" -> error.ECONNREFUSED
      "Efault" -> error.EFAULT
      "Einprogress" -> error.EINPROGRESS
      "Eintr" -> error.EINTR
      "Eisconn" -> error.EISCONN
      "Enetunreach" -> error.ENETUNREACH
      "Enotsock" -> error.ENOTSOCK
      "Eprototype" -> error.EPROTOTYPE
      "Etimeout" -> error.ETIMEDOUT
      _ -> error.UnknownConnectError(kind)
    }
    case kind {
      error.UnknownConnectError(kind) -> {
        let kind = case kind {
          "Nxdomain" -> error.NotFound
          "Formerr" -> error.Formerr
          "Qfmterr" -> error.BadQuery
          "Servfail" -> error.ServerFail
          "Notimp" -> error.NotImplemented
          "Timeout" -> error.Timeout
          "Badvers" -> error.BadFamily
          // what does "badvers" even mean?
          _ -> error.UnknownDNSError(kind)
        }
        case kind {
          error.UnknownDNSError(kind) -> {
            case kind {
              "TlsAlert" -> error.InvalidTLSCertAltName
              _ -> error.UnknownTLSError(kind)
            }
            |> TLSError
          }
          _ -> DNSError(kind)
        }
      }
      _ -> ConnectError(kind)
    }
  })
  |> result.unwrap(UnknownNetworkError("Unknown"))
}

pub fn http_res_from_httpc_res(res: Result(a, Dynamic)) -> Result(a, HttpError) {
  use err <- result.map_error(res)
  http_err_from_httpc_err(err)
}
