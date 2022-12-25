open Core

let read_file problem_num ~test =
  (* TODO: figure out how to get relative path working  *)
  let root = "/Users/jake/Repos/puzzles/advent of code/2022" in
  let filename =
    if test then sprintf "%s/inputs/day%d-example.txt" root problem_num
    else sprintf "%s/inputs/day%d.txt" root problem_num
  in
  In_channel.read_all filename

let split s regex = Re2.split (Re2.create_exn regex) s
let isum l = List.reduce_exn l ~f:( + )
