structure SemanticTokenTypes = struct
    type t = string
    val kNamespace : string = "namespace"
    val kType : string = "type"
    val kClass : string = "class"
    val kEnum : string = "enum"
    val kInterface : string = "interface"
    val kStruct : string = "struct"
    val kTypeParameter : string = "typeParameter"
    val kParameter : string = "parameter"
    val kVariable : string = "variable"
    val kProperty : string = "property"
    val kEnumMember : string = "enumMember"
    val kEvent : string = "event"
    val kFunction : string = "function"
    val kMethod : string = "method"
    val kMacro : string = "macro"
    val kKeyword : string = "keyword"
    val kModifier : string = "modifier"
    val kComment : string = "comment"
    val kString : string = "string"
    val kNumber : string = "number"
    val kRegexp : string = "regexp"
    val kOperator : string = "operator"
    val kDecorator : string = "decorator"
  end
structure SemanticTokenModifiers = struct
    type t = string
    val kDeclaration : string = "declaration"
    val kDefinition : string = "definition"
    val kReadonly : string = "readonly"
    val kStatic : string = "static"
    val kDeprecated : string = "deprecated"
    val kAbstract : string = "abstract"
    val kAsync : string = "async"
    val kModification : string = "modification"
    val kDocumentation : string = "documentation"
    val kDefaultLibrary : string = "defaultLibrary"
  end
structure DocumentDiagnosticReportKind = struct
    type t = string
    val kFull : string = "full"
    val kUnchanged : string = "unchanged"
  end
structure ErrorCodes = struct
    type t = int
    val kParseError : int = ~32700
    val kInvalidRequest : int = ~32600
    val kMethodNotFound : int = ~32601
    val kInvalidParams : int = ~32602
    val kInternalError : int = ~32603
    val kServerNotInitialized : int = ~32002
    val kUnknownErrorCode : int = ~32001
  end
structure LSPErrorCodes = struct
    type t = int
    val kRequestFailed : int = ~32803
    val kServerCancelled : int = ~32802
    val kContentModified : int = ~32801
    val kRequestCancelled : int = ~32800
  end
structure FoldingRangeKind = struct
    type t = string
    val kComment : string = "comment"
    val kImports : string = "imports"
    val kRegion : string = "region"
  end
structure SymbolKind = struct
    type t = word
    val kFile : word = 0wx1
    val kModule : word = 0wx2
    val kNamespace : word = 0wx3
    val kPackage : word = 0wx4
    val kClass : word = 0wx5
    val kMethod : word = 0wx6
    val kProperty : word = 0wx7
    val kField : word = 0wx8
    val kConstructor : word = 0wx9
    val kEnum : word = 0wxA
    val kInterface : word = 0wxB
    val kFunction : word = 0wxC
    val kVariable : word = 0wxD
    val kConstant : word = 0wxE
    val kString : word = 0wxF
    val kNumber : word = 0wx10
    val kBoolean : word = 0wx11
    val kArray : word = 0wx12
    val kObject : word = 0wx13
    val kKey : word = 0wx14
    val kNull : word = 0wx15
    val kEnumMember : word = 0wx16
    val kStruct : word = 0wx17
    val kEvent : word = 0wx18
    val kOperator : word = 0wx19
    val kTypeParameter : word = 0wx1A
  end
structure SymbolTag = struct
    type t = word
    val kDeprecated : word = 0wx1
  end
structure UniquenessLevel = struct
    type t = string
    val kDocument : string = "document"
    val kProject : string = "project"
    val kGroup : string = "group"
    val kScheme : string = "scheme"
    val kGlobal : string = "global"
  end
structure MonikerKind = struct
    type t = string
    val kImport : string = "import"
    val kExport : string = "export"
    val kLocal : string = "local"
  end
structure InlayHintKind = struct
    type t = word
    val kType : word = 0wx1
    val kParameter : word = 0wx2
  end
structure MessageType = struct
    type t = word
    val kError : word = 0wx1
    val kWarning : word = 0wx2
    val kInfo : word = 0wx3
    val kLog : word = 0wx4
    val kDebug : word = 0wx5
  end
structure TextDocumentSyncKind = struct
    type t = word
    val kNone : word = 0wx0
    val kFull : word = 0wx1
    val kIncremental : word = 0wx2
  end
structure TextDocumentSaveReason = struct
    type t = word
    val kManual : word = 0wx1
    val kAfterDelay : word = 0wx2
    val kFocusOut : word = 0wx3
  end
