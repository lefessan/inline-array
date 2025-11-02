(**************************************************************************)
(*                                                                        *)
(*  Copyright (c) 2025 OCamlPro SAS                                       *)
(*                                                                        *)
(*  All rights reserved.                                                  *)
(*  This file is distributed under the terms of the GNU Lesser General    *)
(*  Public License version 2.1, with the special exception on linking     *)
(*  described in the LICENSE.md file in the root directory.               *)
(*                                                                        *)
(*                                                                        *)
(**************************************************************************)

type 'a t

(* Creates an InlineArray.t containing a `n` copies of the record
   given in argument *)
val make : int -> 'a -> 'a t

(* Returns the number of elements in the InlineArray.t *)
val length : 'a t -> int

(* Returns the nth element of the InlineArray.t, which is a pointer to
   the record within the InlineArray.t, not a copy *)
val get : 'a t -> int -> 'a

(* Copies the record in argument to the nth elemtn of the InlineArray.t *)
val set : 'a t -> int -> 'a -> unit

(* Creates an InlineArray.t by calling the function and copying the
   result to the corresponding position of the InlineArray.t *)
val init : int -> (int -> 'a) -> 'a t

(* Iters on elements of the InlineArray.t. Each element is the element
   of the InlineArray.t, not a copy *)
val iter : ('a -> unit) -> 'a t -> unit
val iteri : (int -> 'a -> unit) -> 'a t -> unit

