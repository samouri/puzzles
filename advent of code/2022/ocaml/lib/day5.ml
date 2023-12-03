open Core

let solve ~(file : string) =
  let input = Utils.read_file file in
  let raw_initial_stacks, raw_procedures =
    Utils.split input "\n\n" |> Utils.tuple_exn
  in
  let stacks =
    raw_initial_stacks |> String.split_lines |> List.drop_last_exn
    |> List.map ~f:String.to_array
    |> List.to_array |> Array.transpose_exn
    |> Array.filteri ~f:(fun i _ -> i % 4 = 1)
    |> Array.map ~f:(Array.filter ~f:(fun c -> not (Char.is_whitespace c)))
    |> Array.map ~f:Array.to_list
  in
  let procedures =
    raw_procedures |> String.split_lines
    |> List.map ~f:Utils.extract_numbers
    |> List.map ~f:(function
         | [ num; src; dst ] -> (num, src, dst)
         | _ -> failwith (sprintf "Unexpected input"))
  in

  let stacks1, stacks2 = (Array.copy stacks, Array.copy stacks) in
  List.iter procedures ~f:(fun (num, src, dst) ->
      let src, dst = (src - 1, dst - 1) in
      let moved, new_src = List.split_n stacks1.(src) num in
      stacks1.(src) <- new_src;
      stacks1.(dst) <- List.rev moved @ stacks1.(dst);

      let moved, new_src = List.split_n stacks2.(src) num in
      stacks2.(src) <- new_src;
      stacks2.(dst) <- moved @ stacks2.(dst));

  let all_last stack =
    Array.map stack ~f:List.hd_exn |> Array.to_list |> String.of_char_list
  in
  let part1 = all_last stacks1 in
  let part2 = all_last stacks2 in
  (part1, part2)

let%test_unit _ =
  [%test_eq: string * string] (solve ~file:"day5-example.txt") ("CMZ", "MCD")
