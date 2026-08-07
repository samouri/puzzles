#use "debug.ml";;

(*
 * Advent of Code 2025 Solutions. 
 *)

module Utils = struct
  let read_file path = 
    let ch = open_in_bin path in
    let s = really_input_string ch (in_channel_length ch) in
    close_in ch;
    s
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

  let real = Utils.read_file "./inputs/input_1.txt"

  type rotation = Left of int | Right of int

  let print_rotation r = 
    let output = match r with
      | Left n -> "L" ^ string_of_int n
      | Right n -> "R" ^ string_of_int n in
    print_endline output

  let rotate init r = match r with
    | Left n -> 
        let new_val = (init - n) mod 100 in
        if new_val < 0 then 100 + new_val else new_val
    | Right n -> (init + n) mod 100;;

  let times_crosses_0 init r = match r with
    | Left n -> 
        let new_val = init - n in
        let pos_to_neg_edge = if init > 0 && new_val <= 0  then 1 else 0 in
        ((abs new_val) / 100) + pos_to_neg_edge
    | Right n -> (init + n) / 100;;

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

  let solve1 input = 
    let dial = ref 50 in
    let rotations = parse input in
    let sum_0 = ref 0 in
    List.iter (fun r -> 
        dial := rotate !dial r;
        if !dial = 0 then incr sum_0
      )
      rotations;
    print_int !sum_0

  let solve2 input = 
    let dial = ref 50 in
    let rotations = parse input in
    let sum = ref 0 in
    List.iter (fun r -> 
      sum := !sum + times_crosses_0 !dial r;
      dial := rotate !dial r;
      )
      rotations;
    print_int !sum
end

let () = One.solve2 One.example;;
