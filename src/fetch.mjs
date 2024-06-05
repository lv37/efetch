import * as $fetch from "../gleam_fetch/gleam/fetch.mjs";
import * as $promise from "../gleam_javascript/gleam/javascript/promise.mjs";
import { bitarray_request_to_fetch_request, raw_send as fetch, to_fetch_request } from "./fetch_ffi.mjs";
import { Error, Ok } from "./gleam.mjs";
import * as $error from "./efetch/internal/fetch/error.mjs";

export { bitarray_request_to_fetch_request, fetch, to_fetch_request };

export function fetch_callback(req, transform_fn, callback) {
  let $ = transform_fn(req);
  if ($.isOk()) {
    let req$1 = $[0];
    let _pipe = fetch(req$1);
    $promise.tap(
      _pipe,
      (res) => {
        if (!res.isOk()) {
          let err = res[0];
          callback(new Error(err));
          return undefined;
        } else {
          let res$1 = res[0];
          callback(new Ok(res$1));
          return undefined;
        }
      },
    )
    undefined
  } else {
    let err = $[0];
    callback(new Error(new $error.DNSError(err)));
    undefined
  }
  return req;
}

export function send_generic(req, callback, transform_req_fn, transform_fn) {
  return fetch_callback(
    req,
    transform_req_fn,
    (res) => {
      if (!res.isOk()) {
        let err = res[0];
        callback(new Error(err));
        return undefined;
      } else {
        let res$1 = res[0];
        let _pipe = $fetch.from_fetch_response(res$1);
        let _pipe$1 = transform_fn(_pipe);
        $promise.tap(
          _pipe$1,
          (res) => {
            if (!res.isOk() && res[0] instanceof $fetch.InvalidJsonBody) {
              return callback(new Error(new $error.InvalidJsonBody()));
            } else if (!res.isOk() && res[0] instanceof $fetch.UnableToReadBody) {
              return callback(new Error(new $error.UnableToReadBody()));
            } else if (!res.isOk() && res[0] instanceof $fetch.NetworkError) {
              return callback(new Error(new $error.UnableToReadBody()));
            } else {
              let res$1 = res[0];
              return callback(new Ok(res$1));
            }
          },
        )
        return undefined;
      }
    },
  );
}

export function send(req, callback) {
  return send_generic(req, callback, to_fetch_request, $fetch.read_text_body);
}

export function send_bits(req, callback) {
  return send_generic(
    req,
    callback,
    bitarray_request_to_fetch_request,
    $fetch.read_bytes_body,
  );
}
