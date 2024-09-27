signature LSP_CLIENT_HANDLER = sig
    structure Protocol : sig
        val logTrace : JSONRPC.request -> JSONRPC.unit
        val cancelRequest : JSONRPC.request -> JSONRPC.unit
        val progress : JSONRPC.request -> JSONRPC.unit
      end
    structure TextDocument : sig
        val publishDiagnostics : JSONRPC.request -> JSONRPC.unit
      end
    structure Telemetry : sig
        val event : JSONRPC.request -> JSONRPC.unit
      end
    structure Client : sig
        val registerCapability : JSONRPC.request -> JSONRPC.response
        val unregisterCapability : JSONRPC.request -> JSONRPC.response
      end
    structure Window : sig
        structure WorkDoneProgress : sig
            val create : JSONRPC.request -> JSONRPC.response
          end
        val showDocument : JSONRPC.request -> JSONRPC.response
        val showMessageRequest : JSONRPC.request -> JSONRPC.response
        val showMessage : JSONRPC.request -> JSONRPC.unit
        val logMessage : JSONRPC.request -> JSONRPC.unit
      end
    structure Workspace : sig
        structure CodeLens : sig
            val refresh : JSONRPC.request -> JSONRPC.response
          end
        structure Diagnostic : sig
            val refresh : JSONRPC.request -> JSONRPC.response
          end
        structure InlayHint : sig
            val refresh : JSONRPC.request -> JSONRPC.response
          end
        structure InlineValue : sig
            val refresh : JSONRPC.request -> JSONRPC.response
          end
        structure SemanticTokens : sig
            val refresh : JSONRPC.request -> JSONRPC.response
          end
        structure FoldingRange : sig
            val refresh : JSONRPC.request -> JSONRPC.response
          end
        val workspaceFolders : JSONRPC.request -> JSONRPC.response
        val configuration : JSONRPC.request -> JSONRPC.response
        val applyEdit : JSONRPC.request -> JSONRPC.response
      end
  end

