(* debug.ml
 *
 * Generic structural debugging for "ocaml day1.ml", with no PPX and no
 * user-visible build step.
 *
 * Usage:
 *
 *   #use "debug.ml";;
 *
 *   type direction = Left | Right
 *
 *   let () =
 *     for i = 1 to 3 do
 *       let x = Some [(i, Left); (i + 1, Right)] in
 *       ignore (dbg (__POS_OF__ x))
 *     done
 *
 * Run:
 *
 *   ocaml day1.ml
 *
 * The first dbg call silently asks ocamlc to type-check a temporary,
 * directive-free copy of the source with -bin-annot, reads its .cmt,
 * finds the Typedtree expression identified by __POS_OF__, and hands
 * its Env.t + Types.type_expr + the live Obj.t to Toploop.print_value.
 *
 * Intended for OCaml 5.x.  This deliberately relies on unstable
 * compiler-libs internals.
 *)

(* We are running *inside* [ocaml], which is itself linked with the
   compiler/toplevel implementation.  This makes the compiler-libs .cmi
   files visible to the typechecker without trying to #load
   ocamltoplevel.cma back into itself. *)
#directory "+compiler-libs";;

type dbg_pos = string * int * int * int

type dbg_site =
  { ty : Types.type_expr
  ; env : Env.t
  }

let dbg_formatter = ref Format.err_formatter

let dbg_fail fmt =
  Printf.ksprintf (fun s -> failwith ("dbg: " ^ s)) fmt

let read_file path =
  let ic = open_in_bin path in
  Fun.protect
    ~finally:(fun () -> close_in_noerr ic)
    (fun () ->
      really_input_string ic (in_channel_length ic))

let write_file path contents =
  let oc = open_out_bin path in
  Fun.protect
    ~finally:(fun () -> close_out_noerr oc)
    (fun () -> output_string oc contents)

let absolute_path path =
  if Filename.is_relative path
  then Filename.concat (Sys.getcwd ()) path
  else path

let is_toplevel_directive_line line =
  let rec first_non_space i =
    if i = String.length line then None
    else
      match line.[i] with
      | ' ' | '\t' -> first_non_space (i + 1)
      | c -> Some c
  in
  match first_non_space 0 with
  | Some '#' -> true
  | _ -> false

let strip_toplevel_directives source =
  source
  |> String.split_on_char '\n'
  |> List.map (fun line ->
       if is_toplevel_directive_line line then "" else line)
  |> String.concat "\n"

(* Generated source is a normal compilation unit, rather than a toplevel
   script.  [dbg] only has to typecheck; it must not do anything.  The
   #line directive makes all following source locations point back into
   the real script, which is what lets __POS_OF__ line up with the CMT. *)
let source_for_typechecking ~reported_filename source =
  Printf.sprintf
    "let dbg (_, x) = x\n# 1 %S\n%s"
    reported_filename
    (strip_toplevel_directives source)

let temp_files = ref []

let remember_temp path =
  temp_files := path :: !temp_files

let remove_if_exists path =
  try
    if Sys.file_exists path then Sys.remove path
  with Sys_error _ ->
    ()

let () =
  at_exit (fun () -> List.iter remove_if_exists !temp_files)

let possible_compiler_artifacts ml =
  let stem =
    try Filename.chop_extension ml
    with Invalid_argument _ -> ml
  in
  [ stem ^ ".cmt"
  ; stem ^ ".cmi"
  ; stem ^ ".cmo"
  ; stem ^ ".annot"
  ]

