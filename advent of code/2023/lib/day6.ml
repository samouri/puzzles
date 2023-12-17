open! Core
module Search_pattern = String.Search_pattern
module Int_hashtbl = Hashtbl.Make (Int)

let score ~duration charge_time = charge_time * (duration - charge_time)

let ways_to_win race =
  let duration, distance = race in
  let ways = List.range 0 duration |> List.map ~f:(score ~duration) in
  List.count ways ~f:(Int.( < ) distance)

let part1 ~file () =
  let races =
    let lines = Utils.read_lines file in
    let times = List.nth_exn lines 0 |> Utils.extract_numbers in
    let distances = List.nth_exn lines 1 |> Utils.extract_numbers in
    List.zip_exn times distances
  in
  List.fold ~init:1 races ~f:(fun acc race -> acc * ways_to_win race)

let part2 ~file () =
  let race =
    let lines = Utils.read_lines file in
    let strip_whitespace s =
      Search_pattern.create " " |> Search_pattern.replace_all ~in_:s ~with_:""
    in
    let get_num s =
      s |> strip_whitespace |> Utils.extract_numbers |> List.hd_exn
    in
    let time = get_num (List.nth_exn lines 0) in
    let distance = get_num (List.nth_exn lines 1) in
    (time, distance)
  in
  ways_to_win race

let%test_unit "part1-example" =
  [%test_result: int] (part1 ~file:"day6-example.txt" ()) ~expect:288

let%test_unit "part1" =
  [%test_result: int] (part1 ~file:"day6.txt" ()) ~expect:449820

let%test_unit "part2-example" =
  [%test_result: int] (part2 ~file:"day6-example.txt" ()) ~expect:71503

let%test_unit "part2" =
  [%test_result: int] (part2 ~file:"day6.txt" ()) ~expect:42250895
