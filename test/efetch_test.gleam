import efetch
import gleam/dict
import gleam/dynamic/decode
import gleam/http
import gleam/http/request
import gleam/json
import gleam/option.{None, Some}
import gleam/string
import gleeunit

pub fn main() {
  gleeunit.main()
}

pub type Echo {
  Echo(
    method: String,
    protocol: String,
    host: String,
    path: String,
    ip: String,
    headers: dict.Dict(String, String),
    parsed_query_params: dict.Dict(String, String),
    raw_body: option.Option(String),
  )
}

fn echo_decoder() -> decode.Decoder(Echo) {
  use method <- decode.field("method", decode.string)
  use protocol <- decode.field("protocol", decode.string)
  use host <- decode.field("host", decode.string)
  use path <- decode.field("path", decode.string)
  use ip <- decode.field("ip", decode.string)
  use headers <- decode.field(
    "headers",
    decode.dict(decode.string, decode.string),
  )
  use parsed_query_params <- decode.field(
    "parsedQueryParams",
    decode.dict(decode.string, decode.string),
  )
  case string.uppercase(method) {
    "POST" | "PUT" -> {
      use raw_body <- decode.field("rawBody", decode.optional(decode.string))
      decode.success(Echo(
        method:,
        protocol:,
        host:,
        path:,
        ip:,
        headers:,
        parsed_query_params:,
        raw_body:,
      ))
    }
    _ ->
      decode.success(Echo(
        method:,
        protocol:,
        host:,
        path:,
        ip:,
        headers:,
        parsed_query_params:,
        raw_body: None,
      ))
  }
}

pub fn post_test() {
  let assert Ok(res) =
    request.Request(
      method: http.Post,
      headers: [
        #("Abc", "def"),
        #("Ghi", "jkl"),
        #("User-Agent", "efetch"),
        #("Content-Type", "application/text"),
        #("Accept-Encoding", "raw"),
      ],
      body: "Hello world!",
      scheme: http.Https,
      host: "echo.free.beeceptor.com",
      port: None,
      path: "/",
      query: None,
    )
    |> efetch.send()

  assert res.status == 200
  let assert Ok(res) = json.parse(res.body, echo_decoder())

  assert res.method |> string.uppercase == "POST"
  assert res.protocol |> string.uppercase == "HTTPS"
  assert res.host |> string.lowercase == "echo.free.beeceptor.com"
  assert res.path |> string.lowercase == "/"

  assert dict.get(res.headers, "Abc") == Ok("def")
  assert dict.get(res.headers, "Ghi") == Ok("jkl")
  assert dict.get(res.headers, "User-Agent") == Ok("efetch")
  assert dict.get(res.headers, "Accept-Encoding") == Ok("raw")
  let content_type = dict.get(res.headers, "Content-Type")
  assert content_type == Ok("application/text")
    || content_type == Ok("application/octet-stream")

  assert res.raw_body == Some("Hello world!")
}

pub fn get_test() {
  let assert Ok(res) =
    request.Request(
      method: http.Get,
      headers: [
        #("Abc", "def"),
        #("Ghi", "jkl"),
        #("User-Agent", "efetch"),
        #("Content-Type", "application/text"),
        #("Accept-Encoding", "raw"),
      ],
      body: "Hello world!",
      scheme: http.Https,
      host: "echo.free.beeceptor.com",
      port: None,
      path: "/",
      query: None,
    )
    |> efetch.send()

  assert res.status == 200
  let assert Ok(res) = json.parse(res.body, echo_decoder())

  assert res.method |> string.uppercase == "GET"
  assert res.protocol |> string.uppercase == "HTTPS"
  assert res.host |> string.lowercase == "echo.free.beeceptor.com"
  assert res.path |> string.lowercase == "/"

  assert dict.get(res.headers, "Abc") == Ok("def")
  assert dict.get(res.headers, "Ghi") == Ok("jkl")
  assert dict.get(res.headers, "User-Agent") == Ok("efetch")
  assert dict.get(res.headers, "Accept-Encoding") == Ok("raw")
  let content_type = dict.get(res.headers, "Content-Type")
  assert content_type == Ok("application/text")
    || content_type == Ok("application/octet-stream")

  assert res.raw_body == None
}
