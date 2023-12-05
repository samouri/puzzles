open Core

let is_uniq (s : string) =
  let str_len = String.length s in
  let set_len = String.to_list s |> Char.Set.of_list |> Set.length in
  str_len = set_len

let find_uniq_slice_exn (s : string) (len : int) =
  String.findi s ~f:(fun i _ -> String.slice s i (i + len) |> is_uniq)
  |> Option.value_exn |> Tuple2.get1

let solve ~(file : string) =
  let input = Utils.read_file file in
  let part1 = 4 + find_uniq_slice_exn input 4 in
  let part2 = 14 + find_uniq_slice_exn input 14 in
  (part1, part2)

let%test_unit _ = [%test_eq: int * int] (solve ~file:"day6-example.txt") (7, 19)
