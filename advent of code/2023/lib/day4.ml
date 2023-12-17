open! Core

let update_exn map ~f =
  Hashtbl.update map ~f:(function None -> failwith "ahhhhh" | Some v -> f v)

let part1 ?(file = "day4.txt") () =
  let lines = Utils.read_lines file in
  let score_line line =
    let winning, mine =
      String.lsplit2_exn line ~on:':'
      |> snd |> String.lsplit2_exn ~on:'|'
      |> Tuple2.map ~f:Utils.extract_numbers
      |> Tuple2.map ~f:Int.Set.of_list
    in
    let same_count = Set.inter winning mine |> Set.length in
    if same_count = 0 then 0 else Int.pow 2 (same_count - 1)
  in
  List.sum (module Int) lines ~f:score_line

let part2 ?(file = "day4.txt") () =
  let module Int_hashtbl = Hashtbl.Make (Int) in
  let lines = Utils.read_lines file in
  let counts =
    List.range 0 (List.length lines)
    |> List.mapi ~f:(fun i _ -> (i, 1))
    |> Int_hashtbl.of_alist_exn
  in
  let process_line line =
    let winning, mine =
      String.lsplit2_exn line ~on:':'
      |> snd |> String.lsplit2_exn ~on:'|'
      |> Tuple2.map ~f:Utils.extract_numbers
      |> Tuple2.map ~f:Int.Set.of_list
    in
    Set.inter winning mine |> Set.length
  in
  List.iteri lines ~f:(fun key line ->
      let winners = process_line line in
      for i = key + 1 to key + winners do
        update_exn counts i ~f:(fun v ->
            let current_line_count = Hashtbl.find_exn counts key in
            v + current_line_count)
      done);
  List.sum (module Int) (Hashtbl.to_alist counts) ~f:snd

let%test_unit "part1-example" =
  [%test_result: int] (part1 ~file:"day4-example.txt" ()) ~expect:13

let%test_unit "part1" = [%test_result: int] (part1 ()) ~expect:25183

let%test_unit "part2-example" =
  [%test_result: int] (part2 ~file:"day4-example.txt" ()) ~expect:30

let%test_unit "part2" = [%test_result: int] (part2 ()) ~expect:5667240
