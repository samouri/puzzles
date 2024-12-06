open! Core

let parse_puzzle_input puzzle_input =
  let page_ordering_str, updates_str =
    let parts =
      String.Search_pattern.split_on
        (String.Search_pattern.create "\n\n")
        puzzle_input
    in
    (List.hd_exn parts, List.nth_exn parts 1)
  in
  (* Keys must appear before all of thier associated values *)
  let page_ordering =
    page_ordering_str |> String.split_lines
    |> List.map ~f:(fun order_rule ->
           String.lsplit2_exn order_rule ~on:'|' |> Tuple2.map ~f:Int.of_string)
    |> List.fold ~init:Int.Map.empty ~f:(fun acc (before_int, after_int) ->
           Map.add_multi acc ~key:before_int ~data:after_int)
  in
  let updates =
    updates_str |> String.split_lines
    |> List.map ~f:(fun update_str ->
           String.split ~on:',' update_str |> List.map ~f:Int.of_string)
  in
  (page_ordering, updates)

let first_out_of_order_num ~page_ordering update =
  let seen = Int.Hash_set.create () in
  List.find update ~f:(fun num ->
      Hash_set.add seen num;
      let cannot_have_seen =
        Map.find page_ordering num |> Option.value ~default:[]
      in
      List.exists cannot_have_seen ~f:(Hash_set.mem seen))

let is_ordered ~page_ordering update =
  first_out_of_order_num ~page_ordering update |> Option.is_none

let sum_middles int_list =
  let middle l = List.nth_exn l (List.length l / 2) in
  List.sum (module Int) int_list ~f:middle

let part1 (puzzle_input : string) =
  let page_ordering, updates = parse_puzzle_input puzzle_input in
  let ordered_updates = List.filter updates ~f:(is_ordered ~page_ordering) in
  sum_middles ordered_updates

let part2 (puzzle_input : string) =
  let page_ordering, updates = parse_puzzle_input puzzle_input in
  let unordered_updates =
    List.filter updates ~f:(fun update ->
        not (is_ordered ~page_ordering update))
  in
  (* bubble sort ftw *)
  let rec move_back lst num =
    match lst with
    | [] -> []
    | [ hd ] -> [ hd ]
    | hd :: mid :: tl ->
        if mid = num then mid :: hd :: tl else hd :: move_back (mid :: tl) num
  in
  let reordered_updates =
    let%map.List update = unordered_updates in
    let ordered_update = ref update in
    while
      Option.is_some (first_out_of_order_num ~page_ordering !ordered_update)
    do
      ordered_update :=
        move_back !ordered_update
          (first_out_of_order_num ~page_ordering !ordered_update
          |> Option.value_exn)
    done;
    !ordered_update
  in
  sum_middles reordered_updates

let example_input = Utils.read_file "../inputs/day5-example.txt"
let real_input = Utils.read_file "../inputs/day5-input.txt"

let%expect_test "Part 1: Example input" =
  let result = part1 example_input in
  [%test_result: int] result ~expect:143

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 4774 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input in
  [%test_result: int] result ~expect:123

let%expect_test "Part 2: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 6004 |}]
