# efetch

[![Package Version](https://img.shields.io/hexpm/v/efetch)](https://hex.pm/packages/efetch)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/efetch/)

Uses `XMLHttpRequest` for the browser and `libcurl` for Nodejs.

```sh
gleam add efetch
```
```gleam
import gleam/http/request
import gleam/http
import efetch

pub fn main() {
  let assert Ok(req) = request.to("https://github.com")
  efetch.send(req)
  |> io.debug
}
```

Further documentation can be found at <https://hexdocs.pm/efetch>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
