open Core

type dir = { parent : dir option; mutable children : fs_entry list }
[@@deriving sexp]

and fs_entry = File of string * int | Dir of string * dir [@@deriving sexp]

let parse_input input : fs_entry =
  (* Skip first line since its always cd / *)
  let input = List.tl_exn input in
  let root : dir = { parent = None; children = [] } in
  let cwd : dir ref = ref root in
  List.iter input ~f:(fun line ->
      let split = String.split ~on:' ' line in
      match split with
      | [ "$"; "cd"; ".." ] -> cwd := !cwd.parent |> Option.value_exn
      | [ "$"; "cd"; dir ] -> (
          let child =
            List.find_exn !cwd.children ~f:(function
              | File _ -> false
              | Dir (name, _) -> String.equal name dir)
          in
          match child with
          | Dir (_name, d) -> cwd := d
          | _ -> failwith [%string "Invalid line: %{line}"])
      | [ "$"; "ls" ] -> ()
      | [ "dir"; dirname ] ->
          !cwd.children <-
            Dir (dirname, { parent = Some !cwd; children = [] })
            :: !cwd.children
      | [ size; filename ] ->
          let size = Int.of_string size in
          !cwd.children <- File (filename, size) :: !cwd.children
      | _ -> failwith [%string "Invalid line: %{line}"]);
  Dir ("/", root)

let rec size = function
  | File (_, size) -> size
  | Dir (_, dir) -> List.sum (module Int) ~f:size dir.children

let rec alldirs = function
  | File _ -> []
  | Dir (_, { children; _ }) as dir ->
      dir :: List.concat_map children ~f:alldirs

let name = function File (name, _) | Dir (name, _) -> name

let rec print_tree ?(depth = 0) tree =
  List.iter (List.range 0 depth) ~f:(fun _ -> print_string " ");
  match tree with
  | File (name, size) ->
      print_string "| ";
      print_endline [%string "%{name} %{size#Int}"]
  | Dir (name, dir) ->
      print_string "dir ";
      print_endline [%string "%{name}"];
      List.iter dir.children ~f:(print_tree ~depth:(depth + 1))

let solve ~(file : string) =
  let input = Utils.read_lines file |> parse_input in
  (* print_tree input; *)
  let part1 =
    alldirs input |> List.map ~f:size
    |> List.filter ~f:(fun size -> size < 100000)
    |> Utils.isum
  in
  let to_free = 30000000 - (70000000 - size input) in
  let part2 =
    alldirs input |> List.map ~f:size
    |> List.filter ~f:(fun size -> size >= to_free)
    |> List.min_elt ~compare:Int.compare
    |> Option.value_exn
  in
  (part1, part2)

let%test_unit _ =
  [%test_eq: int * int] (solve ~file:"day7-example.txt") (95437, 24933642)
