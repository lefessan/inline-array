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

type t = {
    x : int ;
    mutable y : int ;
    mutable z : int ;
    xyz : string ;
  }

let make x y z =
  { x ; y ; z ; xyz = Printf.sprintf "%d.%d.%d" x y z }

let to_string a =
  Printf.sprintf "%d.%d.%d.{%s}" a.x a.y a.z a.xyz

let get t n =
  Printf.eprintf "get[%d/%d] = %!" n (InlineArray.length t);
  let s =
  try
    let a = InlineArray.get t n in
    to_string a
  with
    exn ->
    Printexc.to_string exn
  in
  Printf.eprintf "%s\n%!" s

let print t =
  let len = InlineArray.length t in
  get t (-1) ;
  get t len ;
  InlineArray.iteri (fun i v ->
      Printf.eprintf "get[%d/%d] = %s\n%!" i (InlineArray.length t)
        (to_string v)
    ) t;
  ()

let main () =
  let a = make 0 0 0 in
  let len = 10 in
  let t = InlineArray.make len a in
  print t;
  let t = InlineArray.init len (fun i ->
              make i 0 i) in
  print t;
  Gc.major ();
  Gc.major ();
  Gc.major ();
  Gc.major ();
  print t;
  ()
