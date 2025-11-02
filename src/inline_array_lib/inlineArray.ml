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

let invalid_arg s = invalid_arg ( Printf.sprintf "InlineArray.%s" s)

type 'a chunk

type 'a t = {
    nitems : int ;
    item_size : int ; (* without the header *)
    chunk : 'a chunk ;
  }

external make_chunk : int -> 'a -> 'a chunk
  = "ml_inlineArray_make_chunk"
external make_empty_chunk : unit -> 'a chunk = "%identity"
external chunk_get : 'a chunk -> item_size:int -> int -> 'a
  = "ml_inlineArray_get" [@@ noalloc]
external chunk_set : 'a chunk -> item_size:int -> int -> 'a -> unit
  = "ml_inlineArray_set" [@@ noalloc]

let make nitems item =
  let obj = Obj.repr item in
  if not (Obj.is_block obj) then invalid_arg "make: not a block value";
  if Obj.tag obj <> 0 then invalid_arg "make: tag is not zero";
  {
    nitems ;
    item_size = Obj.size (Obj.repr item) ;
    chunk = make_chunk nitems item ;
  }

let length t = t.nitems
let get t n =
  if n < 0 || n >= t.nitems then invalid_arg "get: index out of bounds" ;
  chunk_get t.chunk ~item_size:t.item_size n

let set t n x =
  if n < 0 || n >= t.nitems then invalid_arg "set: index out of bounds" ;
  chunk_set t.chunk ~item_size:t.item_size n x

let init nitems f =
  if nitems = 0 then
    {
      nitems ;
      item_size = 0 ;
      chunk = make_empty_chunk ();
    }
  else
    let item0 = f 0 in
    let t = make nitems item0 in
    for i = 1 to nitems - 1 do
      set t i (f i)
    done;
    t

let iter f t =
  for i = 0 to length t - 1 do
    f (get t i)
  done

let iteri f t =
  for i = 0 to length t - 1 do
    f i (get t i)
  done
