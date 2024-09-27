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

    local
      fun registerRequest name decodeParams encodeResult (SERVER{reqTbl, ...}, h) =
            STbl.insert reqTbl (name, requestHandler decodeParams encodeResult h)
      fun registerNotification name decodeParams (SERVER{reqTbl, ...}, h) =
            STbl.insert reqTbl (name, notifyHandler decodeParams h)
    in

    structure Register = struct
        structure TextDocument = struct
            structure Implementation = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Implementation.name
                          LSP.Server.TextDocument.Implementation.decodeParams
                          LSP.Server.TextDocument.Implementation.encodeResult
              end
            structure TypeDefinition = struct
                val register = registerRequest
                          LSP.Server.TextDocument.TypeDefinition.name
                          LSP.Server.TextDocument.TypeDefinition.decodeParams
                          LSP.Server.TextDocument.TypeDefinition.encodeResult
                val name = "textDocument/typeDefinition"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
            structure DocumentColor = struct
                val register = registerRequest
                          LSP.Server.TextDocument.DocumentColor.name
                          LSP.Server.TextDocument.DocumentColor.decodeParams
                          LSP.Server.TextDocument.DocumentColor.encodeResult
              end
            structure ColorPresentation = struct
                val register = registerRequest
                          LSP.Server.TextDocument.ColorPresentation.name
                          LSP.Server.TextDocument.ColorPresentation.decodeParams
                          LSP.Server.TextDocument.ColorPresentation.encodeResult
              end
            structure FoldingRange = struct
                val register = registerRequest
                          LSP.Server.TextDocument.FoldingRange.name
                          LSP.Server.TextDocument.FoldingRange.decodeParams
                          LSP.Server.TextDocument.FoldingRange.encodeResult
              end
            structure Declaration = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Declaration.name
                          LSP.Server.TextDocument.Declaration.decodeParams
                          LSP.Server.TextDocument.Declaration.encodeResult
              end
            structure SelectionRange = struct
                val register = registerRequest
                          LSP.Server.TextDocument.SelectionRange.name
                          LSP.Server.TextDocument.SelectionRange.decodeParams
                          LSP.Server.TextDocument.SelectionRange.encodeResult
              end
            structure PrepareCallHierarchy = struct
                val register = registerRequest
                          LSP.Server.TextDocument.PrepareCallHierarchy.name
                          LSP.Server.TextDocument.PrepareCallHierarchy.decodeParams
                          LSP.Server.TextDocument.PrepareCallHierarchy.encodeResult
              end
            structure SemanticTokens = struct
                structure Full = struct
                    structure Delta = struct
                      val register = registerRequest
                            LSP.Server.TextDocument.SemanticTokens.Full.Delta.name
                            LSP.Server.TextDocument.SemanticTokens.Full.Delta.decodeParams
                            LSP.Server.TextDocument.SemanticTokens.Full.Delta.encodeResult
                      end
                    val register = registerRequest
                              LSP.Server.TextDocument.SemanticTokens.Full.name
                              LSP.Server.TextDocument.SemanticTokens.Full.decodeParams
                              LSP.Server.TextDocument.SemanticTokens.Full.encodeResult
                  end
                structure Range = struct
                    val register = registerRequest
                              LSP.Server.TextDocument.SemanticTokens.Range.name
                              LSP.Server.TextDocument.SemanticTokens.Range.decodeParams
                              LSP.Server.TextDocument.SemanticTokens.Range.encodeResult
                  end
              end
            structure LinkedEditingRange = struct
                val register = registerRequest
                          LSP.Server.TextDocument.LinkedEditingRange.name
                          LSP.Server.TextDocument.LinkedEditingRange.decodeParams
                          LSP.Server.TextDocument.LinkedEditingRange.encodeResult
              end
            structure Moniker = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Moniker.name
                          LSP.Server.TextDocument.Moniker.decodeParams
                          LSP.Server.TextDocument.Moniker.encodeResult
              end
            structure PrepareTypeHierarchy = struct
                val register = registerRequest
                          LSP.Server.TextDocument.PrepareTypeHierarchy.name
                          LSP.Server.TextDocument.PrepareTypeHierarchy.decodeParams
                          LSP.Server.TextDocument.PrepareTypeHierarchy.encodeResult
              end
            structure InlineValue = struct
                val register = registerRequest
                          LSP.Server.TextDocument.InlineValue.name
                          LSP.Server.TextDocument.InlineValue.decodeParams
                          LSP.Server.TextDocument.InlineValue.encodeResult
              end
            structure InlayHint = struct
                val register = registerRequest
                          LSP.Server.TextDocument.InlayHint.name
                          LSP.Server.TextDocument.InlayHint.decodeParams
                          LSP.Server.TextDocument.InlayHint.encodeResult
              end
            structure Diagnostic = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Diagnostic.name
                          LSP.Server.TextDocument.Diagnostic.decodeParams
                          LSP.Server.TextDocument.Diagnostic.encodeResult
              end
            structure InlineCompletion = struct
                val register = registerRequest
                          LSP.Server.TextDocument.InlineCompletion.name
                          LSP.Server.TextDocument.InlineCompletion.decodeParams
                          LSP.Server.TextDocument.InlineCompletion.encodeResult
              end
            structure WillSaveWaitUntil = struct
                val register = registerRequest
                          LSP.Server.TextDocument.WillSaveWaitUntil.name
                          LSP.Server.TextDocument.WillSaveWaitUntil.decodeParams
                          LSP.Server.TextDocument.WillSaveWaitUntil.encodeResult
              end
            structure Completion = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Completion.name
                          LSP.Server.TextDocument.Completion.decodeParams
                          LSP.Server.TextDocument.Completion.encodeResult
              end
            structure Hover = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Hover.name
                          LSP.Server.TextDocument.Hover.decodeParams
                          LSP.Server.TextDocument.Hover.encodeResult
              end
            structure SignatureHelp = struct
                val register = registerRequest
                          LSP.Server.TextDocument.SignatureHelp.name
                          LSP.Server.TextDocument.SignatureHelp.decodeParams
                          LSP.Server.TextDocument.SignatureHelp.encodeResult
              end
            structure Definition = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Definition.name
                          LSP.Server.TextDocument.Definition.decodeParams
                          LSP.Server.TextDocument.Definition.encodeResult
              end
            structure References = struct
                val register = registerRequest
                          LSP.Server.TextDocument.References.name
                          LSP.Server.TextDocument.References.decodeParams
                          LSP.Server.TextDocument.References.encodeResult
              end
            structure DocumentHighlight = struct
                val register = registerRequest
                          LSP.Server.TextDocument.DocumentHighlight.name
                          LSP.Server.TextDocument.DocumentHighlight.decodeParams
                          LSP.Server.TextDocument.DocumentHighlight.encodeResult
              end
            structure DocumentSymbol = struct
                val register = registerRequest
                          LSP.Server.TextDocument.DocumentSymbol.name
                          LSP.Server.TextDocument.DocumentSymbol.decodeParams
                          LSP.Server.TextDocument.DocumentSymbol.encodeResult
              end
            structure CodeAction = struct
                val register = registerRequest
                          LSP.Server.TextDocument.CodeAction.name
                          LSP.Server.TextDocument.CodeAction.decodeParams
                          LSP.Server.TextDocument.CodeAction.encodeResult
              end
            structure CodeLens = struct
                val register = registerRequest
                          LSP.Server.TextDocument.CodeLens.name
                          LSP.Server.TextDocument.CodeLens.decodeParams
                          LSP.Server.TextDocument.CodeLens.encodeResult
              end
            structure DocumentLink = struct
                val register = registerRequest
                          LSP.Server.TextDocument.DocumentLink.name
                          LSP.Server.TextDocument.DocumentLink.decodeParams
                          LSP.Server.TextDocument.DocumentLink.encodeResult
              end
            structure Formatting = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Formatting.name
                          LSP.Server.TextDocument.Formatting.decodeParams
                          LSP.Server.TextDocument.Formatting.encodeResult
              end
            structure RangeFormatting = struct
                val register = registerRequest
                          LSP.Server.TextDocument.RangeFormatting.name
                          LSP.Server.TextDocument.RangeFormatting.decodeParams
                          LSP.Server.TextDocument.RangeFormatting.encodeResult
              end
            structure RangesFormatting = struct
                val register = registerRequest
                          LSP.Server.TextDocument.RangesFormatting.name
                          LSP.Server.TextDocument.RangesFormatting.decodeParams
                          LSP.Server.TextDocument.RangesFormatting.encodeResult
              end
            structure OnTypeFormatting = struct
                val register = registerRequest
                          LSP.Server.TextDocument.OnTypeFormatting.name
                          LSP.Server.TextDocument.OnTypeFormatting.decodeParams
                          LSP.Server.TextDocument.OnTypeFormatting.encodeResult
              end
            structure Rename = struct
                val register = registerRequest
                          LSP.Server.TextDocument.Rename.name
                          LSP.Server.TextDocument.Rename.decodeParams
                          LSP.Server.TextDocument.Rename.encodeResult
              end
            structure PrepareRename = struct
                val register = registerRequest
                          LSP.Server.TextDocument.PrepareRename.name
                          LSP.Server.TextDocument.PrepareRename.decodeParams
                          LSP.Server.TextDocument.PrepareRename.encodeResult
              end
            structure DidOpen = struct
                val register = registerNotification
                          LSP.Server.TextDocument.DidOpen.name
                          LSP.Server.TextDocument.DidOpen.decodeParams
              end
            structure DidChange = struct
                val register = registerNotification
                          LSP.Server.TextDocument.DidChange.name
                          LSP.Server.TextDocument.DidChange.decodeParams
              end
            structure DidClose = struct
                val register = registerNotification
                          LSP.Server.TextDocument.DidClose.name
                          LSP.Server.TextDocument.DidClose.decodeParams
              end
            structure DidSave = struct
                val register = registerNotification
                          LSP.Server.TextDocument.DidSave.name
                          LSP.Server.TextDocument.DidSave.decodeParams
              end
            structure WillSave = struct
                val register = registerNotification
                          LSP.Server.TextDocument.WillSave.name
                          LSP.Server.TextDocument.WillSave.decodeParams
              end
          end
        structure CallHierarchy = struct
            structure IncomingCalls = struct
                val register = registerRequest
                      LSP.Server.CallHierarchy.IncomingCalls.name
                      LSP.Server.CallHierarchy.IncomingCalls.decodeParams
                      LSP.Server.CallHierarchy.IncomingCalls.encodeResult
              end
            structure OutgoingCalls = struct
                val register = registerRequest
                      LSP.Server.CallHierarchy.OutgoingCalls.name
                      LSP.Server.CallHierarchy.OutgoingCalls.decodeParams
                      LSP.Server.CallHierarchy.OutgoingCalls.encodeResult
              end
          end
        structure Workspace = struct
            structure WillCreateFiles = struct
                val register = registerRequest
                      LSP.Server.Workspace.WillCreateFiles.name
                      LSP.Server.Workspace.WillCreateFiles.decodeParams
                      LSP.Server.Workspace.WillCreateFiles.encodeResult
              end
            structure WillRenameFiles = struct
                val register = registerRequest
                      LSP.Server.Workspace.WillRenameFiles.name
                      LSP.Server.Workspace.WillRenameFiles.decodeParams
                      LSP.Server.Workspace.WillRenameFiles.encodeResult
              end
            structure WillDeleteFiles = struct
                val register = registerRequest
                      LSP.Server.Workspace.WillDeleteFiles.name
                      LSP.Server.Workspace.WillDeleteFiles.decodeParams
                      LSP.Server.Workspace.WillDeleteFiles.encodeResult
              end
            structure Diagnostic = struct
                val register = registerRequest
                      LSP.Server.Workspace.Diagnostic.name
                      LSP.Server.Workspace.Diagnostic.decodeParams
                      LSP.Server.Workspace.Diagnostic.encodeResult
              end
            structure Symbol = struct
                val register = registerRequest
                      LSP.Server.Workspace.Symbol.name
                      LSP.Server.Workspace.Symbol.decodeParams
                      LSP.Server.Workspace.Symbol.encodeResult
              end
            structure ExecuteCommand = struct
                val register = registerRequest
                      LSP.Server.Workspace.ExecuteCommand.name
                      LSP.Server.Workspace.ExecuteCommand.decodeParams
                      LSP.Server.Workspace.ExecuteCommand.encodeResult
              end
            structure DidChangeWorkspaceFolders = struct
                val register = registerNotification
                      LSP.Server.Workspace.DidChangeWorkspaceFolders.name
                      LSP.Server.Workspace.DidChangeWorkspaceFolders.decodeParams
              end
            structure DidCreateFiles = struct
                val register = registerNotification
                      LSP.Server.Workspace.DidCreateFiles.name
                      LSP.Server.Workspace.DidCreateFiles.decodeParams
              end
            structure DidRenameFiles = struct
                val register = registerNotification
                      LSP.Server.Workspace.DidRenameFiles.name
                      LSP.Server.Workspace.DidRenameFiles.decodeParams
              end
            structure DidDeleteFiles = struct
                val register = registerNotification
                      LSP.Server.Workspace.DidDeleteFiles.name
                      LSP.Server.Workspace.DidDeleteFiles.decodeParams
              end
            structure DidChangeConfiguration = struct
                val register = registerNotification
                      LSP.Server.Workspace.DidChangeConfiguration.name
                      LSP.Server.Workspace.DidChangeConfiguration.decodeParams
              end
            structure DidChangeWatchedFiles = struct
                val register = registerNotification
                      LSP.Server.Workspace.DidChangeWatchedFiles.name
                      LSP.Server.Workspace.DidChangeWatchedFiles.decodeParams
              end
          end
        structure TypeHierarchy = struct
            structure Supertypes = struct
                val register = registerRequest
                      LSP.Server.TypeHierarchy.Supertypes.name
                      LSP.Server.TypeHierarchy.Supertypes.decodeParams
                      LSP.Server.TypeHierarchy.Supertypes.encodeResult
              end
            structure Subtypes = struct
                val register = registerRequest
                      LSP.Server.TypeHierarchy.Subtypes.name
                      LSP.Server.TypeHierarchy.Subtypes.decodeParams
                      LSP.Server.TypeHierarchy.Subtypes.encodeResult
              end
          end
        structure InlayHint = struct
            structure Resolve = struct
                val register = registerRequest
                      LSP.Server.InlayHint.Resolve.name
                      LSP.Server.InlayHint.Resolve.decodeParams
                      LSP.Server.InlayHint.Resolve.encodeResult
              end
          end
        (* We omit the "Server" structure, since server messages are handled
         * as special cases (i.e., initialize, shutdown, initialized, and exit
         *)
        structure CompletionItem = struct
            structure Resolve = struct
                val register = registerRequest
                      LSP.Server.CompletionItem.Resolve.name
                      LSP.Server.CompletionItem.Resolve.decodeParams
                      LSP.Server.CompletionItem.Resolve.encodeResult
              end
          end
        structure CodeAction = struct
            structure Resolve = struct
                val register = registerRequest
                      LSP.Server.CodeAction.Resolve.name
                      LSP.Server.CodeAction.Resolve.decodeParams
                      LSP.Server.CodeAction.Resolve.encodeResult
              end
          end
        structure WorkspaceSymbol = struct
            structure Resolve = struct
                val register = registerRequest
                      LSP.Server.WorkspaceSymbol.Resolve.name
                      LSP.Server.WorkspaceSymbol.Resolve.decodeParams
                      LSP.Server.WorkspaceSymbol.Resolve.encodeResult
              end
          end
        structure CodeLens = struct
            structure Resolve = struct
                val register = registerRequest
                      LSP.Server.CodeLens.Resolve.name
                      LSP.Server.CodeLens.Resolve.decodeParams
                      LSP.Server.CodeLens.Resolve.encodeResult
              end
          end
        structure DocumentLink = struct
            structure Resolve = struct
                val register = registerRequest
                      LSP.Server.DocumentLink.Resolve.name
                      LSP.Server.DocumentLink.Resolve.decodeParams
                      LSP.Server.DocumentLink.Resolve.encodeResult
              end
          end
        structure Window = struct
            structure WorkDoneProgress = struct
                structure Cancel = struct
                    val register = registerNotification
                          LSP.Server.Window.WorkDoneProgress.Cancel.name
                          LSP.Server.Window.WorkDoneProgress.Cancel.decodeParams
                  end
              end
          end
        structure NotebookDocument = struct
            structure DidOpen = struct
                val register = registerNotification
                      LSP.Server.NotebookDocument.DidOpen.name
                      LSP.Server.NotebookDocument.DidOpen.decodeParams
              end
            structure DidChange = struct
                val register = registerNotification
                      LSP.Server.NotebookDocument.DidChange.name
                      LSP.Server.NotebookDocument.DidChange.decodeParams
              end
            structure DidSave = struct
                val register = registerNotification
                      LSP.Server.NotebookDocument.DidSave.name
                      LSP.Server.NotebookDocument.DidSave.decodeParams
              end
            structure DidClose = struct
                val register = registerNotification
                      LSP.Server.NotebookDocument.DidClose.name
                      LSP.Server.NotebookDocument.DidClose.decodeParams
              end
          end
        structure Protocol = struct
            structure SetTrace = struct
                val register = registerNotification
                      LSP.Server.Protocol.SetTrace.name
                      LSP.Server.Protocol.SetTrace.decodeParams
              end
            structure CancelRequest = struct
                val register = registerNotification
                      LSP.Server.Protocol.CancelRequest.name
                      LSP.Server.Protocol.CancelRequest.decodeParams
              end
            structure Progress = struct
                val register = registerNotification
                      LSP.Server.Protocol.Progress.name
                      LSP.Server.Protocol.Progress.decodeParams
              end
          end
      end (* structure Register *)

    end (* local *)

  end
