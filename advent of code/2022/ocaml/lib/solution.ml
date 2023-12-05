open Core

module type S = sig
  type t

  val solve : ?file:string -> unit -> t * t

  include Stringable.S with type t := t
end

module Stringable_int = struct
  let of_string = Int.of_string
  let to_string = Int.to_string
end
