if (typeof globalThis.XMLHttpRequest !== 'function') {
	globalThis.request = (await import("sync-request-curl")).default;
}

function fetchSyncCurl(url, options ={}) {
	const res = request(options.method || 'GET', url, options)
	let statusText
	if (res.statusCode === 200) {
		statusText = 'OK'
	}
	let text = () => new TextDecoder('utf8').decode(res.body)
	return {
    status: res.statusCode,
    statusText: statusText,
    headers: res.headers,
    arrayBuffer: () => res.body,
    text,
    json: () => JSON.parse(text),
    blob: () => new Blob([res.body]),
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
