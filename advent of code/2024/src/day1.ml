open! Core

let example_input = {|
3   4
4   3
2   5
1   3
3   9
3   3
|} |> String.strip

let real_input = Utils.read_file "../inputs/day1-input.txt"

let parse_line (line : string) : int * int =
  let parse_int s = Int.of_string (String.strip s) in
  line |> String.lsplit2_exn ~on:' ' |> Tuple2.map ~f:parse_int

let part1 (puzzle_input : string) =
  let left_unsorted, right_unsorted =
    puzzle_input |> String.split_lines |> List.map ~f:parse_line |> List.unzip
  in
  let pairs_sorted =
    let left_sorted = List.sort left_unsorted ~compare:Int.compare in
    let right_sorted = List.sort right_unsorted ~compare:Int.compare in
    List.zip_exn left_sorted right_sorted
  in
  List.sum (module Int) pairs_sorted ~f:(fun (a, b) -> abs (a - b))

let part2 (puzzle_input : string) =
  let left, right =
    puzzle_input |> String.split_lines |> List.map ~f:parse_line |> List.unzip
  in
  let count_in_right num = List.count right ~f:(Int.equal num) in
  List.sum (module Int) left ~f:(fun n -> n * count_in_right n)

let%expect_test "Part 1: Example input" =
  let result = part1 example_input in
  [%test_result: int] result ~expect:11

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 2196996 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input in
  [%test_result: int] result ~expect:31

let%expect_test "Part 2: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 23655822 |}]
