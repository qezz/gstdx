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
/// A more practical example, imagine you have a list of services
/// and each of them can be deployed to a several targets (hosts).
/// You can map `host -> List(service)` as follows:
///
/// ```gleam
/// [
///   #("service_a", ["host01", "host02"]),
///   #("service_b", ["host02", "host03"]),
///   #("service_c", ["host01"]),
/// ]
/// |> listx.group_by_many(fn(pair) { pair.1 })
/// |> dict.to_list
/// // -> [
/// //  #("host01", [
/// //    #("service_c", ["host01"]),
/// //    #("service_a", ["host01", "host02"]),
/// //  ]),
/// //  #("host02", [
/// //    #("service_b", ["host02", "host03"]),
/// //    #("service_a", ["host01", "host02"]),
/// //  ]),
/// //  #("host03", [#("service_b", ["host02", "host03"])]),
/// // ]
///
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

pub type KeyByError(k, t) {
  DuplicateKeyError(key: k, items: List(t))
}

/// Build a dictionary based on the `key` getter function.
///
/// Returns a list of `DuplicateKeyError`s if there are duplicate keys.
///
/// ## Examples
///
/// ```gleam
/// [#("alice", 23), #("bob", 42)]
/// |> key_by(fn(pair) {pair.0})
/// |> result.lazy_unwrap(fn() { panic as "invalid" })
/// |> dict.to_list
/// // -> [
/// //   #("alice", #("alice", 23)),
/// //   #("bob", #("bob", 42)),
/// // ]
/// ```
///
pub fn key_by(
  list: List(v),
  by key: fn(v) -> k,
) -> Result(dict.Dict(k, v), List(KeyByError(k, v))) {
  let #(result_dict, errors) =
    list
    |> list.group(by: key)
    |> dict.fold(#(dict.new(), []), fn(acc, k, items) {
      let #(dict_acc, errors_acc) = acc
      case items {
        [single_item] -> #(dict.insert(dict_acc, k, single_item), errors_acc)
        multiple_items -> #(dict_acc, [
          DuplicateKeyError(k, multiple_items),
          ..errors_acc
        ])
      }
    })

  case errors {
    [] -> Ok(result_dict)
    _ -> Error(errors)
  }
}

/// Enumerate list items, starting from 0.
///
/// This function is similar to `list.index_map`, but without the mapping step.
///
/// ## Examples
///
/// ```gleam
/// ["a", "b", "c"]
/// |> enumerate
/// // -> [#(0, "a"), #(1, "b"), #(2, "c")]
/// ```
pub fn enumerate(list: List(v)) -> List(#(Int, v)) {
  list.index_map(list, fn(item, idx) { #(idx, item) })
}
