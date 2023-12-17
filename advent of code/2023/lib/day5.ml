open! Core
module Search_pattern = String.Search_pattern
module Int_hashtbl = Hashtbl.Make (Int)

let parse_triple line =
  match Utils.extract_numbers line with
  | [ one; two; three ] -> (one, two, three)
  | _ -> failwith [%string "bad line %{line}"]

let part1 ~file () =
  let all_sections =
    let double_newline = Search_pattern.create "\n\n" in
    file |> Utils.read_file |> Search_pattern.split_on double_newline
  in
  let initial_seeds = List.hd_exn all_sections |> Utils.extract_numbers in
  let map_sections =
    List.tl_exn all_sections
    |> List.map ~f:(fun line ->
           line |> String.split_lines |> List.tl_exn |> List.map ~f:parse_triple)
  in
  let maps =
    List.map map_sections ~f:(fun lines ->
        let get_range x =
          List.find_map lines ~f:(fun (dst, src, len) ->
              if src <= x && x <= src + len then Some (dst + (x - src))
              else None)
        in
        get_range)
  in
  let locations =
    List.map initial_seeds ~f:(fun seed ->
        List.fold maps ~init:seed ~f:(fun acc fn ->
            fn acc |> Option.value ~default:acc))
  in
  List.min_elt ~compare:Int.compare locations |> Option.value_exn

let part2 ~file () =
  let all_sections =
    let double_newline = Search_pattern.create "\n\n" in
    file |> Utils.read_file |> Search_pattern.split_on double_newline
  in
  let seed_ranges =
    List.hd_exn all_sections |> Utils.extract_numbers
    |> List.chunks_of ~length:2
    |> List.map ~f:(fun l -> (List.hd_exn l, l |> List.tl_exn |> List.hd_exn))
    |> List.sort ~compare:(fun a b -> Int.compare (fst a) (snd b))
  in
  let is_seed x =
    List.exists seed_ranges ~f:(fun (start, len) ->
        start <= x && x <= start + len)
  in

  let map_sections =
    List.tl_exn all_sections
    |> List.map ~f:(fun line ->
           line |> String.split_lines |> List.tl_exn |> List.map ~f:parse_triple)
  in
  let maps =
    List.map map_sections ~f:(fun lines ->
        let get_range x =
          List.find_map lines ~f:(fun (dst, src, len) ->
              if dst <= x && x <= dst + len then Some (src + (x - dst))
              else None)
        in
        fun x -> get_range x |> Option.value ~default:x)
    |> List.rev
  in
  let rev_convert x = List.fold ~init:x ~f:(fun acc fn -> fn acc) maps in
  (* Retrieved upper_bound via part 1 *)
  let lower_bound = 0 in
  let upper_bound = 309796150 in

  let i = ref (lower_bound - 1) in
  let found = ref false in
  while !i < upper_bound && not !found do
    i := !i + 1;
    let rev_seed = rev_convert !i in
    if is_seed rev_seed then found := true
  done;
  !i

let%test_unit "part1-example" =
  [%test_result: int] (part1 ~file:"day5-example.txt" ()) ~expect:35

let%test_unit "part1" =
  [%test_result: int] (part1 ~file:"day5.txt" ()) ~expect:309796150

let%test_unit "part2-example" =
  [%test_result: int] (part2 ~file:"day5-example.txt" ()) ~expect:46

(*  Part 2 is wrong rn. *)
let%test_unit "part2" =
  [%test_result: int] (part2 ~file:"day5.txt" ()) ~expect:50716417
