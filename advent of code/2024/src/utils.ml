open! Core

let read_file path = In_channel.read_all path |> String.strip

let extract_numbers str =
  Re2.find_all_exn (Re2.create_exn "\\d+") str |> List.map ~f:Int.of_string

let head_and_tl_exn lst = (List.hd_exn lst, List.tl_exn lst)
