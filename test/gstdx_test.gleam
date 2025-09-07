import gleam/dict
import gleam/list
import gleam/option
import gleam/result
import gleeunit
import gstdx/dictx
import gstdx/listx
import gstdx/optionx
import gstdx/resultx
import gstdx/textwrap

type TestCase(i, o) {
  TestCase(input: i, expected: o)
}

type TestCase2(i1, i2, o) {
  TestCase2(input1: i1, input2: i2, expected: o)
}

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

pub fn list_group_by_many_test() {
  let input = [
    #("service_a", ["host01", "host02"]),
    #("service_b", ["host02", "host03"]),
    #("service_c", ["host01"]),
  ]

  let expected = [
    #("host01", [
      #("service_c", ["host01"]),
      #("service_a", ["host01", "host02"]),
    ]),
    #("host02", [
      #("service_b", ["host02", "host03"]),
      #("service_a", ["host01", "host02"]),
    ]),
    #("host03", [#("service_b", ["host02", "host03"])]),
  ]

  let actual =
    input
    |> listx.group_by_many(fn(pair) { pair.1 })
    |> dict.to_list

  assert expected == actual
}

pub fn listx_key_by_ok_test() {
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

  let res = input |> listx.key_by(by: fn(pair) { pair.1 })

  assert expected == res
}

pub fn listx_key_by_ok_2_test() {
  let input = [#("alice", 23), #("bob", 42)]

  let expected = [
    #("alice", #("alice", 23)),
    #("bob", #("bob", 42)),
  ]

  let actual =
    input
    |> listx.key_by(fn(pair) { pair.0 })
    |> result.lazy_unwrap(fn() { panic as "invalid" })
    |> dict.to_list

  assert expected == actual
}

pub fn listx_key_by_err_test() {
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
  let res = input |> listx.key_by(by: fn(trio) { trio.2 })

  assert expected == res

  let handled = case res {
    Error(errors) -> errors |> list.map(with: fn(err) { err.key })
    _ -> panic as "impossible"
  }

  assert handled == ["x"]
}

pub fn textwrap_dedent_test() {
  let testcases = [
    TestCase("   hello\n  world", " hello\nworld"),
    TestCase("no changes\n     expected here", "no changes\n     expected here"),
    TestCase(
      "    consistent\n    indentation\n    block",
      "consistent\nindentation\nblock",
    ),
    TestCase("\n   hey\n   it's me", "\nhey\nit's me"),
    TestCase(
      "\n  we need more\n\n\n  empty lines",
      "\nwe need more\n\n\nempty lines",
    ),
  ]

  list.each(testcases, fn(tc) {
    assert tc.expected == textwrap.dedent(tc.input)
  })
}

pub fn textwrap_indent_test() {
  let testcases = [
    TestCase2("hello\n  world", "  ", "  hello\n    world"),
    TestCase2("\n   \nhey", "xxx", "\n   \nxxxhey"),
  ]

  list.each(testcases, fn(tc) {
    assert tc.expected == textwrap.indent(tc.input1, tc.input2)
  })
}

pub fn resultx_unwrap_test() {
  let x: Result(Int, Int) = Ok(42)
  resultx.unwrap(x)
  // These tests will fail the tests suite.
  //
  // let y: Result(Int, Int) = Error(64)
  // resultx.unwrap(y)
}

pub fn optionx_unwrap_test() {
  let x: option.Option(Int) = option.Some(42)
  optionx.unwrap(x)
  // These tests will fail the tests suite.
  //
  // let y: option.Option(Int) = option.None
  // optionx.unwrap(y)
}

pub fn listx_enumerate_test() {
  let input = ["a", "b", "c"]
  let expected = [#(0, "a"), #(1, "b"), #(2, "c")]

  let actual = input |> listx.enumerate

  assert expected == actual
}

pub fn dictx_merge_all_test() {
  let input =
    [
      [
        #("a", 1),
        #("b", 1),
      ],
      [
        #("b", 2),
        #("c", 2),
      ],
      [
        #("a", 3),
        #("c", 3),
        #("d", 4),
      ],
    ]
    |> list.map(fn(list_of_pairs) { list_of_pairs |> dict.from_list })

  let expected =
    dict.from_list([
      #("a", 3),
      #("b", 2),
      #("c", 3),
      #("d", 4),
    ])

  let actual = input |> dictx.merge_all()

  assert expected == actual
}
