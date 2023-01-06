open Core

let read_lines file =
  (* TODO: figure out how to get relative path working  *)
  let root = "/Users/jake/Repos/puzzles/advent of code/2022/inputs/" in
  let filename = sprintf "%s/%s" root file in
  In_channel.read_lines filename

let read_file file = read_lines file |> String.concat ~sep:"\n"
let split s regex = Re2.split (Re2.create_exn regex) s
let isum l = List.reduce_exn l ~f:( + )

let extract_numbers str =
  Re2.find_all_exn (Re2.create_exn "\\d+") str |> List.map ~f:Int.of_string
