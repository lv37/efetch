import efetch/internal/error.{http_res_from_httpc_res} as int_err
import efetch/internal/fetch/error
import gleam/dynamic.{type Dynamic}
import gleam/http/request.{type Request}
import gleam/http/response.{type Response}
import gleam/httpc
import gleam/result

fn internal_connect_err_to_connect_err(err: error.ConnectError) -> ConnectError {
  case err {
    error.EAcces -> EAcces
    error.EPerm -> EPerm
    error.EAddrinuse -> EAddrinuse
    error.Eddrnotavail -> Eddrnotavail
    error.EAfnosupport -> EAfnosupport
    error.EAgain -> EAgain
    error.EAlready -> EAlready
    error.EBadF -> EBadF
    error.EConnrefused -> EConnrefused
    error.EFault -> EFault
    error.EInProgress -> EInProgress
    error.EIntr -> EIntr
    error.EIsConn -> EIsConn
    error.ENetUnreach -> ENetUnreach
    error.ENotSock -> ENotSock
    error.EPrototype -> EPrototype
    error.ETimeout -> ETimeout
    error.ENoDev -> ENoDev
    error.ENoData -> ENoData
    error.UnknownConnectError(str) -> UnknownConnectError(str)
  }
}

fn internal_dns_err_to_dns_err(err: error.DNSError) -> DNSError {
  case err {
    error.NoData -> NoData
    error.Formerr -> Formerr
    error.ServerFail -> ServerFail
    error.NotFound -> NotFound
    error.NotImplemented -> NotImplemented
    error.Refused -> Refused
    error.BadQuery -> BadQuery
    error.BadName -> BadName
    error.BadFamily -> BadFamily
    error.BadResponse -> BadResponse
    error.ConnectionRefused -> ConnectionRefused
    error.Timeout -> Timeout
    error.EOF -> EOF
    error.File -> File
    error.NoMem -> NoMem
    error.Destruction -> Destruction
    error.BadString -> BadString
    error.BadFlags -> BadFlags
    error.NoName -> NoName
    error.BadHints -> BadHints
    error.NotInitialized -> NotInitialized
    error.LoadIPHLPAPI -> LoadIPHLPAPI
    error.AddrGetNetworkParams -> AddrGetNetworkParams
    error.Cancelled -> Cancelled
    error.TryAgainLater -> TryAgainLater
    error.UnknownDNSError(str) -> UnknownDNSError(str)
  }
}

fn internal_tls_err_to_tls_err(err: error.TLSError) -> TLSError {
  case err {
    error.InvalidTLSCertAltName -> InvalidTLSCertAltName
    error.UnknownTLSError(str) -> UnknownTLSError(str)
  }
}

fn internal_http_err_to_http_err(err: int_err.HttpError) -> HttpError {
  case err {
    int_err.DNSError(err) -> internal_dns_err_to_dns_err(err) |> DNSError()
    int_err.ConnectError(err) ->
      internal_connect_err_to_connect_err(err) |> ConnectError()
    int_err.TLSError(err) -> internal_tls_err_to_tls_err(err) |> TLSError()
    int_err.UnknownNetworkError(str) -> UnknownNetworkError(str)
    int_err.InvalidUtf8Response -> InvalidUtf8Response
    int_err.UnableToReadBody -> UnableToReadBody
    int_err.InvalidJsonBody -> InvalidJsonBody
    int_err.Other(err) -> Other(err)
  }
  |> unknown_errors_to_unknown_network_error()
}

fn unknown_errors_to_unknown_network_error(err: HttpError) -> HttpError {
  case err {
    ConnectError(UnknownConnectError(str))
    | DNSError(UnknownDNSError(str))
    | TLSError(UnknownTLSError(str)) -> UnknownNetworkError(str)
    _ -> err
  }
}

fn internal_http_res_to_http_res(
  res: Result(a, int_err.HttpError),
) -> Result(a, HttpError) {
  result.map_error(res, internal_http_err_to_http_err)
}

pub type ConnectError {
  EAcces
  EPerm
  EAddrinuse
  Eddrnotavail
  EAfnosupport
  EAgain
  EAlready
  EBadF
  EConnrefused
  EFault
  EInProgress
  EIntr
  EIsConn
  ENetUnreach
  ENotSock
  EPrototype
  ETimeout
  ENoDev
  ENoData
  UnknownConnectError(String)
}

pub type DNSError {
  /// `dns.NODATA`: DNS server returned an answer with no data.
  NoData
  /// `dns.FORMERR`: DNS server claims query was misformatted.
  Formerr
  /// `dns.SERVFAIL`: DNS server returned general failure.
  ServerFail
  /// `dns.NOTFOUND`: Domain name not found.
  NotFound
  /// `dns.NOTIMP`: DNS server does not implement the requested operation.
  NotImplemented
  /// `dns.REFUSED`: DNS server refused query.
  Refused
  /// `dns.BADQUERY`: Misformatted DNS query.
  BadQuery
  /// `dns.BADNAME`: Misformatted host name.
  BadName
  /// `dns.BADFAMILY`: Unsupported address family.
  BadFamily
  /// `dns.BADRESP`: Misformatted DNS reply.
  BadResponse
  /// `dns.CONNREFUSED`: Could not contact DNS servers.
  ConnectionRefused
  /// `dns.TIMEOUT`: Timeout while contacting DNS servers.
  Timeout
  /// `dns.EOF`: End of file.
  EOF
  /// `dns.FILE`: Error reading file.
  File
  /// `dns.NOMEM`: Out of memory.
  NoMem
  /// `dns.DESTRUCTION`: Channel is being destroyed.
  Destruction
  /// `dns.BADSTR`: Misformatted string.
  BadString
  /// `dns.BADFLAGS`: Illegal flags specified.
  BadFlags
  /// `dns.NONAME`: Given host name is not numeric.
  NoName
  /// `dns.BADHINTS`: Illegal hints flags specified.
  BadHints
  /// `dns.NOTINITIALIZED`: c-ares library initialization not yet performed.
  NotInitialized
  /// `dns.LOADIPHLPAPI`: Error loading iphlpapi.dll.
  LoadIPHLPAPI
  /// `dns.ADDRGETNETWORKPARAMS`: Could not find GetNetworkParams function.
  AddrGetNetworkParams
  /// `dns.CANCELLED`: DNS query cancelled.
  Cancelled
  /// `EAI_AGAIN`: The name server returned a temporary failure indication. Try again later.
  TryAgainLater
  UnknownDNSError(String)
}

pub type TLSError {
  InvalidTLSCertAltName
  UnknownTLSError(String)
}

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

@external(javascript, "./fetch.mjs", "send")
pub fn send(req: Request(String)) -> Result(Response(String), HttpError) {
  httpc.send(req)
  |> http_res_from_httpc_res()
  |> internal_http_res_to_http_res()
}

@external(javascript, "./fetch.mjs", "send_bits")
pub fn send_bits(
  req: Request(BitArray),
) -> Result(Response(BitArray), HttpError) {
  httpc.send_bits(req)
  |> http_res_from_httpc_res()
  |> internal_http_res_to_http_res()
}