structure CompletionItemKind = struct
    type t = word
    val kText : word = 0wx1
    val kMethod : word = 0wx2
    val kFunction : word = 0wx3
    val kConstructor : word = 0wx4
    val kField : word = 0wx5
    val kVariable : word = 0wx6
    val kClass : word = 0wx7
    val kInterface : word = 0wx8
    val kModule : word = 0wx9
    val kProperty : word = 0wxA
    val kUnit : word = 0wxB
    val kValue : word = 0wxC
    val kEnum : word = 0wxD
    val kKeyword : word = 0wxE
    val kSnippet : word = 0wxF
    val kColor : word = 0wx10
    val kFile : word = 0wx11
    val kReference : word = 0wx12
    val kFolder : word = 0wx13
    val kEnumMember : word = 0wx14
    val kConstant : word = 0wx15
    val kStruct : word = 0wx16
    val kEvent : word = 0wx17
    val kOperator : word = 0wx18
    val kTypeParameter : word = 0wx19
  end
structure CompletionItemTag = struct
    type t = word
    val kDeprecated : word = 0wx1
  end
structure InsertTextFormat = struct
    type t = word
    val kPlainText : word = 0wx1
    val kSnippet : word = 0wx2
  end
structure InsertTextMode = struct
    type t = word
    val kAsIs : word = 0wx1
    val kAdjustIndentation : word = 0wx2
  end
structure DocumentHighlightKind = struct
    type t = word
    val kText : word = 0wx1
    val kRead : word = 0wx2
    val kWrite : word = 0wx3
  end
structure CodeActionKind = struct
    type t = string
    val kEmpty : string = ""
    val kQuickFix : string = "quickfix"
    val kRefactor : string = "refactor"
    val kRefactorExtract : string = "refactor.extract"
    val kRefactorInline : string = "refactor.inline"
    val kRefactorRewrite : string = "refactor.rewrite"
    val kSource : string = "source"
    val kSourceOrganizeImports : string = "source.organizeImports"
    val kSourceFixAll : string = "source.fixAll"
  end
structure TraceValues = struct
    type t = string
    val kOff : string = "off"
    val kMessages : string = "messages"
    val kVerbose : string = "verbose"
  end
structure MarkupKind = struct
    type t = string
    val kPlainText : string = "plaintext"
    val kMarkdown : string = "markdown"
  end
structure InlineCompletionTriggerKind = struct
    type t = word
    val kInvoked : word = 0wx0
    val kAutomatic : word = 0wx1
  end
structure PositionEncodingKind = struct
    type t = string
    val kUTF8 : string = "utf-8"
    val kUTF16 : string = "utf-16"
    val kUTF32 : string = "utf-32"
  end
structure FileChangeType = struct
    type t = word
    val kCreated : word = 0wx1
    val kChanged : word = 0wx2
    val kDeleted : word = 0wx3
  end
structure WatchKind = struct
    type t = word
    val kCreate : word = 0wx1
    val kChange : word = 0wx2
    val kDelete : word = 0wx4
  end
structure DiagnosticSeverity = struct
    type t = word
    val kError : word = 0wx1
    val kWarning : word = 0wx2
    val kInformation : word = 0wx3
    val kHint : word = 0wx4
  end
structure DiagnosticTag = struct
    type t = word
    val kUnnecessary : word = 0wx1
    val kDeprecated : word = 0wx2
  end
structure CompletionTriggerKind = struct
    type t = word
    val kInvoked : word = 0wx1
    val kTriggerCharacter : word = 0wx2
    val kTriggerForIncompleteCompletions : word = 0wx3
  end
structure SignatureHelpTriggerKind = struct
    type t = word
    val kInvoked : word = 0wx1
    val kTriggerCharacter : word = 0wx2
    val kContentChange : word = 0wx3
  end
structure CodeActionTriggerKind = struct
    type t = word
    val kInvoked : word = 0wx1
    val kAutomatic : word = 0wx2
  end
structure FileOperationPatternKind = struct
    type t = string
    val kFile : string = "file"
    val kFolder : string = "folder"
  end
structure NotebookCellKind = struct
    type t = word
    val kMarkup : word = 0wx1
    val kCode : word = 0wx2
  end
structure ResourceOperationKind = struct
    type t = string
    val kCreate : string = "create"
    val kRename : string = "rename"
    val kDelete : string = "delete"
  end
structure FailureHandlingKind = struct
    type t = string
    val kAbort : string = "abort"
    val kTransactional : string = "transactional"
    val kTextOnlyTransactional : string = "textOnlyTransactional"
    val kUndo : string = "undo"
  end
structure PrepareSupportDefaultBehavior = struct
    type t = word
    val kIdentifier : word = 0wx1
  end
structure TokenFormat = struct
    type t = string
    val kRelative : string = "relative"
  end

