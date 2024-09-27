signature LSP_SERVER_HANDLER = sig
    structure Protocol : sig
        val setTrace : JSONRPC.request -> JSONRPC.unit
        val cancelRequest : JSONRPC.request -> JSONRPC.unit
        val progress : JSONRPC.request -> JSONRPC.unit
      end
    structure NotebookDocument : sig
        val didOpen : JSONRPC.request -> JSONRPC.unit
        val didChange : JSONRPC.request -> JSONRPC.unit
        val didSave : JSONRPC.request -> JSONRPC.unit
        val didClose : JSONRPC.request -> JSONRPC.unit
      end
    structure Window : sig
        structure WorkDoneProgress : sig
            val cancel : JSONRPC.request -> JSONRPC.unit
          end
      end
    structure DocumentLink : sig
        val resolve : JSONRPC.request -> JSONRPC.response
      end
    structure CodeLens : sig
        val resolve : JSONRPC.request -> JSONRPC.response
      end
    structure WorkspaceSymbol : sig
        val resolve : JSONRPC.request -> JSONRPC.response
      end
    structure CodeAction : sig
        val resolve : JSONRPC.request -> JSONRPC.response
      end
    structure CompletionItem : sig
        val resolve : JSONRPC.request -> JSONRPC.response
      end
    structure Server : sig
        val initialize : JSONRPC.request -> JSONRPC.response
        val shutdown : JSONRPC.request -> JSONRPC.response
        val initialized : JSONRPC.request -> JSONRPC.unit
        val exit : JSONRPC.request -> JSONRPC.unit
      end
    structure InlayHint : sig
        val resolve : JSONRPC.request -> JSONRPC.response
      end
    structure TypeHierarchy : sig
        val supertypes : JSONRPC.request -> JSONRPC.response
        val subtypes : JSONRPC.request -> JSONRPC.response
      end
    structure Workspace : sig
        val willCreateFiles : JSONRPC.request -> JSONRPC.response
        val willRenameFiles : JSONRPC.request -> JSONRPC.response
        val willDeleteFiles : JSONRPC.request -> JSONRPC.response
        val diagnostic : JSONRPC.request -> JSONRPC.response
        val symbol : JSONRPC.request -> JSONRPC.response
        val executeCommand : JSONRPC.request -> JSONRPC.response
        val didChangeWorkspaceFolders : JSONRPC.request -> JSONRPC.unit
        val didCreateFiles : JSONRPC.request -> JSONRPC.unit
        val didRenameFiles : JSONRPC.request -> JSONRPC.unit
        val didDeleteFiles : JSONRPC.request -> JSONRPC.unit
        val didChangeConfiguration : JSONRPC.request -> JSONRPC.unit
        val didChangeWatchedFiles : JSONRPC.request -> JSONRPC.unit
      end
    structure CallHierarchy : sig
        val incomingCalls : JSONRPC.request -> JSONRPC.response
        val outgoingCalls : JSONRPC.request -> JSONRPC.response
      end
    structure TextDocument : sig
        structure SemanticTokens : sig
            structure Full : sig
                val delta : JSONRPC.request -> JSONRPC.response
              end
            val full : JSONRPC.request -> JSONRPC.response
            val range : JSONRPC.request -> JSONRPC.response
          end
        val implementation : JSONRPC.request -> JSONRPC.response
        val typeDefinition : JSONRPC.request -> JSONRPC.response
        val documentColor : JSONRPC.request -> JSONRPC.response
        val colorPresentation : JSONRPC.request -> JSONRPC.response
        val foldingRange : JSONRPC.request -> JSONRPC.response
        val declaration : JSONRPC.request -> JSONRPC.response
        val selectionRange : JSONRPC.request -> JSONRPC.response
        val prepareCallHierarchy : JSONRPC.request -> JSONRPC.response
        val linkedEditingRange : JSONRPC.request -> JSONRPC.response
        val moniker : JSONRPC.request -> JSONRPC.response
        val prepareTypeHierarchy : JSONRPC.request -> JSONRPC.response
        val inlineValue : JSONRPC.request -> JSONRPC.response
        val inlayHint : JSONRPC.request -> JSONRPC.response
        val diagnostic : JSONRPC.request -> JSONRPC.response
        val inlineCompletion : JSONRPC.request -> JSONRPC.response
        val willSaveWaitUntil : JSONRPC.request -> JSONRPC.response
        val completion : JSONRPC.request -> JSONRPC.response
        val hover : JSONRPC.request -> JSONRPC.response
        val signatureHelp : JSONRPC.request -> JSONRPC.response
        val definition : JSONRPC.request -> JSONRPC.response
        val references : JSONRPC.request -> JSONRPC.response
        val documentHighlight : JSONRPC.request -> JSONRPC.response
        val documentSymbol : JSONRPC.request -> JSONRPC.response
        val codeAction : JSONRPC.request -> JSONRPC.response
        val codeLens : JSONRPC.request -> JSONRPC.response
        val documentLink : JSONRPC.request -> JSONRPC.response
        val formatting : JSONRPC.request -> JSONRPC.response
        val rangeFormatting : JSONRPC.request -> JSONRPC.response
        val rangesFormatting : JSONRPC.request -> JSONRPC.response
        val onTypeFormatting : JSONRPC.request -> JSONRPC.response
        val rename : JSONRPC.request -> JSONRPC.response
        val prepareRename : JSONRPC.request -> JSONRPC.response
        val didOpen : JSONRPC.request -> JSONRPC.unit
        val didChange : JSONRPC.request -> JSONRPC.unit
        val didClose : JSONRPC.request -> JSONRPC.unit
        val didSave : JSONRPC.request -> JSONRPC.unit
        val willSave : JSONRPC.request -> JSONRPC.unit
      end
  end

