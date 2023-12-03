open! Core

module Color = struct
  type t = Red | Green | Blue

  let to_string = function Red -> "red" | Green -> "green" | Blue -> "blue"
end

let get_game_num str =
  let regex = Re2.create_exn {|Game (\d+)|} in
  Re2.find_submatches_exn regex str
  |> Array.last |> Option.value_exn |> Int.of_string

let count_color ~str color =
  let matches =
    let color_str = Color.to_string color in
    Re2.find_submatches (Re2.create_exn ({|(\d+) |} ^ color_str)) str
  in
  match matches with
  | Error _ -> 0
  | Ok matches ->
      matches |> Array.last |> Option.value ~default:"0" |> Int.of_string

let count_rgb str =
  (count_color ~str Red, count_color ~str Green, count_color ~str Blue)

let part1 ?(file = "day2.txt") () =
  let lines = Utils.read_lines file in
  let passing_games =
    List.filter lines ~f:(fun line ->
        let rounds = String.split line ~on:';' in
        let reds, greens, blues = List.map rounds ~f:count_rgb |> List.unzip3 in
        let max ints =
          List.max_elt ints ~compare:Int.compare |> Option.value_exn
        in
        max reds <= 12 && max greens <= 13 && max blues <= 14)
  in
  List.sum (module Int) passing_games ~f:get_game_num

let part2 ?(file = "day2.txt") () =
  let lines = Utils.read_lines file in
  let passing_games =
    List.map lines ~f:(fun line ->
        let rounds = String.split line ~on:';' in
        let reds, greens, blues = List.map rounds ~f:count_rgb |> List.unzip3 in
        let max ints =
          List.max_elt ints ~compare:Int.compare |> Option.value_exn
        in
        max reds * max greens * max blues)
  in
  List.sum (module Int) passing_games ~f:Fn.id

let%test_unit "part1-example" =
  [%test_eq: int] (part1 ~file:"day2-example.txt" ()) 8

let%test_unit "part2-example" =
  [%test_eq: int] (part2 ~file:"day2-example.txt" ()) 2286

let%test_unit "part1" = [%test_eq: int] (part1 ~file:"day2.txt" ()) 2256
let%test_unit "part2" = [%test_eq: int] (part2 ~file:"day2.txt" ()) 74229
