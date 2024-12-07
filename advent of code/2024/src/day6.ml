open! Core

module Direction = struct
  type t = Up | Down | Left | Right [@@deriving sexp, hash, compare]

  let parse = function
    | '^' -> Some Up
    | '>' -> Some Right
    | '<' -> Some Left
    | _ -> None

  let turn = function Up -> Right | Right -> Down | Down -> Left | Left -> Up
end

module Position = struct
  module T = struct
    type t = { row : int; col : int } [@@deriving equal, hash, sexp, compare]

    let move t direction =
      match direction with
      | Direction.Up -> { t with row = t.row - 1 }
      | Down -> { t with row = t.row + 1 }
      | Left -> { t with col = t.col - 1 }
      | Right -> { t with col = t.col + 1 }
  end

  include Core.Hashable.Make (T)
  include Core.Comparable.Make (T)
  include T
end

module Guard = struct
  module T = struct
    type t = { position : Position.t; direction : Direction.t }
    [@@deriving sexp, compare, hash]
  end

  include T
  include Core.Hashable.Make (T)

  let is_in_grid t grid =
    let ({ row; col } : Position.t) = t.position in
    row >= 0
    && row < Array.length grid
    && col >= 0
    && col < Array.length grid.(0)

  let step t grid =
    let candidate_position = Position.move t.position t.direction in
    let candidate = { t with position = candidate_position } in
    if is_in_grid candidate grid then
      let char_at_spot =
        grid.(candidate.position.row).(candidate.position.col)
      in
      if Char.equal char_at_spot '#' then
        { t with direction = Direction.turn t.direction }
      else candidate
    else candidate
end

let parse_input puzzle_input =
  let grid_area =
    String.split_lines puzzle_input
    |> List.to_array
    |> Array.map ~f:String.to_array
  in
  let guard : Guard.t =
    Array.find_mapi_exn grid_area ~f:(fun row_i row ->
        Array.find_mapi row ~f:(fun col_i cell ->
            let%map.Option direction = Direction.parse cell in
            let position = { Position.row = row_i; col = col_i } in
            { Guard.position; direction }))
  in
  (grid_area, guard)

let part1 (puzzle_input : string) =
  let grid, guard = parse_input puzzle_input in
  let guard = ref guard in
  let seen = Position.Hash_set.create () in
  while Guard.is_in_grid !guard grid do
    Hash_set.add seen !guard.position;
    guard := Guard.step !guard grid
  done;
  Hash_set.length seen

let part2 (puzzle_input : string) =
  let grid, guard = parse_input puzzle_input in
  let indices =
    Array.concat_mapi grid ~f:(fun row_i row ->
        Array.mapi row ~f:(fun col_i _ -> (row_i, col_i)))
    |> Array.filter ~f:(fun (row, col) ->
           (* Filter out the guard's current position and any existing obstacle indices *)
           let pos : Position.t = { row; col } in
           (not (Position.equal pos guard.position))
           && not (Char.equal grid.(row).(col) '#'))
  in
  Array.count indices ~f:(fun (row, col) ->
      let grid = Array.copy (Array.map grid ~f:Array.copy) in
      grid.(row).(col) <- '#';
      let seen = Guard.Hash_set.of_list [ guard ] in
      let cycled = ref false in
      let guard = ref guard in
      while Guard.is_in_grid !guard grid && not !cycled do
        Hash_set.add seen !guard;
        guard := Guard.step !guard grid;
        if Hash_set.mem seen !guard then cycled := true
      done;
      Hash_set.mem seen !guard)

let example_input = Utils.read_file "../inputs/day6-example.txt"
let real_input = Utils.read_file "../inputs/day6-input.txt"

let%expect_test "Part 1: Example input" =
  let result = part1 example_input in
  [%test_result: int] result ~expect:41

let%expect_test "Part 1: Real input" =
  let result = part1 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 5329 |}]

let%expect_test "Part 2: Example input" =
  let result = part2 example_input in
  [%test_result: int] result ~expect:6

let%expect_test "Part 2: Real input" =
  let result = part2 real_input in
  Out_channel.print_endline (Int.to_string result);
  [%expect {| 2162 |}]
