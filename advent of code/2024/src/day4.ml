open! Core

let parse_grid puzzle_input =
  puzzle_input |> String.split_lines
  |> List.map ~f:(Fn.compose List.to_array String.to_list)
  |> List.to_array

let is_valid ~grid row col =
  (0 <= row && row < Array.length grid)
  && 0 <= col
  && col < Array.length grid.(0)

let rec can_spell row col ~grid ~word ~direction =
  if not (is_valid ~grid row col) then false
  else
    let current_char = grid.(row).(col) in
    let char_needed, remaining = (List.hd_exn word, List.tl_exn word) in
    if not (Char.equal current_char char_needed) then false
    else if List.is_empty remaining then true
    else
      let row_offset, col_offset = direction in
      can_spell ~grid ~direction ~word:remaining (row + row_offset)
        (col + col_offset)

let part1 (puzzle_input : string) =
  let grid = parse_grid puzzle_input in
  let directions =
    [ (-1, 1); (0, 1); (1, 1); (-1, 0); (1, 0); (-1, -1); (0, -1); (1, -1) ]
  in
  let all_indices_and_directions =
    Array.concat_mapi grid ~f:(fun row_i row ->
        Array.mapi row ~f:(fun col_i _ -> (row_i, col_i)))
    |> List.of_array
    |> List.concat_map ~f:(fun (row, col) ->
           List.map directions ~f:(fun direction -> (row, col, direction)))
  in
  let xmas_indices =
    List.filter all_indices_and_directions ~f:(fun (row, col, direction) ->
        can_spell ~grid ~word:(String.to_list "XMAS") ~direction row col)
  in
  List.length xmas_indices

let part2 (puzzle_input : string) =
  let grid = parse_grid puzzle_input in
  let all_indices =
    Array.concat_mapi grid ~f:(fun row_i row ->
        Array.mapi row ~f:(fun col_i _ -> (row_i, col_i)))
    |> List.of_array
  in
  let good_indices =
    List.filter all_indices ~f:(fun (row, col) ->
        (can_spell ~grid row col ~word:(String.to_list "MAS") ~direction:(1, 1)
        || can_spell ~grid row col ~word:(String.to_list "SAM") ~direction:(1, 1)
        )
        && (can_spell ~grid row (col + 2) ~word:(String.to_list "MAS")
              ~direction:(1, -1)
           || can_spell ~grid row (col + 2) ~word:(String.to_list "SAM")
                ~direction:(1, -1)))
  in
  List.length good_indices

let example_input =
  {|
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
|}
  |> String.strip

let real_input = Utils.read_file "../inputs/day4-input.txt"

let%expect_test "Part 1: Example input" =
  let result = part1 example_input in
  [%test_result: int] result ~expect:18

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 2406 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input in
  [%test_result: int] result ~expect:9

let%expect_test "Part 2: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 1807 |}]
