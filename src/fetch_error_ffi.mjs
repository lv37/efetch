import * as _ from './efetch/internal/fetch/error.mjs'

export function fetch_getaddrinfo_error_to_gleam(code) {
	let getaddrinfo_err;
	if (code === 'ENODATA') {
		getaddrinfo_err = new _.NoData()
	} else if (code === 'EFORMERR') {
		getaddrinfo_err = new _.Formerr()
	} else if (code === 'ESERVFAIL') {
		getaddrinfo_err = new _.ServerFail()
	} else if (code === 'ENOTFOUND') {
		getaddrinfo_err = new _.NotFound()
	} else if (code === 'ENOTIMP') {
		getaddrinfo_err = new _.NotImplemented()
	} else if (code === 'EREFUSED') {
		getaddrinfo_err = new _.Refused()
	} else if (code === 'EBADQUERY') {
		getaddrinfo_err = new _.BadQuery()
	} else if (code === 'EBADNAME') {
		getaddrinfo_err = new _.BadName()
	} else if (code === 'EBADFAMILY') {
		getaddrinfo_err = new _.BadFamily()
	} else if (code === 'EBADRESP') {
		getaddrinfo_err = new _.BadResponse()
	} else if (code === 'ECONNREFUSED') {
		getaddrinfo_err = new _.ConnectionRefused()
	} else if (code === 'ETIMEOUT') {
		getaddrinfo_err = new _.Timeout()
	} else if (code === 'EEOF') {
		getaddrinfo_err = new _.EOF()
	} else if (code === 'EFILE') {
		getaddrinfo_err = new _.File()
	} else if (code === 'ENOMEM') {
		getaddrinfo_err = new _.NoMem()
	} else if (code === 'EDESTRUCTION') {
		getaddrinfo_err = new _.Destruction()
	} else if (code === 'EBADSTR') {
		getaddrinfo_err = new _.BadString()
	} else if (code === 'EBADFLAGS') {
		getaddrinfo_err = new _.BadFlags()
	} else if (code === 'ENONAME') {
		getaddrinfo_err = new _.NoName()
	} else if (code === 'EBADHINTS') {
		getaddrinfo_err = new _.BadHints()
	} else if (code === 'ENOTINITIALIZED') {
		getaddrinfo_err = new _.NotInitialized()
	} else if (code === 'ELOADIPHLPAPI') {
		getaddrinfo_err = new _.LoadIPHLPAPI()
	} else if (code === 'EADDRGETNETWORKPARAMS') {
		getaddrinfo_err = new _.AddrGetNetworkParams()
	} else if (code === 'ECANCELLED') {
		getaddrinfo_err = new _.Cancelled()
	} else if (code === 'EAI_AGAIN') {
		getaddrinfo_err = new _.TryAgainLater()
	} else {
		getaddrinfo_err = new _.UnknownDNSError(code)
	}
	return new _.DNSError(getaddrinfo_err)
}

export function fetch_connect_error_to_gleam(code) {
	let connect_err;
	if (code === 'EACCES') {
		connect_err = new _.EAcces()
	} else if (code === 'EPERM') {
		connect_err = new _.EPerm()
	} else if (code === 'EADDRINUSE') {
		connect_err = new _.EAddrinuse()
	} else if (code === 'EADDRNOTAVAIL') {
		connect_err = new _.Eddrnotavail()
	} else if (code === 'EAFNOSUPPORT') {
		connect_err = new _.EAfnosupport()
	} else if (code === 'EAGAIN') {
		connect_err = new _.EAgain()
	} else if (code === 'EALREADY') {
		connect_err = new _.EAlready()
	} else if (code === 'EBADF') {
		connect_err = new _.EBadF()
	} else if (code === 'ECONNREFUSED') {
		connect_err = new _.EConnrefused()
	} else if (code === 'EFAULT') {
		connect_err = new _.EFault()
	} else if (code === 'EINPROGRESS') {
		connect_err = new _.EInProgress()
	} else if (code === 'EINTR') {
		connect_err = new _.EIntr()
	} else if (code === 'EISCONN') {
		connect_err = new _.EIsConn()
	} else if (code === 'ENETUNREACH') {
		connect_err = new _.ENetUnreach()
	} else if (code === 'ENODATA') {
		connect_err = new _.ENoData()
	} else if (code === 'ENOTSOCK') {
		connect_err = new _.ENotSock()
	} else if (code === 'EPROTOTYPE') {
		connect_err = new _.EPrototype()
	} else if (code === 'ETIMEDOUT') {
		connect_err = new _.ETimeout()
	} else if (code === 'ENODEV') {
		connect_err = new _.ENoDev()
} else {
		connect_err = new _.UnknownConnectError(code)
	}
	return new _.ConnectError(connect_err)
}

