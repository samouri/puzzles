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

let () = Four.part2 ()
