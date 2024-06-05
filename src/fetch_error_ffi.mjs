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
		connect_err = new _.EACCES()
	} else if (code === 'EPERM') {
		connect_err = new _.EPERM()
	} else if (code === 'EADDRINUSE') {
		connect_err = new _.EADDRINUSE()
	} else if (code === 'EADDRNOTAVAIL') {
		connect_err = new _.EADDRNOTAVAIL()
	} else if (code === 'EAFNOSUPPORT') {
		connect_err = new _.EAFNOSUPPORT()
	} else if (code === 'EAGAIN') {
		connect_err = new _.EAGAIN()
	} else if (code === 'EALREADY') {
		connect_err = new _.EALREADY()
	} else if (code === 'EBADF') {
		connect_err = new _.EBADF()
	} else if (code === 'ECONNREFUSED') {
		connect_err = new _.ECONNREFUSED()
	} else if (code === 'EFAULT') {
		connect_err = new _.EFAULT()
	} else if (code === 'EINPROGRESS') {
		connect_err = new _.EINPROGRESS()
	} else if (code === 'EINTR') {
		connect_err = new _.EINTR()
	} else if (code === 'EISCONN') {
		connect_err = new _.EISCONN()
	} else if (code === 'ENETUNREACH') {
		connect_err = new _.ENETUNREACH()
	} else if (code === 'ENODATA') {
		connect_err = new _.NoData()
	} else if (code === 'ENOTSOCK') {
		connect_err = new _.ENOTSOCK()
	} else if (code === 'EPROTOTYPE') {
		connect_err = new _.EPROTOTYPE()
	} else if (code === 'ETIMEDOUT') {
		connect_err = new _.ETIMEDOUT()
	} else {
		connect_err = new _.UnknownConnectErr(code)
	}
	return new _.ConnectError(connect_err)
}

export function fetch_error_to_gleam(err) {
	if (err.cause === undefined) {
		return undefined
	}
	let cause = err.cause
	if (cause.code === "UND_ERR_CONNECT_TIMEOUT") {
		return new _.ConnectError(new _.ETIMEDOUT())
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
		return undefined
	}
}