open! Core

(* Composition infix operator *)
let ( >> ) f g x = g (f x)

module Utils = struct
  let read_file path = In_channel.read_all path |> String.strip

  let extract_numbers str =
    Re2.find_all_exn (Re2.create_exn "\\d+") str |> List.map ~f:Int.of_string

  let head_and_tl_exn lst = (List.hd_exn lst, List.tl_exn lst)

  let time f =
    let start_time = Time_ns.now () in
    let result = f () in
    let end_time = Time_ns.now () in
    let runtime = Time_ns.diff end_time start_time in
    print_s [%message (runtime : Time_ns.Span.t)];
    result
end
