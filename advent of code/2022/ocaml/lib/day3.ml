open Core

type t = int

include Solution.Stringable_int

let intersect (chars : char list list) =
  let sets = List.map ~f:Char.Set.of_list chars in
  let intersection = List.reduce_exn ~f:Set.inter sets in
  Set.choose_exn intersection

let priority c =
  let code c = Char.to_int c in
  match c with
  | 'a' .. 'z' -> 1 + (code c - code 'a')
  | 'A' .. 'Z' -> 27 + (code c - code 'A')
  | _ -> assert false

let solve ?(file = "day3.txt") () =
  let input = Utils.read_lines file |> List.map ~f:String.to_list in
  let split_half line =
    let mid = List.length line / 2 in
    let first, second = List.split_n line mid in
    [ first; second ]
  in
  let part1 =
    List.sum
      (module Int)
      input
      ~f:(fun line -> split_half line |> intersect |> priority)
  in
  let part2 =
    List.chunks_of input ~length:3
    |> List.sum (module Int) ~f:(fun chunk -> chunk |> intersect |> priority)
  in
  (part1, part2)

let%test_unit _ =
  [%test_eq: int * int] (solve ~file:"day3-example.txt" ()) (157, 70)
