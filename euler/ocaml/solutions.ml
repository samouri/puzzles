open Core;;

(*
  sum between 0 and provided number.
  @param multiple: only sum numbers that are multiples of a number in this list
*)
let rec sum ?(multiple=[1]) = function
  | 0 -> 0
  | n -> (sum ~multiple (n-1)) + if List.exists ~f: (fun y -> n mod y = 0 ) multiple then n else 0
;;

(*
  a worse version of sum because of mem usage and speed but at least i got to
  play with some cool functions like reverse applicative operator
*)
let sum2 ?(multiple=[1]) n = 
  List.range 0 (n+1)
  |> List.filter ~f: (fun z -> (List.exists ~f: (fun y -> z mod y = 0) multiple ) )
  |> List.fold ~f: (+) ~init: 0;;

let rec fib = function
  | 0 -> 1
  | 1 -> 2
  | n -> fib (n - 1) + fib (n - 2)
;;

(*
  Keeping this for old times sake so i see just how bad my first solution
  was
*)
let rec sum_until_4mil n =
  let fibVal = fib n in
  let isEven = fibVal mod 2 = 0 in
  if fibVal > 4_000_000 then 0 else (
    ( if isEven then fibVal else 0 ) + sum_until_4mil (n+1)
  )


let rec pfactors_nondeduped ?(factors=[]) ?(divisor=2) n = 
  if n = 1 then factors 
  else if n mod divisor = 0 then pfactors_nondeduped ~factors:(divisor::factors) ~divisor (n/divisor)
  else pfactors_nondeduped ~factors ~divisor:(divisor+1) n;;

(* get all prime factors *)
let rec pfactors ?(factors=[]) ?(divisor=2) n = 
  pfactors_nondeduped ~factors ~divisor n 
  |> List.dedup
;;

(* problem 1
*)
let prob1 = fun() ->
  let answer = sum ~multiple:[3; 5] 999 in
  print_endline ( "problem 1: " ^ ( string_of_int answer ) )
;;

(* problem 2
*)
let prob2 = fun() -> 
  let answer = sum_until_4mil 0 in
  print_endline ( "problem 2: " ^ ( string_of_int answer ) )
;;

let prob3 = fun() ->
  let answer = match List.max_elt (pfactors 600851475143 ) (-) with
    | Some x -> x
    | None -> 0 in
  print_endline ( "problem 3: " ^ ( string_of_int answer ) )
;;


(* problem 4 
 * A palindromic number reads the same both ways. 
 * The largest palindrome made from the product of two 2-digit numbers is 9009 = 91 × 99.
 * Find the largest palindrome made from the product of two 3-digit numbers.
*)
let rec isPalindromic = function
  | "" -> true
  | s when (String.length s) = 0 -> true
  | s -> (String.get s 0) = (String.get s ((String.length s)-1)) &&
         isPalindromic (String.slice s 1 ( String.length s -1) )
;; 
let isPalindromicNumber n = string_of_int n |> isPalindromic;;

let prob4 = fun() ->
  let maxPalindrome = ref 0 in
  for i = 100 to 999 do
    for j = 100 to 999 do
      let product = i * j in
      if (isPalindromicNumber product) && product > !maxPalindrome then
        maxPalindrome := product
    done
  done;
  print_endline ("problem 4: " ^ string_of_int !maxPalindrome);
;;

(* problem 5
 * 2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder. 
 * What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?
*)

let rec gcd x y = match (x,y) with
  | (x', 0) -> x'
  | (x',y') -> gcd y' (x' mod y')

let lcm x y  = ( x * y ) / (gcd x y);;

(* least common multiple of a list of numbers *)
let lcmList nums = List.fold ~f:lcm ~init:1 nums;;

let prob5 = fun() ->
  let probRange = List.range 1 20 in
  print_endline ("problem 5: " ^ string_of_int (lcmList probRange)) 
;;

prob1();
prob2();
prob3();
prob4();
prob5();
