import { Ok, Error } from "./gleam.mjs";
import { fetch_error_to_gleam } from './fetch_error_ffi.mjs'
import { to_string as uri_to_string } from "../gleam_stdlib/gleam/uri.mjs";
import { method_to_string } from "../gleam_http/gleam/http.mjs";
import { to_uri } from "../gleam_http/gleam/http/request.mjs";
import { NotFound } from "./efetch/internal/fetch/error.mjs"
import { fetchSync } from './sync_fetch_ffi.mjs'

export function raw_send(request) {
  try {
  const headers = request.headers.forEach((v, k) => { b[k] = v })
    return new Ok(fetchSync(request.url, {...request, headers}));
  } catch (err) {
    return new Error(fetch_error_to_gleam(err));
  }
}

function make_headers(headersList) {
  let headers = new globalThis.Headers();
  for (let [k, v] of headersList) headers.append(k.toLowerCase(), v);
  return headers;
}


function request_common(request) {
  let url = uri_to_string(to_uri(request));
  let method = method_to_string(request.method).toUpperCase();
  let options = {
    headers: make_headers(request.headers),
    method,
  };
  return [url, options]
}

export function to_fetch_request(request) {
  let [url, options] = request_common(request)
  if (options.method !== "GET" && options.method !== "HEAD") options.body = request.body;
  try {
  	return new Ok(new globalThis.Request(url, options))
  } catch (err) {
  	return new Error(new NotFound())
  }
}

export function bitarray_request_to_fetch_request(request) {
  let [url, options] = request_common(request)
  if (options.method !== "GET" && options.method !== "HEAD") options.body = request.body.buffer;
  try {
    	return Ok(new globalThis.Request(url, options))
    } catch (err) {
    	return new Error(new NotFound())
    }
}