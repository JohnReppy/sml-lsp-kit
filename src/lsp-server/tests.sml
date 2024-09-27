(* tests.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure Tests =
  struct

    val request = JSONRPCInput.request o MessageIO.testRd
    val response = JSONRPCInput.response o MessageIO.testRd

    val requestTests = [
            "test-messages/message01.txt",      (* "initialize" request *)
            "test-messages/message03.txt",      (* "initialized" notification *)
            "test-messages/message04.txt",      (* "textDocument/didOpen" notification *)
            "test-messages/message05.txt",      (* "textDocument/publishDiagnostics" notification *)
            "test-messages/message06.txt",      (* "textDocument/didChange" notification *)
            "test-messages/message07.txt"       (* "textDocument/completion" request *)
          ]

    val responseTests = [
            "test-messages/message02.txt",      (* "initialize" response *)
            "test-messages/message08.txt"       (* "textDocument/completion" response *)
          ]

  end
