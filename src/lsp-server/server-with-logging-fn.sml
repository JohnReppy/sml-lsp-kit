(* server-with-logging-fn.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * This file implements a sequential version of an LSP server that supports logging
 * the message traffic.
 *)

functor LSPServerWithLoggingFn (L : LANGUAGE_SERVER) : LSP_SERVER =
  struct

    structure TIO = TextIO.StreamIO
    structure Encode : JSONRPCEncode
    structure Decode : JSONRPCDecode

    structure STbl = HashTableFn (struct
        type hash_key = string
        val hashVal = HashString.hashString
        val sameKey : string * string -> bool = (op =)
      end);

    (* output to CharBuffer.buf *)
    structure JSONOut = JSONStreamOutputFn (
      struct
        type outstream = CharBuffer.buf

        val output1 = CharBuffer.add1
        val output = CharBuffer.addVec
        val outputSlice = CharBuffer.addSlice

      end)

    datatype id = datatype JSONRPC.id
    datatype request = datatype JSONRPC.request
    datatype response = datatype JSONRPC.response
    datatype value = datatype JSON.value

    datatype result = datatype ServerResult.t

    type state = L.state

    datatype status
      (* server is waiting for Initialize request from client *)
      = WaitingForInit
      (* server has been initialized and is running *)
      | Running
      (* server has received and processed a "shutdown" request *)
      | WaitingForExit
      (* the server has received and processed an "exit" notification *)
      | Exited of OS.Process.status

    (* the state of a LSP server *)
    datatype t = SERVER of {
        (* a table mapping request names to handlers.  Note that the handlers are
         * responsible for sending the response to the client.
         *)
        reqTbl : (t * JSONRPC.request -> unit) STbl.hash_table,
        (* requests and notifications that arrived while the language server was
         * waiting for a response to a request that it sent to the server.  Note
         * that these are in the reverse order in which they were received.
         *)
        pendingReqs : message list ref,
        (* the input stream for receiving messages from the client *)
        inp : TIO.instream ref,
        (* the output stream for sending messages to the client *)
        outp : TIO.outstream,
        (* output buffer for holding message content *)
        outBuf : CharBuffer.buf,
        (* optional output stream for logging *)
        logp : TextIO.outstream option,
        (* the next request ID *)
        nextId : word ref,
        (* the status of the LSP server *)
        status : status ref,
        (* the state of the language server *)
        state : state
      }

    fun stateOf (SERVER{state, ...}) = state
    fun outBufOf (SERVER{outBuf, ...}) = outBuf

    fun getStatus (SERVER{status, ...}) = !status
    fun setStatus (SERVER{status, ...}, sts) = (status := sts)

    fun send (SERVER{outp, outBuf, ...}) = (
          MessageIO.write(outp, CharBuffer.contents outBuf);
          CharBuffer.reset outBuf)

    fun sendResponse (serv, response) = (
          (* log the response *)
          logResponse (serv, response);
          (* output to buffer *)
          JSONOut.value (outBufOf serv, response);
          (* send response to client *)
          send serv)

(* the following is a version with support for logging.  If we disable logging,
 * then we can directly encode messages into the outBuf.
 *)
    fun requestHandler decodeParams encodeResult handlerFn = let
          fun handler (serv, Request{id, params=SOME(OBJECT flds), ...}) = let
                val response = (case decodeParams flds
                       of SOME params => (case handlerFn (stateOf serv, params)
                             of OK res =>
                                  encodeResult(id, res)
                              | ERR{code, msg, data=NONE} =>
                                  Encode.error{id = id, code = code, message = msg}
                              | ERR{code, msg, data=SOME data} => Encode.errorWithData{
                                    id = id, code = code, message = msg, data = data
                                  }
                            (* end case *))
                        | NONE => Encode.error{
                              id = id,
                              code = JSONRPC.errInvalidParams,
                              message = "invalid parameters in request"
                            }
                      (* end case *))
                in
                  sendResponse (serv, response)
                end
            | handler (serv, _) = sendResponse (serv, Encode.error{
                  id = id,
                  code = JSONRPC.errInvalidParams,
                  message = "expected object for request parameters"
                })
          in
            handler
          end

    val handleInitialize =
          requestHandler
            LSP.Initialize.decodeParams
            LSP.Initialize.encodeResult
            L.initialize

    (* handler for a `shutdown` request *)
    fun handleShutdown serv = ??

    (* handler for an `exit` notification *)
    fun handleExit (serv, Notify _) = (
          L.exit (stateOf serv);
          case getStatus serv
           of WaitingForExit => setStatus (serv, Exited OS.Process.Success)
            | _ => setStatus (serv, Exited OS.Process.Failure)
          (* end case *))

    (* wait for an initialization request from the client.  During this period
     * notifications are ignored and any requests other than an "exit" request
     * result in "ServerNotInitialized" errors.
     *)
    fun waitForInitialize serv = ??

    (* wait for an "exit" notification from the client.  Any requests received
     * while waiting result an "InvalidRequest" error response and any notifications
     * or response messages are ignored.
     *)
    fun waitForExit serv = ??

    (* dispatch a client request to the Language Server *)
    fun dispatch (serv as SERVER{reqTbl, ...}) = let
          val find = STbl.find reqTbl
          in
(* QUESTIONS:
 *   - are unsupported (but valid) requests stubbed out with a handler that generates
 *     a LSPErrors.kRequestFailed message for valid, but unsupported, requests?
 *   - should we have separate request and notification handler tables or should
 *     we change the JSONRPC.request datatype to unify requests and notifications
 *     (i.e., make the ID optional)?
 *)
            fn (req as Request{name, id, ...}) => (case find name
                 of SOME h => h (serv, req)
                  | NONE => sendResponse (serv, Encode.error{
                        id = id,
                        code = ErrorCodes.kMethodNotFound,
                        message = concat["unknown method '", name, "'"]
                      })
                (* end case *))
             | (note as Notify{name, ...}) => (case find name
                 of SOME h => h (serv, note)
                  | NONE => ()
                (* end case *))
          end

    fun run serv = let
          (* first, we must wait for the initialization message *)
          val () = waitForInitialize serv
          fun lp () = (case getStatus serv
                 of WaitingForInit => raise Fail "server not initialized"
                  | Running => (waitForRequest serv; lp())
                  | WaitingForExit => waitForExit serv
                  | Exited sts => sts
                (* end case *))
          in
            lp ()
          end

  end
