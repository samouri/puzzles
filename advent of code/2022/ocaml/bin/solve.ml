open Core

let solvers : (int, (module Lib.Solution.S)) List.Assoc.t = [
  1, (module Lib.Day1);
  2, (module Lib.Day2);
  3, (module Lib.Day3)
]

let print_solution (module M : Lib.Solution.S) =
  let (part1, part2) =  M.solve () in

  print_endline "Solution:\n------------";
  print_endline [%string "Part 1: %{part1#M}"];
  print_endline [%string "Part 1: %{part2#M}"];
;;

let problem = (Sys.get_argv ()).(1) |> Int.of_string in
let solver = (List.Assoc.find solvers ~equal:Int.equal problem) in

match solver with
  | Some solver -> print_solution solver
  | None -> print_endline [%string "Invalid input: %{problem#Int}"]
;

(* const solutions = { *)
(*      6: [7, 19], *)
(*      7: [95437, 24933642], *)
(*      8: [21, 8], *)
(*      9: [88, 36], *)
(*      10: [13140, 0], *)
(*      11: [10605, 2713310158], *)
(*      12: [31, 29], *)
(*      13: [13, 140], *)
(*      14: [24, 0], *)
(*      15: [0, 0], *)
(*      16: [0, 0], *)
(*      17: [0, 0], *)
(*      18: [0, 0], *)
(* } *)
