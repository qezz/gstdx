import gleam/int
import gleam/list
import gleam/option.{type Option}
import gleam/string

fn count_leading_whitespace(line: String) -> Int {
  string.length(line) - string.length(string.trim_start(line))
}

fn is_empty_or_whitespace_only(line: String) -> Bool {
  string.is_empty(string.trim(line))
}

fn find_min_indent(lines: List(String)) -> Option(Int) {
  lines
  |> list.filter(fn(line) { !is_empty_or_whitespace_only(line) })
  |> list.map(count_leading_whitespace)
  |> list.reduce(int.min)
  |> option.from_result
}

/// Removes common leading whitespaces for each line.
/// Empty lines are ignored when counting the common indentation.
///
/// The behavior is similar to Python's `textwrap.dedent`, but depends
/// on Gleam's implementation of `string.trim_start`
pub fn dedent(text: String) -> String {
  let lines = string.split(text, "\n")

  case lines {
    [] -> ""
    _ -> {
      case find_min_indent(lines) {
        option.None -> text
        option.Some(min_indent) -> {
          lines
          |> list.map(string.drop_start(_, min_indent))
          |> string.join("\n")
        }
      }
    }
  }
}

/// Add prefix to the beginning of each non-empty line in text.
///
/// The behavior is similar to Python's `textwrap.indent` with the default
/// predicate.
pub fn indent(text: String, indentation: String) -> String {
  string.split(text, "\n")
  |> list.map(fn(line) {
    case is_empty_or_whitespace_only(line) {
      True -> line
      False -> indentation <> line
    }
  })
  |> string.join("\n")
}
