open! Core

let example_input1 =
  "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

let example_input2 =
  "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

let real_input = Utils.read_file "../inputs/day3-input.txt"

module Operation = struct
  type t = Mult of int * int | Do | Don't [@@deriving sexp]

  let parse_match_exn (match_ : Re2.Match.t) =
    let whole_match =
      Re2.Match.get ~sub:(`Index 0) match_ |> Option.value_exn
    in
    if String.equal whole_match "do()" then Do
    else if String.equal whole_match "don't()" then Don't
    else
      let parse_operand index =
        Re2.Match.get ~sub:(`Index index) match_
        |> Option.value_exn |> Int.of_string
      in
      Mult (parse_operand 1, parse_operand 2)
end

let get_operations input_ =
  let operations_regex =
    Re2.create_exn {|mul\((\d+),(\d+)\)|don't\(\)|do\(\)|}
  in
  input_ |> String.split_lines
  |> List.concat_map ~f:(fun line -> Re2.get_matches_exn operations_regex line)
  |> List.map ~f:Operation.parse_match_exn

let part1 (puzzle_input : string) =
  let operations = get_operations puzzle_input in
  let get_value = function Operation.Do | Don't -> 0 | Mult (a, b) -> a * b in
  List.sum (module Int) operations ~f:get_value

let part2 (puzzle_input : string) =
  let operations = get_operations puzzle_input in
  List.fold operations ~init:(true, 0) ~f:(fun (should, acc) op ->
      match op with
      | Mult (a, b) -> (should, acc + if should then a * b else 0)
      | Do -> (true, acc)
      | Don't -> (false, acc))
  |> snd

let%expect_test "Part 1: Example input" =
  let result = part1 example_input1 in
  [%test_result: int] result ~expect:161

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 161085926 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input2 in
  [%test_result: int] result ~expect:48

let%expect_test "Part 2: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 82045421 |}]