function xmlhttprequest_error_to_gleam(err) {
	const code = err.code
	if (code === 1) {
		return new _.ConnectError(new _.EPerm())
	} else if (code === 4) {
		return new _.ConnectError(new _.EIntr())
	} else if (code === 9) {
		return new _.ConnectError(new _.EBadF())
	} else if (code === 13) {
		return new _.ConnectError(new _.EAcces())
	} else if (code === 14) {
		return new _.ConnectError(new _.EFault())
	} else if (code === 19) {
  	return new _.ConnectError(new _.ENoDev());
  } else if (code === 35) {
		return new _.ConnectError(new _.EAgain())
	} else if (code === 36) {
		return new _.ConnectError(new _.EInProgress())
	} else if (code === 37) {
		return new _.ConnectError(new _.EAlready())
	} else if (code === 38) {
		return new _.ConnectError(new _.ENotSock())
	} else if (code === 41) {
		return new _.ConnectError(new _.EPrototype())
	} else if (code === 47) {
		return new _.ConnectError(new _.EAfnosupport())
	} else if (code === 49) {
		return new _.ConnectError(new _.Eddrnotavail())
	} else if (code === 48) {
		return new _.ConnectError(new _.EAddrinuse())
	} else {
		return new _.ConnectError(new _.UnknownConnectError(err.toString()))
	}
}

function curl_error_to_gleam(err) {
	const code = err.code
	let msg = err.message?.substring(err.message.indexOf(':') + 12)
	msg = msg?.substring(0, msg.indexOf('\n'))
	if (code === 6) {
		return new _.DNSError(new _.NotFound())
	} else if (code === 7 || code === 9) {
		return new _.ConnectError(new _.EConnrefused())
	} else if (code === 28) {
		return new _.ConnectError(new _.ETimeout())
	} else if (code === 35 || code === 53 || code === 54 || code === 58 || code === 59) {
		return new _.TLSError(new _.UnknownTLSError(msg))
	}
	return new _.ConnectError(new _.UnknownConnectError(msg))
}

export function fetch_error_to_gleam(err) {
	if (typeof globalThis.XMLHttpRequest === 'function' && typeof err.code === 'number') {
		return xmlhttprequest_error_to_gleam(err)
	}
	if (err.cause === undefined && err.code === undefined) {
		return new _.ConnectError(new _.UnknownConnectError(err.toString()))
	} else if (err.code !== 0) {
		return curl_error_to_gleam(err)
	}
	let cause = err.cause
	if (cause.code === "UND_ERR_CONNECT_TIMEOUT") {
		return new _.ConnectError(new _.ETimeout())
	} else if (cause.code === "ERR_TLS_CERT_ALTNAME_INVALID") {
		return new _.TLSError(new _.InvalidTLSCertAltName())
	}
	if (cause.syscall === undefined && cause.errors?.[0]?.syscall !== undefined) {
		cause = cause.errors[0]
	}
	if (cause.syscall === 'getaddrinfo') {
		return fetch_getaddrinfo_error_to_gleam(cause.code)
	} else if (cause.syscall === 'connect') {
		return fetch_connect_error_to_gleam(cause.code)
	} else {
		return new _.ConnectError(new _.UnknownConnectError(cause.toString()))
	}
}