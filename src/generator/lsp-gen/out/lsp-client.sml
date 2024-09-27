structure LSPClient = struct
    structure Protocol = struct
        structure LogTrace = struct
            val name = "$/logTrace"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure CancelRequest = struct
            val name = "$/cancelRequest"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure Progress = struct
            val name = "$/progress"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure TextDocument = struct
        structure PublishDiagnostics = struct
            val name = "textDocument/publishDiagnostics"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Telemetry = struct
        structure Event = struct
            val name = "telemetry/event"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Client = struct
        structure RegisterCapability = struct
            val name = "client/registerCapability"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure UnregisterCapability = struct
            val name = "client/unregisterCapability"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Window = struct
        structure WorkDoneProgress = struct
            structure Create = struct
                val name = "window/workDoneProgress/create"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure ShowDocument = struct
            val name = "window/showDocument"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure ShowMessageRequest = struct
            val name = "window/showMessageRequest"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure ShowMessage = struct
            val name = "window/showMessage"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure LogMessage = struct
            val name = "window/logMessage"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Workspace = struct
        structure CodeLens = struct
            structure Refresh = struct
                val name = "workspace/codeLens/refresh"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure Diagnostic = struct
            structure Refresh = struct
                val name = "workspace/diagnostic/refresh"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure InlayHint = struct
            structure Refresh = struct
                val name = "workspace/inlayHint/refresh"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure InlineValue = struct
            structure Refresh = struct
                val name = "workspace/inlineValue/refresh"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure SemanticTokens = struct
            structure Refresh = struct
                val name = "workspace/semanticTokens/refresh"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure FoldingRange = struct
            structure Refresh = struct
                val name = "workspace/foldingRange/refresh"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure WorkspaceFolders = struct
            val name = "workspace/workspaceFolders"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Configuration = struct
            val name = "workspace/configuration"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure ApplyEdit = struct
            val name = "workspace/applyEdit"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
  end

