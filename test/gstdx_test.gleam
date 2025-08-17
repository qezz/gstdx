import gleam/dict
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
