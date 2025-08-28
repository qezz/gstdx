import gleam/option.{type Option, None, Some}

pub fn expect(res: option.Option(t), msg: String) -> t {
  case res {
    Some(val) -> val
    None -> {
      panic as msg
    }
  }
}

pub fn unwrap(res: Option(t)) -> t {
  expect(res, "called unwrap() on an None value")
}
