/**************************************************************************/
/*                                                                        */
/*  Copyright (c) 2025 OCamlPro SAS                                       */
/*                                                                        */
/*  All rights reserved.                                                  */
/*  This file is distributed under the terms of the GNU Lesser General    */
/*  Public License version 2.1, with the special exception on linking     */
/*  described in the LICENSE.md file in the root directory.               */
/*                                                                        */
/*                                                                        */
/**************************************************************************/

#define CAML_NAME_SPACE

#define DEBUG
#include "caml/mlvalues.h"
#include "caml/alloc.h"
#include "caml/memory.h"
#include "caml/callback.h"
#include "caml/gc.h"

/* Inline array structure

   value[-1]: header (global header with size of the full block)
   value[0]: Val_long(item_size)
   value[INLINE_ARRAY_HEAD]: header of first record if Infix_tag
   value[2]: field[0] of first record
   ...
   value[INLINE_ARRAY_HEAD+(1+item_size)]: header of second record
   ...
   value[INLINE_ARRAY_HEAD+2*(1+item_size)]: header of third record
   ...
 */

#define INLINE_ARRAY_HEAD 1

void caml_failed_assert (char * expr, char_os * file_os, int line)
{
  char* file = caml_stat_strdup_of_os(file_os);
  fprintf (stderr, "file %s; line %d ### Assertion failed: %s\n",
           file, line, expr);
  fflush (stderr);
  caml_stat_free(file);
  abort();
}

CAMLprim value ml_inlineArray_get(value t_v, value item_size_v, value pos_v) {
  /* We could also use the item_size stored inside the global block
     first pos */
  long item_size = Long_val(item_size_v);
  CAMLparam1(t_v);
  CAMLlocal1(res_v);

  res_v = (value)
    (((char*)t_v) +
     (INLINE_ARRAY_HEAD + 1 +
      Long_val(pos_v) * (1+ item_size)) * sizeof(value));

  CAMLassert ( Long_val(Field(t_v,0)) == item_size );

  CAMLreturn(res_v);
}

CAMLprim value ml_inlineArray_set(value t_v, value item_size_v,
				  value pos_v, value x_v) {
  int i ;
  long item_size = Long_val(item_size_v);
  CAMLparam1(t_v);
  CAMLlocal1(res_v);
  CAMLassert ( Wosize_val(x_v) == item_size );

  res_v = (value)
    (((char*)t_v) +
     (INLINE_ARRAY_HEAD + 1 +
      Long_val(pos_v) * (1+item_size)) * sizeof(value));

  CAMLassert ( Long_val(Field(t_v,0)) == item_size );
  for (i=0; i<item_size; i++)
    Store_field (res_v, i, Field(x_v, i));

  CAMLreturn(Val_unit);
}

CAMLprim value ml_inlineArray_make_chunk(value nitems_v, value x_v) {
  long nitems = Long_val(nitems_v);
  long item_size ;
  CAMLparam1(x_v);
  CAMLlocal1(res_v);

  if (nitems == 0)
    res_v = Val_unit;
  else {
    int size,i,j,pos ;

    item_size = Wosize_val(x_v);
    size = INLINE_ARRAY_HEAD + (1 + item_size) * nitems;
    res_v = caml_alloc ( size, 0);

    Field (res_v, 0) = Val_long (item_size);

    pos = 1;
    for (j=0; j<nitems; j++){
      Field (res_v, pos) = Make_header (pos+1, Infix_tag, Caml_white) ;
      pos++ ;
      {
	value v = (value) (&Field(res_v, pos));
	CAMLassert ( v - Infix_offset_val(v) == res_v );
      }
      for (i=0; i<item_size; i++){
	Store_field (res_v, pos, Field(x_v, i));
	pos++ ;
      }
    }
  }
  CAMLreturn(res_v);
}
