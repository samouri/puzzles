open! Core

let read_file path = In_channel.read_all path |> String.strip
