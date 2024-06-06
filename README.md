# efetch

[![Package Version](https://img.shields.io/hexpm/v/efetch)](https://hex.pm/packages/efetch)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/efetch/)

```sh
gleam add efetch
```
```gleam
import gleam/http/request
import gleam/http
import gleam/result
import efetch

pub fn main() {
  let assert Ok(req) = request.to("https://github.com")
  use res <- efetch.send(req)
  res
  |> result.map(fn(res) { io.debug(res.status) })
  |> result.map_error(io.debug)
}
```

Further documentation can be found at <https://hexdocs.pm/efetch>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
gleam shell # Run an Erlang shell
```
