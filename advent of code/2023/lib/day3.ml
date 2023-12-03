open! Core

let is_symbol c = not (Char.is_digit c || Char.equal c '.')

module Point = struct
  module T = struct
    type t = int * int [@@deriving compare, hash, sexp]
  end

  include T
  include Hashable.Make (T)
end

let extract_numbers_with_indexes input_string =
  let pattern = Re2.create_exn "\\d+" in
  let rec helper index acc remaining_str =
    match Re2.first_match pattern remaining_str |> Or_error.ok with
    | None -> acc
    | Some match_result ->
        let match_str = Re2.Match.get_exn ~sub:(`Index 0) match_result in
        let start_idx, len =
          Re2.Match.get_pos_exn ~sub:(`Index 0) match_result
        in
        let end_idx = start_idx + len in
        helper (index + end_idx)
          ((index + start_idx, match_str) :: acc)
          (String.drop_prefix remaining_str end_idx)
  in
  List.rev (helper 0 [] input_string)

let get_adjacents ~line_i ~col_i ~len =
  let col_indexes = List.range (col_i - 1) (col_i + len + 1) in
  List.cartesian_product [ line_i - 1; line_i; line_i + 1 ] col_indexes

let part1 ?(file = "day3.txt") () =
  let lines = Utils.read_lines file in
  let symbol_locations =
    List.concat_mapi lines ~f:(fun line_i line ->
        let characters = String.to_list line in
        List.filter_mapi characters ~f:(fun col_i c ->
            if is_symbol c then Some (line_i, col_i) else None))
    |> Point.Hash_set.of_list
  in
  let part_numbers =
    List.concat_mapi lines ~f:(fun line_i line ->
        let nums = extract_numbers_with_indexes line in
        List.filter nums ~f:(fun (col_i, number) ->
            let len = String.length number in
            let adjacents = get_adjacents ~line_i ~col_i ~len in
            List.exists adjacents ~f:(Hash_set.mem symbol_locations)))
  in
  List.sum (module Int) part_numbers ~f:(fun (_, num) -> Int.of_string num)

let part2 ?(file = "day3.txt") () =
  let lines = Utils.read_lines file in
  let symbol_locations =
    List.concat_mapi lines ~f:(fun line_i line ->
        let characters = String.to_list line in
        List.filter_mapi characters ~f:(fun col_i c ->
            if is_symbol c then Some (line_i, col_i) else None))
    |> Point.Hash_set.of_list
  in
  let module Point_hashtbl = Hashtbl.Make (Point) in
  (* Hashtabl with key=point, value = unique key of part *)
  let part_number_locations = Point_hashtbl.create () in
  let () =
    List.iteri lines ~f:(fun line_i line ->
        let nums = extract_numbers_with_indexes line in
        let part_numbers =
          List.filter nums ~f:(fun (col_i, number) ->
              let adjacents =
                get_adjacents ~line_i ~col_i ~len:(String.length number)
              in
              List.exists adjacents ~f:(Hash_set.mem symbol_locations))
        in
        List.iter part_numbers ~f:(fun (col_i, number) ->
            (* For every char of the part, add it to the hashtbl *)
            List.range 0 (String.length number)
            |> List.iter ~f:(fun num_col_i ->
                   Hashtbl.add_exn part_number_locations
                     ~key:(line_i, col_i + num_col_i)
                     ~data:(line_i, col_i, number))))
  in
  let gear_ratios =
    List.mapi lines ~f:(fun line_i line ->
        let characters = String.to_list line in
        List.filter_mapi characters ~f:(fun col_i c ->
            match Char.equal '*' c with
            | false -> None
            | true -> (
                let adjacent_parts =
                  get_adjacents ~line_i ~col_i ~len:1
                  |> List.filter_map ~f:(Hashtbl.find part_number_locations)
                  |> List.dedup_and_sort ~compare:[%compare: int * int * string]
                in
                match adjacent_parts with
                | [ (_, _, num1); (_, _, num2) ] ->
                    Some (Int.of_string num1, Int.of_string num2)
                | _ -> None)))
  in
  List.sum (module Int) (List.concat gear_ratios) ~f:(fun (n1, n2) -> n1 * n2)

let%test_unit "part1-example" =
  [%test_result: int] (part1 ~file:"day3-example.txt" ()) ~expect:4361

let%test_unit "part2-example" =
  [%test_result: int] (part2 ~file:"day3-example.txt" ()) ~expect:467835

let%test_unit "part1" =
  [%test_result: int] (part1 ~file:"day3.txt" ()) ~expect:550934

let%test_unit "part2" =
  [%test_result: int] (part2 ~file:"day3.txt" ()) ~expect:81997870
