import gleam/string

pub fn expect(res: Result(t, e), msg: String) -> t {
  case res {
    Ok(r) -> r
    Error(err) -> {
      let m = msg <> ": " <> string.inspect(err)

      panic as m
    }
  }
}

pub fn unwrap(res: Result(t, e)) -> t {
  expect(res, "called unwrap() on an Error value")
}
