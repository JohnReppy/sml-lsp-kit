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
