(* debug.ml
 *
 * Generic structural debugging for "ocaml day1.ml", with no PPX and no
 * user-visible build step.
 *
 * WHY THIS FILE EXISTS
 * --------------------
 * OCaml values do not carry a complete description of their source type at
 * runtime.  For example, the runtime representation of [Left 3] contains a
 * constructor tag and the integer 3, but not the source-level name "Left".
 * A generic printer therefore needs two things:
 *
 *   1. the live runtime value, and
 *   2. the compiler's description of its type and naming environment.
 *
 * [Debug.to_string] gets (1) normally.  To obtain (2), this file asks [ocamlc] to
 * type-check a temporary copy of the script and emit a CMT file.  A CMT is a
 * compiler artifact containing, among other metadata, the Typedtree: the
 * parsed program after name resolution and type checking.  Every expression
 * in that tree has an [exp_type], [exp_env], and [exp_loc].
 *
 * [__POS_OF__ expression] is built into OCaml.  It evaluates to a pair:
 *
 *   ((filename, line, start_column, end_column), expression)
 *
 * The position lets us find the same expression in the Typedtree.  We then
 * give its type, environment, and the live value to OCaml's own toplevel
 * value printer.  This is why plain [Debug.to_string expression] is not enough here:
 * after type erasure, the helper could inspect the memory shape but could not
 * reliably recover record fields or constructor names.
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
 *       print_endline (Debug.to_string (__POS_OF__ x))
 *     done
 *
 * Run:
 *
 *   ocaml day1.ml
 *
 * The first [Debug.to_string] call for a source file does the compilation and Typedtree
 * search.  The results are cached, so later calls at the same or other source
 * locations do not invoke [ocamlc] again.
 *
 * Intended for OCaml 5.x.  This deliberately relies on unstable
 * compiler-libs internals.  Compiler-libs is useful but is not a stable API;
 * constructor names and function signatures may change between OCaml
 * releases.
 *
 * FINDING AND LEARNING THESE APIS
 * -------------------------------
 * Compiler-libs ships with OCaml.  It is not a separate package managed by
 * this script.  Useful ways to explore the installed version are:
 *
 *   ocamlc -where
 *     Prints the standard-library directory.  Compiler interfaces are in its
 *     [compiler-libs/] subdirectory.
 *
 *   #show Toploop.print_value;;
 *   #show_type Types.type_desc;;
 *     Ask an interactive [ocaml] session about a loaded interface.
 *
 *   less $(ocamlc -where)/compiler-libs/toploop.mli
 *     Read an installed [.mli] interface.  Relevant interfaces here include
 *     [cmt_format.mli], [typedtree.mli], [tast_iterator.mli], [types.mli],
 *     [env.mli], [envaux.mli], and [toploop.mli].
 *
 * Findlib (usually invoked through [ocamlfind], and through [#require] in a
 * findlib-enabled toplevel) solves package discovery: it translates package
 * names into include directories and archives.  This file does not use
 * findlib.  It uses the compiler's built-in [+compiler-libs] directory name
 * and loads a known archive directly.
 *)

(* Lines beginning with [#] at the OCaml toplevel are directives: commands to
   the interactive/script runner rather than ordinary OCaml expressions.
   [#use "debug.ml"] reads, parses, and executes the phrases in this file as
   though they had been entered into the current toplevel session.

   [#directory] adds a directory to the toplevel's search path for compiled
   interfaces and bytecode archives.  A leading [+] means "relative to
   OCaml's standard-library directory", so [+compiler-libs] is portable
   across OPAM switches and installations.

   A [.cmi] contains a module's compiled interface.  Making its directory
   visible lets this file type-check references such as [Types.type_expr],
   but does not load executable implementations.  [#load] dynamically loads
   a bytecode object or archive; [.cma] is a bytecode library archive.

   The running [ocaml] process already contains the toplevel implementation,
   so loading [ocamltoplevel.cma] again would be wrong.  [ocamlcommon.cma]
   supplies common compiler modules needed here, notably the code for reading
   CMT files and walking compiler data structures. *)
#directory "+compiler-libs";;
#load "ocamlcommon.cma";;

(* This is the type returned as the first component of [__POS_OF__ e].
   Lines are one-based; columns are zero-based. *)
type dbg_pos = string * int * int * int

(* [Types.type_expr] is compiler-libs' internal, graph-shaped representation
   of a type.  It is more than a printed type string.  [Env.t] is the naming
   environment needed to resolve paths inside that type to declarations, such
   as resolving [rotation] to constructors [Left] and [Right]. *)
type dbg_site =
  { ty : Types.type_expr
  ; env : Env.t
  }

let dbg_fail fmt =
  Printf.ksprintf (fun s -> failwith ("Debug.to_string: " ^ s)) fmt

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

(* Toplevel directives such as [#use] are understood by [ocaml], but they are
   not structure items that [ocamlc] can compile in an ordinary [.ml]
   compilation unit.  The temporary source therefore blanks directive lines.

   We replace each directive with an empty line rather than deleting it so
   all later line numbers remain unchanged.  This intentionally recognizes
   only a directive whose [#] is the first non-whitespace character. *)
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

(* The temporary file is a normal compilation unit rather than a toplevel
   script.  Because its [#use "debug.ml"] line was blanked, we insert a tiny
   type-correct stand-in for [Debug.to_string].  It has the essential type

       ('position * 'a) -> string

   and never runs: [ocamlc] will stop after type checking.

   [# 1 "filename"] looks like a toplevel directive, but is a different
   feature: it is a lexer line-number directive, conventionally emitted by
   preprocessors.  It tells the compiler that the following text came from
   line 1 of the real script.  Consequently, locations recorded in the CMT
   match the position produced while the real script runs. *)
let source_for_typechecking ~reported_filename source =
  Printf.sprintf
    "module Debug = struct let to_string (_, _) = \"\" end\n# 1 %S\n%s"
    reported_filename
    (strip_toplevel_directives source)

(* [ocamlc] may create several sibling files.  Register every possible path
   before invoking it so an exception or compiler error does not leave junk
   behind.  [at_exit] runs on normal process exit and most exceptions, though
   it cannot help after an uncatchable kill or machine crash. *)
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

(* Run a second, compile-only view of the source and read its CMT metadata.

   This does not compile or replace the live program.  The original script is
   still being evaluated phrase by phrase by [ocaml]; the temporary compile
   exists only to ask the compiler, "what type and environment did this source
   expression have?" *)
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

  (* Some environments stored in a CMT are compact summaries.  Reconstructing
     them later may require finding standard-library or project [.cmi] files.
     [Compmisc.init_path] initializes compiler-libs' own [Load_path] using the
     current OCaml installation, with the script directory as a local include
     directory.  This is separate from the toplevel's [#directory] search
     path above. *)
  Compmisc.init_path ~dir:source_dir ();
  let err_file = Filename.temp_file "ocaml_dbg_" ".err" in
  remember_temp err_file;

  (* The flags mean:

       -bin-annot          write binary annotations, including a [.cmt]
       -stop-after typing  parse and type-check, but do not generate code
       -w -a               disable warnings for this private second pass
       -I source_dir       find compiled modules beside the real script

     We run from [temp_dir] so compiler outputs land beside the temporary
     source.  [Filename.quote] prevents spaces and shell metacharacters in
     paths from changing the command's meaning.  Compiler stderr is captured
     so [Debug.to_string] can report a useful exception if this second pass
     fails. *)
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

  (* [read_cmt] unmarshals the compiler metadata.  The result contains a
     [cmt_annots] field whose implementation case holds the Typedtree. *)
  Cmt_format.read_cmt cmt

(* A [Lexing.position] stores an absolute character offset [pos_cnum] and the
   absolute offset of the beginning of its line [pos_bol].  Their difference
   is the zero-based column. *)
let col (p : Lexing.position) =
  p.pos_cnum - p.pos_bol

(* [Location.t] has a start and end [Lexing.position].  OCaml locations are
   normally half-open: the start is inclusive and the end is just after the
   expression.  These helpers compare a Typedtree node with [__POS_OF__]'s
   simpler tuple representation. *)
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

(* The expression located by [pos] is the compiler expansion of

       __POS_OF__ value

   and therefore has the pair type [dbg_pos * value_type].  At runtime
   [Debug.to_string] pattern-matches that pair and passes only [value] to the
   printer.  We must
   likewise pass only [value_type], not the enclosing pair type.  Getting this
   wrong is especially dangerous because [Toploop.print_value] receives an
   untyped [Obj.t]: it could interpret the live memory using the wrong shape. *)
let payload_type (e : Typedtree.expression) =
  match Types.get_desc e.exp_type with
  | Types.Ttuple [_position_type; value_type] ->
      value_type
  | _ ->
      dbg_fail
        "expression selected by __POS_OF__ does not have the expected pair type"

(* Locate the Typedtree expression corresponding to one [__POS_OF__] site.

   [Tast_iterator] is compiler-libs' visitor for typed syntax trees.  The
   default iterator knows how to recurse into every kind of structure item,
   expression, pattern, module, and so on.  We override only its [expr]
   callback, record matching expressions, and then call the default callback
   to keep walking into the expression's children. *)
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
      (fun (a : Typedtree.expression) (b : Typedtree.expression) ->
        (* Typedtrees can contain nested or compiler-generated expressions
           sharing a start location.  An exact end match is strongest.  If
           several still tie, the shortest span is the most specific node. *)
        match same_end pos a.exp_loc, same_end pos b.exp_loc with
        | true, false -> -1
        | false, true -> 1
        | _ -> Int.compare (loc_span a.exp_loc) (loc_span b.exp_loc))
      !candidates
  in

  match candidates with
  | e :: _ ->
      { ty = payload_type e

      (* To keep CMT files smaller, expression environments may retain only an
         [Env.summary]: roughly, a replayable history of environment changes.
         [env_of_only_summary] rebuilds the lookup tables required by the
         value printer.  Without this step, ordinary types such as [list] and
         local variants may be printed as [<abstr>]. *)
      ; env = Envaux.env_of_only_summary e.exp_env
      }
  | [] ->
      let file, line, c0, c1 = pos in
      dbg_fail
        "could not find a Typedtree expression at %s:%d:%d-%d"
        file line c0 c1

(* Reading and rebuilding a Typedtree is the expensive part.  One source file
   has one structure, so cache it by the filename reported by [__POS_OF__]. *)
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
        (* A normal [.ml] file produces [Implementation].  Other CMT forms
           represent interfaces, packed units, or partial compiler output and
           do not give us the complete structure this traversal expects. *)
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

(* Cache the final type/environment pair per call site as well.  A loop may
   execute the same [Debug.to_string] call thousands of times; only the live
   value changes. *)
let sites : (string, dbg_site) Hashtbl.t =
  Hashtbl.create 17

(* NUL separators make keys unambiguous even if a filename or decimal fields
   happen to have similar textual boundaries. *)
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

(* The public operation.

   Pattern matching separates the source position from the live value.  The
   result is the value's structural representation as a string; this function
   does not print it or include source-location metadata.

   [Obj.repr] forgets the static OCaml type and exposes the value through the
   universal runtime handle [Obj.t].  This is the intentionally unsafe bridge
   in the design: [Obj.t] itself cannot prove that [site.ty] describes
   [value].  The source-location lookup above establishes that correspondence.

   [Toploop.print_value] is the same structural machinery used when the OCaml
   REPL displays the result of an entered expression.  Given the environment,
   it can resolve type declarations and turn runtime constructor tags back
   into names.  Its usual limits still apply: functions display as [<fun>],
   abstract types may display as [<abstr>], and large/deep values are
   truncated according to the toplevel printer's limits.

   [Format.asprintf] supplies an in-memory formatter and returns everything
   written to it as a string. *)
module Debug = struct
  let to_string (pos, value) =
    let site = site_for_pos pos in
    Format.asprintf
      "%a"
      (fun ppf () ->
        Toploop.print_value site.env (Obj.repr value) ppf site.ty)
      ()
end
