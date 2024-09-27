(* language-server-result.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure LanguageServerResult =
  struct

    (* the result of handling a request *)
    type 'a t
      = OK of 'a
      | ERR of {
	    code : int,
	    msg : string,
	    data : JSON.value option
	  }

  end
