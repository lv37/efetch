import * as $fetch from "../gleam_fetch/gleam/fetch.mjs";
import * as $promise from "../gleam_javascript/gleam/javascript/promise.mjs";
import { bitarray_request_to_fetch_request, raw_send as fetch, to_fetch_request } from "./fetch_ffi.mjs";
import { Error, Ok } from "./gleam.mjs";
import * as $error from "./efetch/internal/fetch/error.mjs";

export { bitarray_request_to_fetch_request, fetch, to_fetch_request };

function read_bytes_body(response) {
  let body;
  try {
    body = response.body.arrayBuffer()
  } catch (error) {
    return new Error(new $fetch.UnableToReadBody());
  }
  return new Ok(response.withFields({ body: toBitArray(new Uint8Array(body)) }));
}

function read_text_body(response) {
  let body;
  try {
    body = response.body.text();
  } catch (error) {
    return new Error(new $fetch.UnableToReadBody());
  }
  return new Ok(response.withFields({ body }));
}

export function fetch_callback(req, transform_fn) {
  let $ = transform_fn(req);

  if ($.isOk()) {
    let req$1 = $[0];
    let res = fetch(req$1);
    if (!res.isOk()) {
      return new Error(res[0])
    } else {
      return new Ok(res[0])
    }
  } else {
    let err = $[0];
    return new Error(new $error.DNSError(err));
  }
}

export function send_generic(req, transform_req_fn, transform_fn) {
  const res = fetch_callback(
    req,
    transform_req_fn,
  )
  if (!res.isOk()) {
    let err = res[0];
    return new Error(err);
  } else {
    let res$1 = res[0];
    let _pipe = $fetch.from_fetch_response(res$1);
    let res$2 = transform_fn(_pipe);

    if (!res$2.isOk() && res$2[0] instanceof $fetch.InvalidJsonBody) {
      return new Error(new $error.InvalidJsonBody());
    } else if (!res$2.isOk() && res$2[0] instanceof $fetch.UnableToReadBody) {
      return new Error(new $error.UnableToReadBody());
    } else if (!res$2.isOk() && res$2[0] instanceof $fetch.NetworkError) {
      return new Error(new $error.UnableToReadBody());
    } else {
      let res$1 = res$2[0];
      return new Ok(res$1);
    }
  }


}

export function send(req) {
  return send_generic(req, to_fetch_request, read_text_body);
}

export function send_bits(req, callback) {
  return send_generic(
    req,
    bitarray_request_to_fetch_request,
    read_bytes_body,
  );
}
