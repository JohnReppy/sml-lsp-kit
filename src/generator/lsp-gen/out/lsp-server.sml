structure LSPServer = struct
    structure TextDocument = struct
        structure Implementation = struct
            val name = "textDocument/implementation"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure TypeDefinition = struct
            val name = "textDocument/typeDefinition"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure DocumentColor = struct
            val name = "textDocument/documentColor"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure ColorPresentation = struct
            val name = "textDocument/colorPresentation"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure FoldingRange = struct
            val name = "textDocument/foldingRange"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Declaration = struct
            val name = "textDocument/declaration"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure SelectionRange = struct
            val name = "textDocument/selectionRange"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure PrepareCallHierarchy = struct
            val name = "textDocument/prepareCallHierarchy"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure SemanticTokens = struct
            structure Full = struct
                structure Delta = struct
                    val name = "textDocument/semanticTokens/full/delta"
                    type params = unit
                    type result = unit
                    fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                    fun encodeResult result = raise (Fail "UNIMPLEMENTED")
                  end
                val name = "textDocument/semanticTokens/full"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
            structure Range = struct
                val name = "textDocument/semanticTokens/range"
                type params = unit
                type result = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
                fun encodeResult result = raise (Fail "UNIMPLEMENTED")
              end
          end
        structure LinkedEditingRange = struct
            val name = "textDocument/linkedEditingRange"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Moniker = struct
            val name = "textDocument/moniker"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure PrepareTypeHierarchy = struct
            val name = "textDocument/prepareTypeHierarchy"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure InlineValue = struct
            val name = "textDocument/inlineValue"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure InlayHint = struct
            val name = "textDocument/inlayHint"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Diagnostic = struct
            val name = "textDocument/diagnostic"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure InlineCompletion = struct
            val name = "textDocument/inlineCompletion"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure WillSaveWaitUntil = struct
            val name = "textDocument/willSaveWaitUntil"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Completion = struct
            val name = "textDocument/completion"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Hover = struct
            val name = "textDocument/hover"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure SignatureHelp = struct
            val name = "textDocument/signatureHelp"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Definition = struct
            val name = "textDocument/definition"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure References = struct
            val name = "textDocument/references"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure DocumentHighlight = struct
            val name = "textDocument/documentHighlight"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure DocumentSymbol = struct
            val name = "textDocument/documentSymbol"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure CodeAction = struct
            val name = "textDocument/codeAction"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure CodeLens = struct
            val name = "textDocument/codeLens"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure DocumentLink = struct
            val name = "textDocument/documentLink"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Formatting = struct
            val name = "textDocument/formatting"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure RangeFormatting = struct
            val name = "textDocument/rangeFormatting"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure RangesFormatting = struct
            val name = "textDocument/rangesFormatting"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure OnTypeFormatting = struct
            val name = "textDocument/onTypeFormatting"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Rename = struct
            val name = "textDocument/rename"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure PrepareRename = struct
            val name = "textDocument/prepareRename"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure DidOpen = struct
            val name = "textDocument/didOpen"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidChange = struct
            val name = "textDocument/didChange"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidClose = struct
            val name = "textDocument/didClose"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidSave = struct
            val name = "textDocument/didSave"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure WillSave = struct
            val name = "textDocument/willSave"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure CallHierarchy = struct
        structure IncomingCalls = struct
            val name = "callHierarchy/incomingCalls"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure OutgoingCalls = struct
            val name = "callHierarchy/outgoingCalls"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Workspace = struct
        structure WillCreateFiles = struct
            val name = "workspace/willCreateFiles"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure WillRenameFiles = struct
            val name = "workspace/willRenameFiles"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure WillDeleteFiles = struct
            val name = "workspace/willDeleteFiles"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Diagnostic = struct
            val name = "workspace/diagnostic"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Symbol = struct
            val name = "workspace/symbol"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure ExecuteCommand = struct
            val name = "workspace/executeCommand"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure DidChangeWorkspaceFolders = struct
            val name = "workspace/didChangeWorkspaceFolders"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidCreateFiles = struct
            val name = "workspace/didCreateFiles"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidRenameFiles = struct
            val name = "workspace/didRenameFiles"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidDeleteFiles = struct
            val name = "workspace/didDeleteFiles"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidChangeConfiguration = struct
            val name = "workspace/didChangeConfiguration"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidChangeWatchedFiles = struct
            val name = "workspace/didChangeWatchedFiles"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure TypeHierarchy = struct
        structure Supertypes = struct
            val name = "typeHierarchy/supertypes"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Subtypes = struct
            val name = "typeHierarchy/subtypes"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure InlayHint = struct
        structure Resolve = struct
            val name = "inlayHint/resolve"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Server = struct
        structure Initialize = struct
            val name = "initialize"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Shutdown = struct
            val name = "shutdown"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
        structure Initialized = struct
            val name = "initialized"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure Exit = struct
            val name = "exit"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure CompletionItem = struct
        structure Resolve = struct
            val name = "completionItem/resolve"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure CodeAction = struct
        structure Resolve = struct
            val name = "codeAction/resolve"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure WorkspaceSymbol = struct
        structure Resolve = struct
            val name = "workspaceSymbol/resolve"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure CodeLens = struct
        structure Resolve = struct
            val name = "codeLens/resolve"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure DocumentLink = struct
        structure Resolve = struct
            val name = "documentLink/resolve"
            type params = unit
            type result = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
            fun encodeResult result = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Window = struct
        structure WorkDoneProgress = struct
            structure Cancel = struct
                val name = "window/workDoneProgress/cancel"
                type params = unit
                fun decodeParams params = raise (Fail "UNIMPLEMENTED")
              end
          end
      end
    structure NotebookDocument = struct
        structure DidOpen = struct
            val name = "notebookDocument/didOpen"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidChange = struct
            val name = "notebookDocument/didChange"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidSave = struct
            val name = "notebookDocument/didSave"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
        structure DidClose = struct
            val name = "notebookDocument/didClose"
            type params = unit
            fun decodeParams params = raise (Fail "UNIMPLEMENTED")
          end
      end
    structure Protocol = struct
        structure SetTrace = struct
            val name = "$/setTrace"
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
  end

