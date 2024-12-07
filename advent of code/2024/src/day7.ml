open! Core

module Equation = struct
  type t = { target : int; operands : int list } [@@deriving sexp]

  let parse s =
    let target, operands = Utils.extract_numbers s |> Utils.head_and_tl_exn in
    { target; operands }

  let solvable ~with_operators t =
    let rec helper t ~acc =
      match t with
      | { target; operands = [] } -> target = acc
      | { target; operands = hd :: remaining } ->
          let new_equation = { target; operands = remaining } in
          List.exists with_operators ~f:(fun op ->
              helper new_equation ~acc:(op acc hd))
    in
    let acc, operands = Utils.head_and_tl_exn t.operands in
    helper { t with operands } ~acc
end

let parse_input puzzle_input =
  puzzle_input |> String.strip |> String.split_lines
  |> List.map ~f:Equation.parse

let part1 (puzzle_input : string) =
  let equations = parse_input puzzle_input in
  equations
  |> List.filter ~f:(Equation.solvable ~with_operators:[ ( + ); ( * ) ])
  |> List.sum (module Int) ~f:(fun (equation : Equation.t) -> equation.target)

let part2 (puzzle_input : string) =
  let equations = parse_input puzzle_input in
  let concat_nums n1 n2 =
    Int.to_string n1 ^ Int.to_string n2 |> Int.of_string
  in
  equations
  |> List.filter
       ~f:(Equation.solvable ~with_operators:[ ( + ); ( * ); concat_nums ])
  |> List.sum (module Int) ~f:(fun (equation : Equation.t) -> equation.target)

let example_input = Utils.read_file "../inputs/day7-example.txt"
let real_input = Utils.read_file "../inputs/day7-input.txt"

let%expect_test "Part 1: Example input" =
  let result = part1 example_input in
  [%test_result: int] result ~expect:3749

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 882304362421 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input in
  [%test_result: int] result ~expect:11387

let%expect_test "Part 2: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 145149066755184 |}]
