(* lsp-server.sig
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

signature LSP_SERVER = sig

    structure LS : LANGUAGE_SERVER

    type t
    type state = LS.t

    (* create a server with the supplied IO streams.
    val create : {
            inp : TextIO.instream,
            outp : TextIO.outstream,
            logp : TextIO.outstream option
          } -> t

(* registration structure has generated signature
    structure Register : LSP_SERVER_REGISTRATION
*)

(* the pattern for message-handling functions
    (* register a handler for the "Foo" request *)
    val registerFoo : t * (state * Foo.params -> Foo.result ServerResult.t) -> unit

    (* register a handler for the "Foo" notification *)
    val registerFoo : t * (state * Foo.params -> unit) -> unit

    (* send a "Foo" notification *)
    val notifyFoo : t * Foo.params -> unit

    (* send a "Foo" request *)
    val requestFoo : t * Foo.params -> Foo.result ServerResult.t
*)

    (* run the server *)
    fun run : t -> OS.Process.status

  end (* signature LSP_SERVER *)
