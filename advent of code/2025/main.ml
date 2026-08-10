(*
 * Advent of Code 2025 Solutions. 
 *)

(*  Uncomment to use a generic datatype print function. 
 *
 *  print_endiline (Debug.to_string ( __POS_OF__ <any>))
 *)
(* #use "debug.ml" *)

module Utils = struct
  let read_file path =
    let ch = open_in_bin path in
    let s = really_input_string ch (in_channel_length ch) in
    close_in ch;
    s
  ;;

  let read_input day =
    let path = Printf.sprintf "./inputs/input_%d.txt" day in
    read_file path
  ;;

  let assert_int expected actual =
    if actual <> expected
    then failwith (Printf.sprintf "expected %d, got %d" expected actual)
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
    let was_invalid = ref false in
    for chunk_size = 1 to len / 2 do
      if len mod chunk_size = 0
      then (
        let all_same = ref true in
        let first_chunk = String.sub id 0 chunk_size in
        let chunk_count = len / chunk_size in
        for chunk_index = 1 to chunk_count - 1 do
          let offset = chunk_index * chunk_size in
          let this_chunk = String.sub id offset chunk_size in
          all_same := !all_same && this_chunk = first_chunk
        done;
        was_invalid := !was_invalid || !all_same)
    done;
    !was_invalid
  ;;

  let is_invalid_part_2'' id =
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
    let product_id_ranges = parse input in
    let invalid_ids =
      let all_product_ids =
        List.map
          (fun (start, end_) ->
            List.init (end_ - start + 1) (fun i -> start + i |> string_of_int))
          product_id_ranges
        |> List.flatten
      in
      List.filter is_invalid all_product_ids |> List.map (fun str -> int_of_string str)
    in
    List.fold_left ( + ) 0 invalid_ids
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

  let part1 input =
    let dial = ref 50 in
    let rotations = parse input in
    let sum_0 = ref 0 in
    List.iter
      (fun r ->
        dial := rotate !dial r;
        if !dial = 0 then incr sum_0)
      rotations;
    print_int !sum_0
  ;;

  let part2 input =
    let dial = ref 50 in
    let rotations = parse input in
    let sum = ref 0 in
    List.iter
      (fun r ->
        sum := !sum + times_crosses_0 !dial r;
        dial := rotate !dial r)
      rotations;
    print_int !sum
  ;;
end

let () = Two.part2 ()
