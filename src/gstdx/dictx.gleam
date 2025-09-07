import gleam/dict.{type Dict}
import gleam/list

/// Merges all dictionaries from left to right.
///
/// Note: In some programming languages a relevant function is called `union`,
/// in Gleam stdlib it's called `dict.merge`.
///
/// Extra note: The implementation of this function is trivial, you might want
/// to simply "inline" the implementation into your code.
///
/// ## Examples
///
/// ```gleam
/// [
///   [
///     #("a", 1),
///     #("b", 1),
///   ],
///   [
///     #("b", 2),
///     #("c", 2),
///   ],
/// ]
/// |> list.map(fn(list_of_pairs) { list_of_pairs |> dict.from_list })
/// |> merge_all
/// |> dict.to_list
/// // -> [
/// //   #("a", 1),
/// //   #("b", 2),
/// //   #("c", 2),
/// // ]
/// ```
pub fn merge_all(data: List(Dict(k, v))) -> Dict(k, v) {
  case data {
    [] -> dict.new()
    [head, ..rest] -> rest |> list.fold(from: head, with: dict.merge)
  }
}
