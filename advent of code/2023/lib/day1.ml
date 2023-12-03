open! Core

let word_to_int = function
  | "one" -> "1"
  | "two" -> "2"
  | "three" -> "3"
  | "four" -> "4"
  | "five" -> "5"
  | "six" -> "6"
  | "seven" -> "7"
  | "eight" -> "8"
  | "nine" -> "9"
  | s -> s

let part1 ?(file = "day1.txt") () =
  let lines = Utils.read_lines file in
  let find_nums str = Re2.find_all_exn (Re2.create_exn {|\d|}) str in
  let process_line line =
    let numbers = find_nums line in
    let first = List.hd_exn numbers in
    let last = List.rev numbers |> List.hd_exn in
    Int.of_string (first ^ last)
  in
  List.sum (module Int) lines ~f:process_line

let part2 ?(file = "day1.txt") () =
  let lines = Utils.read_lines file in
  let find_nums =
    Re2.create_exn "\\d|one|two|three|four|five|six|seven|eight|nine"
  in
  let process_line line =
    let first = Re2.find_first_exn find_nums line |> word_to_int in
    (* Using foldi and regex to find the last occurence is dumb. *)
    let last =
      String.foldi ~init:first line ~f:(fun i acc _c ->
          let rest = String.slice line i (String.length line) in
          Re2.find_first find_nums rest
          |> Or_error.ok |> Option.value ~default:acc)
      |> word_to_int
    in
    Int.of_string (first ^ last)
  in
  List.sum (module Int) lines ~f:process_line

let%test_unit "part1-example" =
  [%test_result: int] ~expect:142 (part1 ~file:"day1-example.txt" ())

let%test_unit "part2-example" =
  [%test_result: int] ~expect:281 (part2 ~file:"day1-example2.txt" ())

let%test_unit "part1" =
  [%test_result: int] ~expect:54630 (part1 ~file:"day1.txt" ())

let%test_unit "part2" =
  [%test_result: int] ~expect:54770 (part2 ~file:"day1.txt" ())
