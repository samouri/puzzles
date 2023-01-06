open Core

let solve ~(file:string) =
  let input = Utils.read_file file |> String.split_lines in
  let score1 = function
    | "A Z" -> 3 | "B X" -> 1 | "C Y" -> 2 (* Losses *)
    | "A X" -> 4 | "B Y" -> 5 | "C Z" -> 6 (* Ties *)
    | "A Y" -> 8 | "B Z" -> 9 | "C X" -> 7 (* Wins *)
    | _ -> failwith "impossible"
  in
  let score2 = function
    | "A Y" -> 4 | "B X" -> 1 | "C Z" -> 7
    | "A Z" -> 8 | "B Y" -> 5 | "C X" -> 2
    | "A X" -> 3 | "B Z" -> 9 | "C Y" -> 6
    | _ -> failwith "impossible"
  in
  let part1 = List.sum (module Int) ~f:score1 input in
  let part2 = List.sum (module Int) ~f:score2 input in
  (part1, part2)

let%test_unit _ = [%test_eq: int * int] (solve ~file:"day2-example.txt") (15, 12)
