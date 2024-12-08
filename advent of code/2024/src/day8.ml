open! Core
open! Import

let is_valid (row, col) ~grid =
  (0 <= row && row < Array.length grid)
  && 0 <= col
  && col < Array.length grid.(0)

let parse_grid puzzle_input =
  puzzle_input |> String.split_lines
  |> List.map ~f:(String.to_list >> List.to_array)
  |> List.to_array

let parse_input puzzle_input =
  let grid = parse_grid puzzle_input in
  let all_indices =
    Array.concat_mapi grid ~f:(fun row_i row ->
        Array.mapi row ~f:(fun col_i _ -> (row_i, col_i)))
  in
  let antennae_locations =
    Array.fold all_indices ~init:Char.Map.empty ~f:(fun acc (row, col) ->
        match grid.(row).(col) with
        | '.' -> acc
        | char -> Map.add_multi acc ~key:char ~data:(row, col))
  in
  (grid, antennae_locations)

let unique_pairs list ~equal =
  List.concat_map list ~f:(fun x ->
      List.filter_map list ~f:(fun y -> if equal x y then None else Some (x, y)))

let rec unfold_while ~init ~f ~while_ =
  let next = f (List.hd_exn init) in
  match while_ next with
  | false -> init
  | true -> unfold_while ~init:(next :: init) ~f ~while_

let part1 (puzzle_input : string) =
  let grid, antennae_locations = parse_input puzzle_input in
  let antinode_locations =
    Map.map antennae_locations ~f:(fun locations ->
        let pairs = unique_pairs locations ~equal:[%equal: int * int] in
        List.concat_map pairs ~f:(fun ((r1, c1), (r2, c2)) ->
            let offset_r1 = r1 - r2 in
            let offset_c1 = c1 - c2 in
            let antinode1 = (r1 + offset_r1, c1 + offset_c1) in
            let antinode2 = (r2 - offset_r1, c2 - offset_c1) in
            [ antinode1; antinode2 ]))
  in
  let antinodes_in_grid =
    antinode_locations |> Map.data |> List.concat
    |> List.filter ~f:(is_valid ~grid)
    |> List.dedup_and_sort ~compare:[%compare: int * int]
  in
  List.length antinodes_in_grid

let part2 (puzzle_input : string) =
  let grid, antennae_locations = parse_input puzzle_input in
  let antinode_locations_by_type =
    Map.map antennae_locations ~f:(fun locations ->
        let pairs = unique_pairs locations ~equal:[%equal: int * int] in
        List.concat_map pairs ~f:(fun ((r1, c1), (r2, c2)) ->
            let offset_r = r1 - r2 in
            let offset_c = c1 - c2 in
            unfold_while
              ~init:[ (r1, c1) ]
              ~f:(fun (r, c) -> (r + offset_r, c + offset_c))
              ~while_:(is_valid ~grid)))
  in
  let antinode_locations =
    antinode_locations_by_type |> Map.data |> List.concat
    |> List.dedup_and_sort ~compare:[%compare: int * int]
  in
  List.length antinode_locations

let example_input = Utils.read_file "../inputs/day8-example.txt"
let real_input = Utils.read_file "../inputs/day8-input.txt"

let%expect_test "Part 1: Example input" =
  let result = part1 example_input in
  [%test_result: int] result ~expect:14

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 278 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input in
  [%test_result: int] result ~expect:34

(* < 1ms *)
let%expect_test "Part 2: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 1067 |}]
