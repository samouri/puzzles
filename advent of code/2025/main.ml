(*
 * Advent of Code 2025 solutions.
 *
 * This file is intentionally a toplevel script, not a compilation unit.
 * Run it directly with:
 *
 *   ocaml main.ml
 *
 * Keeping it as a script makes each puzzle quick to run and leaves room for
 * toplevel-only experiments.  In particular, the [#use "debug.ml"] directive
 * below enables the generic structural printer:
 *
 *   print_endline (Debug.to_string (__POS_OF__ value))
 *
 * [#use] is a toplevel directive rather than ordinary [.ml] syntax, so tools
 * that treat this file as a compiled module may report it as a syntax error
 * while it is enabled.  That mismatch is expected; [ocaml main.ml] is the
 * intended execution environment.
 *)
#use "debug.ml"

#load "str.cma"

module Utils = struct
  let read_input day =
    let path = Printf.sprintf "./inputs/input_%d.txt" day in
    In_channel.with_open_bin path In_channel.input_all
  ;;

  let assert_int expected actual =
    if actual <> expected
    then failwith (Printf.sprintf "expected %d, got %d" expected actual)
  ;;
end

module Six = struct
  let example = {|
123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   +
    |}

  type operation =
    | Mult
    | Add

  let real = lazy (Utils.read_input 6)

  let parse_operation_line line =
    Str.split (Str.regexp {| +|}) line
    |> Array.of_list
    |> Array.map (function
      | "+" -> Add
      | "*" -> Mult
      | _ as str -> failwith ("Failed to parse operation: " ^ str))
  ;;

  let parse1 input =
    let lines = input |> String.trim |> String.split_on_char '\n' in
    let revved = List.rev lines in
    let lines, last_line = revved |> List.tl |> List.rev, List.hd revved in
    let numbers =
      lines
      |> List.map (fun line ->
        Str.split (Str.regexp {| +|}) line |> List.map int_of_string)
      |> List.to_seq
      |> Seq.map List.to_seq
      |> Seq.transpose
    in
    let operations = parse_operation_line last_line in
    numbers, operations
  ;;

  let parse2 input =
    let lines = input |> String.trim |> String.split_on_char '\n' in
    let revved = List.rev lines in
    let lines, last_line = revved |> List.tl |> List.rev, List.hd revved in
    let numbers =
      lines
      |> List.to_seq
      |> Seq.map String.to_seq
      |> Seq.transpose
      |> Seq.map String.of_seq
      |> Seq.map (fun s -> if String.trim s = "" then "\n" else s)
      |> List.of_seq
      |> String.concat " "
      |> String.split_on_char '\n'
      |> List.map (fun line -> Str.split (Str.regexp " +") line |> List.map int_of_string)
    in
    let operations = parse_operation_line last_line in
    numbers, operations
  ;;

  let resolve numbers ~operation =
    let perform_operation =
      match operation with
      | Add -> ( + )
      | Mult -> ( * )
    in
    List.fold_left perform_operation (List.hd numbers) (List.tl numbers)
  ;;

  let part1 () =
    let go input =
      let numbers, operations = parse1 input in
      numbers
      |> Seq.fold_lefti
           (fun acc i column ->
             let operation = operations.(i) in
             let column_result = resolve (List.of_seq column) ~operation in
             acc + column_result)
           0
    in
    let example_result = go example in
    Utils.assert_int 4277556 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 6 part 1: %d\n" real_result
  ;;

  let part2 () =
    let go input =
      let numbers, operations = parse2 input in
      numbers
      |> List.to_seq
      |> Seq.fold_lefti
           (fun acc i column ->
             let operation = operations.(i) in
             let column_result = resolve column ~operation in
             acc + column_result)
           0
    in
    let example_result = go example in
    Utils.assert_int 3263827 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 6 part 2: %d\n" real_result
  ;;
end

module Five = struct
  let example = {|
3-5
10-14
16-20
12-18

1
5
8
11
17
32
  |}

  let real = lazy (Utils.read_input 5)

  let parse input =
    let[@warning "-8"] [ ranges; ingredients ] =
      input |> String.trim |> Str.split (Str.regexp "\n\n")
    in
    let ranges =
      ranges
      |> String.split_on_char '\n'
      |> List.map (fun line ->
        let[@warning "-8"] [ start; end_ ] = String.split_on_char '-' line in
        int_of_string start, int_of_string end_)
    in
    let ingredients =
      ingredients |> String.split_on_char '\n' |> List.map int_of_string
    in
    ranges, ingredients
  ;;

  let is_in_range (start, end_) n = start <= n && n <= end_

  let ranges_overlap (start1, end1) (start2, end2) =
    (* Four cases
       1. Overlaps left edge
       2. Overlaps right edge
       3. Fully surrounds
       4. Fully surrounded by
    *)
    let overlaps_left_edge = start1 <= start2 && start2 <= end1 in
    let overlaps_right_edge = start1 <= end2 && end2 <= end1 in
    let fully_surrounds = start1 <= start2 && end2 <= end1 in
    let fully_surrounded_by = start2 <= start1 && start1 <= end2 in
    overlaps_left_edge || overlaps_right_edge || fully_surrounds || fully_surrounded_by
  ;;

  (* Only valid for known overlapping ranges *)
  let combine_range (start1, end1) (start2, end2) = min start1 start2, max end1 end2

  (* Currently performing an O(n) scan through all the ranges. A segment tree
     would be O(lg n). But I feel confident there is an even better way. *)
  let part1 () =
    let go input =
      let ranges, ingredients = parse input in
      List.fold_left
        (fun sum ingredient ->
          let is_fresh = List.exists (fun range -> is_in_range range ingredient) ranges in
          if is_fresh then sum + 1 else sum)
        0
        ingredients
    in
    let example_result = go example in
    Utils.assert_int 3 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 5 part 1: %d\n" real_result
  ;;

  (* given a list of ranges, simplify until it cannot be simplifed anymore.*)
  let rec simplify ranges =
    let simplified_ranges =
      List.fold_left
        (fun acc range ->
          let overlaps = ranges_overlap range in
          let overlapping_ranges = List.filter overlaps acc in
          let non_overlapping_ranges = List.filter (Fun.negate overlaps) acc in
          let simplified_overlap =
            List.fold_left combine_range range overlapping_ranges
          in
          simplified_overlap :: non_overlapping_ranges)
        []
        ranges
    in
    if List.length simplified_ranges = List.length ranges
    then simplified_ranges
    else simplify simplified_ranges
  ;;

  let part2 () =
    let go input =
      let ranges, _ingredients = parse input in
      let ranges = simplify ranges in
      List.fold_left (fun sum (start, end_) -> sum + (end_ - start + 1)) 0 ranges
    in
    let example_result = go example in
    Utils.assert_int 14 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 5 part 2: %d\n" real_result
  ;;
end

module Four = struct
  let example =
    {|
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
  |}
  ;;

  let explode s = Array.init (String.length s) (String.get s)
  let real = lazy (Utils.read_input 4)

  let parse input =
    input
    |> String.trim
    |> String.split_on_char '\n'
    |> Array.of_list
    |> Array.map explode
  ;;

  let directions =
    [
      (-1,-1); (0,-1); (1,-1);
      (-1, 0);         (1, 0);
      (-1, 1); (0, 1); (1, 1);
    ] [@ocamlformat "disable"]
  ;;

  let is_valid (x, y) (max_x, max_y) = 0 <= x && x < max_x && 0 <= y && y < max_y

  let paper_neighbors grid (x, y) =
    let bounds = Array.length grid.(0), Array.length grid in
    List.fold_left
      (fun sum (dx, dy) ->
        let in_bounds = is_valid (x + dx, y + dy) bounds in
        if in_bounds && grid.(x + dx).(y + dy) = '@' then sum + 1 else sum)
      0
      directions
  ;;

  let part1 () =
    let go input =
      let grid = parse input in
      let row_count, col_count = Array.length grid.(0), Array.length grid in
      let indices =
        Seq.init row_count (fun x -> Seq.init col_count (fun y -> x, y))
        |> Seq.flat_map Fun.id
      in
      Seq.fold_left
        (fun sum (row_i, col_i) ->
          let marked = paper_neighbors grid (row_i, col_i) in
          let is_paper = grid.(row_i).(col_i) = '@' in
          if is_paper && marked < 4 then sum + 1 else sum)
        0
        indices
    in
    let example_result = go example in
    Utils.assert_int 13 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 4 part 1: %d\n" real_result
  ;;

  let part2 () =
    let go input =
      let grid = parse input in
      let row_count, col_count = Array.length grid.(0), Array.length grid in
      let removed = ref 0 in
      let can_remove = ref true in
      while !can_remove do
        let indices =
          Seq.init row_count (fun x -> Seq.init col_count (fun y -> x, y))
          |> Seq.flat_map Fun.id
        in
        let accessible =
          Seq.fold_left
            (fun acc (row_i, col_i) ->
              let marked = paper_neighbors grid (row_i, col_i) in
              let is_paper = grid.(row_i).(col_i) = '@' in
              if is_paper && marked < 4 then (row_i, col_i) :: acc else acc)
            []
            indices
        in
        removed := !removed + List.length accessible;
        can_remove := List.length accessible > 0;
        (* Now update the grid for next round *)
        List.iter (fun (row_i, col_i) -> grid.(row_i).(col_i) <- '.') accessible
      done;
      !removed
    in
    let example_result = go example in
    Utils.assert_int 43 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 4 part 1: %d\n" real_result
  ;;
end

module Three = struct
  let example = {|
987654321111111
811111111111119
234234234234278
818181911112111
  |}

  let real = lazy (Utils.read_input 3)
  let parse input = input |> String.trim |> String.split_on_char '\n'

  let max_joltage bank ~count =
    let len = String.length bank in
    let rec choose ~start ~remaining selected =
      if remaining = 0
      then selected |> List.rev |> List.to_seq |> String.of_seq |> int_of_string
      else (
        let final_candidate = len - remaining in
        let best_idx = ref start in
        for i = start + 1 to final_candidate do
          if bank.[i] > bank.[!best_idx] then best_idx := i
        done;
        choose
          ~start:(!best_idx + 1)
          ~remaining:(remaining - 1)
          (bank.[!best_idx] :: selected))
    in
    choose ~start:0 ~remaining:count []
  ;;

  let part1 () =
    let go input =
      let banks = parse input in
      let max_joltages = banks |> List.map (max_joltage ~count:2) in
      (* print_endline (Debug.to_string (__POS_OF__ max_joltages)); *)
      let sum = max_joltages |> List.fold_left ( + ) 0 in
      sum
    in
    let example_result = go example in
    Utils.assert_int 357 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 3 part 1: %d\n" real_result
  ;;

  let part2 () =
    let go input =
      let banks = parse input in
      let max_joltages = banks |> List.map (max_joltage ~count:12) in
      (* print_endline (Debug.to_string (__POS_OF__ max_joltages)); *)
      let sum = max_joltages |> List.fold_left ( + ) 0 in
      sum
    in
    let example_result = go example in
    Utils.assert_int 3121910778619 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 3 part 2: %d\n" real_result
  ;;
end

module Two = struct
  let example =
    {|11-22,95-115,998-1012,1188511880-1188511890,222220-222224,
1698522-1698528,446443-446449,38593856-38593862,565653-565659,
824824821-824824827,2121212118-2121212124|}
    |> String.split_on_char '\n'
    |> String.concat ""
  ;;

  let parse input =
    input
    |> String.trim
    |> String.split_on_char ','
    |> List.map (fun s ->
      let[@warning "-8"] [ start; end_ ] = String.split_on_char '-' s in
      int_of_string start, int_of_string end_)
  ;;

  let is_invalid_part_1 id =
    let len = String.length id in
    let first_half = String.sub id 0 (len / 2) in
    let second_half = String.sub id (len / 2) ((len / 2) + (len mod 2)) in
    first_half = second_half
  ;;

  let is_invalid_part_2 id =
    let len = String.length id in
    let repeats_in_chunks size =
      let first = String.sub id 0 size in
      Seq.init ((len / size) - 1) (fun i -> String.sub id ((i + 1) * size) size)
      |> Seq.for_all (String.equal first)
    in
    Seq.init (len / 2) (fun i -> i + 1)
    |> Seq.filter (fun chunk_size -> len mod chunk_size = 0)
    |> Seq.exists repeats_in_chunks
  ;;

  let real = lazy (Utils.read_input 2)

  let sum_invalid_ids input ~is_invalid =
    parse input
    |> List.to_seq
    |> Seq.flat_map (fun (start, end_) ->
      Seq.init (end_ - start + 1) (fun offset -> start + offset))
    |> Seq.filter (fun id -> is_invalid (string_of_int id))
    |> Seq.fold_left ( + ) 0
  ;;

  let part1 () =
    let go input = sum_invalid_ids input ~is_invalid:is_invalid_part_1 in
    let example_result = go example in
    Utils.assert_int 1227775554 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 2 part 1: %d\n" real_result
  ;;

  let part2 () =
    let go input = sum_invalid_ids input ~is_invalid:is_invalid_part_2 in
    let example_result = go example in
    Utils.assert_int 4174379265 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 2 part 2: %d\n" real_result
  ;;
end

module One = struct
  let example = {|
L68
L30
R48
L5
R60
L55
L1
L99
R14
L82
  |}

  let real = lazy (Utils.read_input 1)

  type rotation =
    | Left of int
    | Right of int

  let rotate init r =
    match r with
    | Left n ->
      let new_val = (init - n) mod 100 in
      if new_val < 0 then 100 + new_val else new_val
    | Right n -> (init + n) mod 100
  ;;

  let times_crosses_0 init r =
    match r with
    | Left n ->
      let new_val = init - n in
      let pos_to_neg_edge = if init > 0 && new_val <= 0 then 1 else 0 in
      (abs new_val / 100) + pos_to_neg_edge
    | Right n -> (init + n) / 100
  ;;

  let parse input =
    let lines =
      String.split_on_char '\n' input
      |> List.map String.trim
      |> List.filter (fun s -> not (String.equal s ""))
    in
    let parse_line line =
      let dir_char = String.get line 0 in
      let amt = int_of_string (String.sub line 1 (String.length line - 1)) in
      match dir_char with
      | 'L' -> Left amt
      | 'R' -> Right amt
      | _ -> failwith "unexpected direction"
    in
    List.map parse_line lines
  ;;

  let part1 () =
    let go input =
      let rotations = parse input in
      let _, sum_0 =
        List.fold_left
          (fun (dial, sum_0) rotation ->
            let dial = rotate dial rotation in
            let sum_0 = if dial = 0 then sum_0 + 1 else sum_0 in
            dial, sum_0)
          (50, 0)
          rotations
      in
      sum_0
    in
    let example_result = go example in
    Utils.assert_int 3 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 1 part 1: %d\n" real_result
  ;;

  let part2 () =
    let go input =
      let rotations = parse input in
      let _, sum =
        List.fold_left
          (fun (dial, sum) rotation ->
            let sum = sum + times_crosses_0 dial rotation in
            rotate dial rotation, sum)
          (50, 0)
          rotations
      in
      sum
    in
    let example_result = go example in
    Utils.assert_int 6 example_result;
    let real_result = go (Lazy.force real) in
    Printf.printf "Day 1 part 2: %d\n" real_result
  ;;
end

let () = Six.part2 ()
