# The Standard ML LSP Kit

**Work in Progress**
As it currently stands, this system is quite incomplete with many holes.

## Overview

This repository contains infrastructure for writing [https://microsoft.github.io/language-server-protocol/](**LSP**)
servers (and possibly clients) in Standard ML (**SML**).  It has two parts:
1. code for generating type declarations and message decoders/encoders from a =
   machine readable specification of the protocol
2. Implementations of the protocol transport layer that can be wrapped around a
   language-specific server.

In this implementation we use the term "*Language Server*" to describe the
language-specific implementation of the handlers for the various **LSP** requests
and notifications, and the term "*LSP Server*" to describe the language server
wrapped with code that handles the communication between the server and client.

## Road map

All of the code is in the `src` directory.

* `src/generator` -- this directory holds the generator part of the LSP Kit
  * `src/generator/lsp-gen` -- the implementation of the generator
  * `src/generator/lsp-gen/fragments` -- fragments of **SML** code that get inserted
    into the generated files.
  * `src/generator/lsp-gen/out` -- directory for dumping the output of the generator.
  * `src/generator/meta-model` -- this directory contains copies of the so-called
    "meta-model" that specifies **LSP**.
    * `src/generator/meta-model/3.17` -- Version 3.17 of the protocol (the current
      stable version).
    * `src/generator/meta-model/3.18` -- Version 3.18 of the protocol, which is
      under development.
* `src/lsp-server` -- this library implements the transport layer for a LSP
  server.
  * `src/lsp-server/test-messages` -- files containing various **LSP** messages
    that are used to test message decoding.
  * `src/lsp-server/json-rpc` -- a library for working with
    (https://www.jsonrpc.org)[**JSON RPC**], which is the encoding for **LSP**.
    Note that this library is under development as part of the
    (https://smlnj.org/doc/smlnj-lib)[**SML of NJ Library**] and will be removed
    once it is part of the **SML/NJ** distribution.

## TODO

There is a lot of work to do, here is a partial list.

* the generator code can load the meta-model file, but does not support
  much in the way of code generation yet.  Specifically, we need to do
  the following:
  * generate **SML** types for the **LSP**
  * for each request `R`, generate a structure with the signature
    ```sml
    structure R : sig
        val name : string
        type params = { ... }
        type result = { ... }
        val decodeParams : (string * JSONRPC.value) list -> params
        val encodeResult : result -> JSON.value
      end
    ```
  * for each notification `N`, generate a structure with the signature
    ```sml
    structure N : sig
        val name : string
        type params = { ... }
        val decodeParams : (string * JSONRPC.value) list -> params
      end
    ```
  * generate a signature for the registration functions implemented
    in the server
* Write a CML version of the server infrastructure
* build a demo server; I'm thinking of a server for typed PCF
