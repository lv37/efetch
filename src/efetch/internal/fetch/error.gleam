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

pub type FetchError {
  DNSError(DNSError)
  ConnectError(ConnectError)
  TLSError(TLSError)
  UnableToReadBody
  InvalidJsonBody
}

pub type RawFetchError {
  RawFetchError(code: String, syscall: String)
}

@external(javascript, "../../../fetch_error_ffi.mjs", "fetch_error_to_gleam")
pub fn fetch_error_to_gleam(err: RawFetchError) -> FetchError {
  let _err = err
  panic as "Only the JS target is supported"
}
