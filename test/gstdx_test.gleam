import gleam/dict
import gleam/list
import gleeunit
import gstdx/listx

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn list_group_flat_lists_test() {
  let input = [#("a", [100, 200]), #("b", [200]), #("c", [])]

  let res =
    input
    |> listx.group_by_many(by: fn(pair) { pair.1 })
    |> dict.to_list

  let expected = [
    #(100, [#("a", [100, 200])]),
    #(200, [#("b", [200]), #("a", [100, 200])]),
  ]

  assert expected == res
}

pub fn listx_keyed_ok_test() {
  let input = [
    #("a", "x"),
    #("b", "y"),
  ]

  let expected =
    Ok(
      dict.from_list([
        #("x", #("a", "x")),
        #("y", #("b", "y")),
      ]),
    )

  let res = input |> listx.keyed(by: fn(pair) { pair.1 })

  assert expected == res
}

pub fn listx_keyed_err_test() {
  let input = [
    #("a", 1, "x"),
    #("a", 2, "x"),
    #("c", 3, "x"),
    #("d", 4, "y"),
  ]

  let expected =
    Error([
      listx.DuplicateKeyError("x", [
        #("c", 3, "x"),
        #("a", 2, "x"),
        #("a", 1, "x"),
      ]),
    ])
  let res = input |> listx.keyed(by: fn(trio) { trio.2 })

  assert expected == res

  let handled = case res {
    Error(errors) -> errors |> list.map(with: fn(err) { err.key })
    _ -> panic as "impossible"
  }

  assert handled == ["x"]
}
