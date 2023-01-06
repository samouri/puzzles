open Core

let print_answer (part1, part2) =
  print_endline "\n\nSolution:\n------------";
  print_endline (sprintf "Part 1: %s" part1);
  print_endline (sprintf "Part 2: %s" part2)
;;

print_answer (Lib.Day5.solve ~file:"day5.txt")
