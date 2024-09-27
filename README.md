# The Standard ML LSP Kit

**Work in Progress**

## Overview

This repository contains infrastructure for writing [https://microsoft.github.io/language-server-protocol/](**LSP**)
servers (and possibly clients) in Standard ML (**SML**).  It has two parts:
1. code for generating type declarations and message decoders/encoders from a machine readable specification of the protocol
2. Implementations of the protocol transport layer that can be wrapped around a language-specific server.

In this implementation we use the term "*Language Server*" to describe the language-specific implementation of
the handlers for the various **LSP** requests and notifications, and the term "*LSP Server*" to describe the
language server wrapped with code that handles the communication between the server and client.