let compile_cmt ~reported_filename =
  let actual_source = absolute_path reported_filename in
  if not (Sys.file_exists actual_source) then
    dbg_fail "source file %S does not exist" actual_source;

  let source = read_file actual_source in
  let generated =
    source_for_typechecking ~reported_filename source
  in

  let temp_ml = Filename.temp_file "ocaml_dbg_" ".ml" in
  remember_temp temp_ml;
  List.iter remember_temp (possible_compiler_artifacts temp_ml);

  write_file temp_ml generated;

  let temp_dir = Filename.dirname temp_ml in
  let temp_base = Filename.basename temp_ml in
  let source_dir = Filename.dirname actual_source in
  let err_file = Filename.temp_file "ocaml_dbg_" ".err" in
  remember_temp err_file;

  (* [Filename.quote] is for shell command arguments on the platforms
     where the stock [ocaml] scripting workflow is normally used. *)
  let command =
    Printf.sprintf
      "cd %s && ocamlc -bin-annot -stop-after typing -w -a -I %s %s 2>%s"
      (Filename.quote temp_dir)
      (Filename.quote source_dir)
      (Filename.quote temp_base)
      (Filename.quote err_file)
  in

  let status = Sys.command command in
  if status <> 0 then begin
    let errors =
      try read_file err_file
      with _ -> "(unable to read ocamlc stderr)"
    in
    dbg_fail
      "could not type-check %S to obtain its Typedtree.\n\
       Command exited %d.\n%s"
      reported_filename
      status
      errors
  end;

  let cmt =
    let stem =
      try Filename.chop_extension temp_ml
      with Invalid_argument _ -> temp_ml
    in
    stem ^ ".cmt"
  in

  if not (Sys.file_exists cmt) then
    dbg_fail
      "ocamlc succeeded but did not produce expected CMT %S"
      cmt;

  Cmt_format.read_cmt cmt

let col (p : Lexing.position) =
  p.pos_cnum - p.pos_bol

let same_start
    ((file, line, start_col, _end_col) : dbg_pos)
    (loc : Location.t)
  =
  let p = loc.loc_start in
  p.pos_fname = file
  && p.pos_lnum = line
  && col p = start_col

let same_end
    ((_file, line, _start_col, end_col) : dbg_pos)
    (loc : Location.t)
  =
  let p = loc.loc_end in
  p.pos_lnum = line
  && col p = end_col

let loc_span (loc : Location.t) =
  loc.loc_end.pos_cnum - loc.loc_start.pos_cnum

let find_site_in_structure pos (structure : Typedtree.structure) =
  let candidates = ref [] in

  let expr self (e : Typedtree.expression) =
    if same_start pos e.exp_loc then
      candidates := e :: !candidates;
    Tast_iterator.default_iterator.expr self e
  in

  let iterator =
    { Tast_iterator.default_iterator with expr }
  in
  iterator.structure iterator structure;

  let candidates =
    List.sort
      (fun a b ->
        (* Exact end-position matches win.  Among ties, prefer the
           smallest expression beginning at this location. *)
        match same_end pos a.exp_loc, same_end pos b.exp_loc with
        | true, false -> -1
        | false, true -> 1
        | _ -> Int.compare (loc_span a.exp_loc) (loc_span b.exp_loc))
      !candidates
  in

  match candidates with
  | e :: _ ->
      { ty = e.exp_type; env = e.exp_env }
  | [] ->
      let file, line, c0, c1 = pos in
      dbg_fail
        "could not find a Typedtree expression at %s:%d:%d-%d"
        file line c0 c1

let typed_structures :
    (string, Typedtree.structure) Hashtbl.t =
  Hashtbl.create 3

let structure_for_source reported_filename =
  match Hashtbl.find_opt typed_structures reported_filename with
  | Some structure ->
      structure
  | None ->
      let cmt = compile_cmt ~reported_filename in
      let structure =
        match cmt.Cmt_format.cmt_annots with
        | Cmt_format.Implementation structure ->
            structure
        | Cmt_format.Partial_implementation _ ->
            dbg_fail
              "compiler produced only a partial Typedtree for %S"
              reported_filename
        | _ ->
            dbg_fail
              "CMT for %S does not contain an implementation Typedtree"
              reported_filename
      in
      Hashtbl.add typed_structures reported_filename structure;
      structure

let sites : (string, dbg_site) Hashtbl.t =
  Hashtbl.create 17

let site_key ((file, line, c0, c1) : dbg_pos) =
  Printf.sprintf "%s\000%d\000%d\000%d" file line c0 c1

let site_for_pos (((file, _, _, _) as pos) : dbg_pos) =
  let key = site_key pos in
  match Hashtbl.find_opt sites key with
  | Some site ->
      site
  | None ->
      let structure = structure_for_source file in
      let site = find_site_in_structure pos structure in
      Hashtbl.add sites key site;
      site

let dbg (((file, line, c0, c1) as pos), value) =
  let site = site_for_pos pos in
  let ppf = !dbg_formatter in
  Format.fprintf ppf "@[<v 0>%s:%d:%d-%d:@," file line c0 c1;
  Toploop.print_value site.env (Obj.repr value) ppf site.ty;
  Format.fprintf ppf "@]@.";
  value
