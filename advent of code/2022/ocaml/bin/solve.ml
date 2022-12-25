open Core

let print_answer (part1, part2) =
  print_endline "\n\nSolution:\n------------";
  print_endline (sprintf "Part 1: %d" part1);
  print_endline (sprintf "Part 2: %d" part2)
;;

print_answer (Lib.Day2.solve false)
