open! Core
module Search_pattern = String.Search_pattern
module Int_hashtbl = Hashtbl.Make (Int)

module Seed_range = struct
  type t = { start : int; len : int }

  let parse_singles ~file =
    Utils.read_lines file |> List.hd_exn |> Utils.extract_numbers
    |> List.map ~f:(fun start -> { start; len = 1 })
    |> List.sort ~compare:(fun a b -> Int.compare a.start b.start)

  let parse_ranges ~file =
    Utils.read_lines file |> List.hd_exn |> Utils.extract_numbers
    |> List.chunks_of ~length:2
    |> List.map ~f:(function
         | [ start; len ] -> { start; len }
         | _ -> failwith "bad line")
    |> List.sort ~compare:(fun a b -> Int.compare a.start b.start)
end

module Almanac = struct
  module Entry = struct
    type t = { src : int; dst : int; len : int }
  end

  type t = Entry.t list list

  let parse ~file =
    let double_newline = Search_pattern.create "\n\n" in
    file |> Utils.read_file
    |> Search_pattern.split_on double_newline
    |> List.tl_exn
    |> List.map ~f:(fun entries ->
           entries |> String.split_lines |> List.tl_exn
           |> List.map ~f:(fun entry_str ->
                  match Utils.extract_numbers entry_str with
                  | [ dst; src; len ] -> { Entry.src; dst; len }
                  | _ -> failwith "bad line"))

  let convert (t : t) seed =
    let convert_type (entries : Entry.t list) x =
      List.find_map entries ~f:(fun { dst; src; len } ->
          if src <= x && x < src + len then Some (dst + (x - src)) else None)
      |> Option.value ~default:x
    in
    List.fold t ~init:seed ~f:(fun acc entries -> convert_type entries acc)
end

let part1 ~file () =
  let almanac = Almanac.parse ~file in
  let seeds = Seed_range.parse_singles ~file in
  let locations =
    List.map seeds ~f:(fun seed -> Almanac.convert almanac seed.start)
  in
  List.min_elt ~compare:Int.compare locations |> Option.value_exn

let part2 ~file () =
  let almanac = Almanac.parse ~file in
  let seeds = Seed_range.parse_ranges ~file in
  let locations =
    List.concat_map seeds ~f:(fun seed_range ->
        let ({ start; len } : Seed_range.t) = seed_range in
        let locations = ref [] in
        let i = ref start in
        while !i < start + len do
          let location = Almanac.convert almanac !i in
          locations := location :: !locations;
          let step = 10000 in
          if
            !i + step <= start + len
            && Almanac.convert almanac (!i + step) = location + step
          then i := !i + step + 1
          else i := !i + 1
        done;
        !locations)
  in

  List.min_elt ~compare:Int.compare locations |> Option.value_exn

let%test_unit "part1-example" =
  [%test_result: int] (part1 ~file:"day5-example.txt" ()) ~expect:35

let%test_unit "part1" =
  [%test_result: int] (part1 ~file:"day5.txt" ()) ~expect:309796150

let%test_unit "part2-example" =
  [%test_result: int] (part2 ~file:"day5-example.txt" ()) ~expect:46

let%test_unit "part2" =
  [%test_result: int] (part2 ~file:"day5.txt" ()) ~expect:50716416
