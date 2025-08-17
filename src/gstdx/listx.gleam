import gleam/dict
import gleam/list

/// Groups the elements from the given list by each item returned by the given function
///
/// Does not preserve the initial value order.
///
/// ## Examples
///
/// ```gleam
/// import gleam/dict
///
/// [#("a", [100, 200]), #("b", [200]), #("c", [])]
/// |> group_by_many(by: fn(pair) { pair.1 })
/// |> dict.to_list
/// // -> [#(100, [#("a", [100, 200])]), #(200, [#("b", [200]), #("a", [100, 200])])]
/// ```
///
pub fn group_by_many(
  list: List(v),
  by key: fn(v) -> List(k),
) -> dict.Dict(k, List(v)) {
  list
  |> list.flat_map(fn(item) {
    key(item)
    |> list.map(fn(key_item) { #(key_item, item) })
  })
  |> list.group(by: fn(pair) { pair.0 })
  |> dict.map_values(fn(_k, pairs) {
    pairs
    |> list.map(fn(pair) { pair.1 })
  })
}
