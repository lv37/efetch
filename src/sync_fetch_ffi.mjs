if (typeof globalThis.XMLHttpRequest !== 'function') {
	globalThis.request = (await import("sync-request-curl")).default;
}

function fetchSyncCurl(url, options ={}) {
	const res = request(options.method || 'GET', url, options)
	let statusText
	if (res.statusCode === 200) {
		statusText = 'OK'
	}
	return {
    status: res.statusCode,
    statusText: statusText,
    headers: res.headers,
    text: () => res.getBody('utf8'),
    json: () => JSON.parse(res.getBody('utf8')),
    blob: () => new Blob([res.getBody('binary')]),
    arrayBuffer: () => res.getBody('binary'),
  };
}

export function fetchSync(url, options = {}) {
	if (typeof globalThis.XMLHttpRequest === 'function') {
		return fetchSyncXMLHttpRequest(url, options)
  } else {
	  return fetchSyncCurl(url, options)
  }
}

function fetchSyncXMLHttpRequest(url, options = {}) {
  const xhr = new XMLHttpRequest();

  xhr.open(options.method || 'GET', url, false);

  if (options.headers) {
    for (const [key, value] of Object.entries(options.headers)) {
      xhr.setRequestHeader(key, value);
    }
  }

  if (options.body) {
    xhr.send(options.body, false);
  } else {
    xhr.send('', false);
  }

  const response = {
    status: xhr.status,
    statusText: xhr.statusText,
    headers: {},
    get headersObject() {
    	console.log(xhr.getAllResponseHeaders())
      const headersArray = xhr.getAllResponseHeaders().trim().split(/[\r\n]+/);
      headersArray.forEach(line => {
        const parts = line.split(': ');
        this.headers[parts[0].trim()] = parts[1].trim();
      });
      return this.headers;
    },
    text: () => xhr.responseText,
    json: () => JSON.parse(xhr.responseText),
    blob: () => new Blob([xhr.response]),
    arrayBuffer: () => xhr.response,
  };

  return response
}
