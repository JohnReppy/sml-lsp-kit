# LSP for SML

This repository contains a program for generating encoders/decoders for
the **Language Server Protocol** (**LSP**) from the so-called "Meta Model."
The source for the specifications used in this project is

> https://github.com/microsoft/language-server-protocol/tree/gh-pages/_specifications/lsp

## Meta Model Sources

The meta model for the current and next LSP versions (3.17 and 3.18,
respectively) are contained in the corresponding subdirectories.
The meta model consists of three files:

* [`metaModel.json`](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/metaModel/metaModel.json):
  The actual meta model for the LSP specification
* [`metaModel.ts`](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/metaModel/metaModel.ts):
  A TypeScript file defining the data types that make up the meta model.
* [`metaModel.schema.json`](https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/metaModel/metaModel.schema.json):
  A JSON schema file defining the data types that make up the meta model.
  This file can be used to generate code to read the meta model JSON file.

We have replaced tab characters with two spaces in our copies of these files to make
them more readable.

## The Generator

The `lsp-gen` subdirectory contains **Standard ML** code for loading the meta model
from the `metaModel.json` file and then generating the **SML** type definitions,
encoders, and decoders that implement the **LSP**.

## Generated Code

The main purpose of the generator is to generate **SML** type definitions and
the functions that map between these types and **JSON RPC** messages.  The **LSP**
messages (requests and notifications) have a hierachical structure (*e.g.*, messages
that target the document share a common "``textDocument/``" prefix).  We map this
hierachy to nested **SML** modules.  For each request message `R` there will be
a structure

```sml
structure R = struct
    type params = ...
    type result = ...
    val decodeParams : (string * JSON.value) list -> params
    val encodeParams : params -> JSON.value
    val decodeResult : JSON.value -> result
    val encodeResult : result -> JSON.value
  end
```

The encode and decode functions are included when required to implement the
requested side of the protocol; *e.g.*, if the message is sent, but not received,
then the `decodeParams` and `encodeResult` functions are omitted.  For **LSP**
notifications, there is no `result` type or supporting functions.  In some cases,
the `params` type will be a datatype.

We also generate **SML** structures for the other named types in the protocol.
For a named type `T`, we generate

```sml
structure T = struct
    type t = ...
    val encode : JSON.value -> t
    val decode : t -> JSON.value
  end
```

