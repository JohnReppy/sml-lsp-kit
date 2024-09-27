(* language-server.sig
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * A "Language Server" is an abstract interface to a language-specific code
 * for handling the various client requests and notifications of the LSP
 * protocol.  We use the term "LSP Server" to describe the combination of
 * a language server with the code that handles the LSP transport.
 *)

signature LANGUAGE_SERVER = sig

    type t

    datatype workspace
      = RootPath of string
      | RootURI of string
      | WorkspaceFolders of WorkspaceFolder.t list
      | NullWorkspace

    (** create a language server *)
    val create : unit -> t

    (** the required handler for the "initialize" request.  This message is the
     ** first message from the client to server and will only be sent once.
     **)
    val initialize : t * {
            processId : int option,
            clientInfo : {name : string, version : string option} option,
            locale : string option,
            workspace : workspace option,
            initializationOptions : JSON.value option,
            capabilities: ClientCapabilities.t,
            trace : TraceValue.t option,
          } -> {
            capabilities : ServerCapabilities.t,
            serverInfo : { name : string, version : string option } option
          } ServerResult.t

    (** the required handler for the "initialized" notification.  This notification
     ** is sent following the client' receipt of the response to the "initialize"
     ** request.
     **)
    val initialized : unit -> unit

    (** handle a "shutdown" request. If there is an error during shutdown, this function
     ** should return an `Error` value with the `kRequestFailed` code and appropriate
     ** message.
     **)
    val shutdown : t -> unit ServerResult.t

    (** handle an "exit" notification".  Under normal operation, this function is called
     ** after a "shutdown" request has been processed, but the language server should
     ** handle the case were `exit` is called by itself.
     **)
    val exit : t -> unit

  end
