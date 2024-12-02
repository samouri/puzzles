open! Core

let example_input = Utils.read_file "../inputs/day2-example.txt"
let real_input = Utils.read_file "../inputs/day2-input.txt"

let parse_line (line : string) : int list =
  let parse_int s = Int.of_string (String.strip s) in
  line |> String.split ~on:' ' |> List.map ~f:parse_int

let is_safe l =
  let is_in_order =
    let is_ascending = List.is_sorted l ~compare:Int.compare in
    let is_descending =
      List.is_sorted l ~compare:(Comparable.reverse Int.compare)
    in
    is_ascending || is_descending
  in
  let diff_between_one_and_three =
    let is_valid_diff n1 n2 =
      let diff = Int.abs (n2 - n1) in
      diff = 1 || diff = 2 || diff = 3
    in
    List.for_alli (List.tl_exn l) ~f:(fun i n ->
        let prev = List.nth_exn l i in
        is_valid_diff prev n)
  in
  is_in_order && diff_between_one_and_three

let part1 (puzzle_input : string) =
  let lines = puzzle_input |> String.split_lines |> List.map ~f:parse_line in
  List.count lines ~f:is_safe

let part2 (puzzle_input : string) =
  let lines = puzzle_input |> String.split_lines |> List.map ~f:parse_line in
  let get_all_variants l =
    let remove_nth nth = List.filteri l ~f:(fun i _ -> i <> nth) in
    List.init (List.length l) ~f:remove_nth
  in
  List.count lines ~f:(fun line ->
      List.exists (get_all_variants line) ~f:is_safe)

let%expect_test "Part 1: Example input" =
  let result = part1 example_input in
  [%test_result: int] result ~expect:2

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 510 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input in
  [%test_result: int] result ~expect:4

let%expect_test "Part 4: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 553 |}]
