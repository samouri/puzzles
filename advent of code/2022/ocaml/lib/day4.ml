open Core

let solve ~(file : string) =
  let input = Utils.read_lines file in
  let pairs =
    List.map input ~f:(fun line ->
        match Utils.extract_numbers line with
        | [ start1; end1; start2; end2 ] -> ((start1, end1), (start2, end2))
        | _ -> failwith (sprintf "unexpected input: %s" line))
  in
  let supersets ((start1, end1), (start2, end2)) =
    (start1 <= start2 && end2 <= end1) || (start2 <= start1 && end1 <= end2)
  in
  let overlaps ((start1, end1), (start2, end2)) =
    (start1 <= start2 && start2 <= end1) || (start2 <= start1 && start1 <= end2)
  in
  let part1 = List.count pairs ~f:supersets in
  let part2 = List.count pairs ~f:overlaps in
  (part1, part2)

let%test_unit _ = [%test_eq: int * int] (solve ~file:"day4-example.txt") (2, 4)
