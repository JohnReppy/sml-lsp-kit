(* json-rpc.sml
 *
 * COPYRIGHT (c) 2024 The Fellowship of SML/NJ (https://www.smlnj.org)
 * All rights reserved.
 *)

structure JSONRPC =
  struct

    (* We support version 2.0 *)
    val version = [2, 0]
    val versionString = String.concatWithMap "." Int.toString version

    (* Request IDs can either be numbers or strings *)
    datatype id = IdNum of int | IdStr of string

    (* the content of the different kinds of messages *)
    type request_content = {
          method : string,
          params : JSON.value option,
          id : id
        }
    type notify_content = {
          method : string,
          params : JSON.value option
        }
    type response_content = {
          result : JSON.value,
          id : id
        }
    type error_content = {
          code : int,
          msg : string,
          data : JSON.value option,
          id : id option
        }

    (* request or notification message *)
    datatype request
      = Request of request_content
      | Notify of notify_content

    (* response to a request message *)
    datatype response
      = Response of response_content
      | Error of error_content

    (* the different kinds of messages; the lists are non-empty with two or more
     * items for batch messages.
     *)
    datatype message
      = RequestMsg of request list
      | ResponseMsg of response list
      | InvalidMsg

    (* error codes that are specified by the JSON RPC spec *)
    val errInvalidJSON : int = ~32700
    val errInvalidRequest : int = ~32600
    val errMethodNotFound : int = ~32601
    val errInvalidParams : int = ~32602
    val errInternal : int = ~32603

  end
