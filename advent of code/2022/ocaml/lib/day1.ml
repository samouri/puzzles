open Core

let solve file =
  let input = Utils.read_file file in
  let elves = Utils.split input "\n\n" |> List.map ~f:String.split_lines in
  let elf_sums =
    List.map elves ~f:(List.sum (module Int) ~f:Int.of_string)
    |> List.sort ~compare:Int.descending
  in
  let part1 = List.hd_exn elf_sums in
  let part2 = List.take elf_sums 3 |> Utils.isum in
  (part1, part2)

let%test_unit "Day one" =
  [%test_eq: int * int] (solve "day1-example.txt") (24000, 45000)
