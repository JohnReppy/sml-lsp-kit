(* json-rpc-input.sml
 *
 * COPYRIGHT (c) 2024 The Fellowship of SML/NJ (https://www.smlnj.org)
 * All rights reserved.
 *)

structure JSONRPCInput : sig

    val request : string -> JSONRPC.request option

    val response : string -> JSONRPC.response option

    val message : string -> JSONRPC.message

  end = struct

    fun request content =
          JSONRPCDecode.request(JSONParser.parse(JSONParser.openString content))

    fun response content =
          JSONRPCDecode.response(JSONParser.parse(JSONParser.openString content))

    fun message content =
          JSONRPCDecode.message(JSONParser.parse(JSONParser.openString content))

  end
