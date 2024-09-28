(* codegen.sml
 *
 * COPYRIGHT (c) 2023 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Generate JSON-RPC encoders/decoders for the LSP protocol.  We generate the following
 * files:
 *
 *      lsp-types.sml           -- contains the type definitions and enumeration
 *                                 structures
 *      lsp-server.sml
 *      lsp-client.sml
 *
 * TODO:
 *    - add option for including documentation in generated code
 *)

structure CodeGen : sig

    (*! which side of the protocol should be generated *)
    datatype side
      (*! generate serverToClient decoders and clientToServer encoders. *)
      = ClientSide
      (*! generate clientToServer decoders and serverToClient encoders. *)
      | ServerSide

    (* code-generation targets; these are used to support selective omission
     * of certain messages in the output.
     *)
    datatype target
      (* the parameter and result types and encoder/decoder functions *)
      = Coder
      (* the registration signature *)
      | Registration

    (*! options that control the generator *)
    type options = {
          (*! the directory for the generated output *)
          outputDir : string,
          (*! if true, generate code that allows for logging the message traffic. *)
          enableLogging : bool,
          (*! if true, then omit deprecated messages *)
          omitDeprecated : bool,
          (*! if true, then omit requests and notifications that are not final *)
          omitProposed : bool,
          (*! if true, then generate the type definitions *)
          types : bool,
          (*! specifies which side of the protocol is generated *)
          side : side,
          (*! a predicate for testing if generator should omit code *)
          omitMessage : side * target * string -> bool
        }

    val gen : MetaModel.t * options -> unit

  end = struct

    structure MM = MetaModel
    structure LTy = LSPTypes
    structure U = Util
    structure S = SML

    datatype side = ClientSide | ServerSide

    datatype target
      = Coder
      | Registration

    (*! options that control the generator *)
    type options = {
          (*! the directory for the generated output *)
          outputDir : string,
          (*! if true, generate code that allows for logging the message traffic. *)
          enableLogging : bool,
          (*! if true, then omit deprecated messages *)
          omitDeprecated : bool,
          (*! if true, then omit requests and notifications that are not final *)
          omitProposed : bool,
          (*! if true, then generate the type definitions *)
          types : bool,
          (*! specifies which side of the protocol is generated *)
          side : side,
          (*! a predicate for testing if generator should omit code *)
          omitMessage : side * target * string -> bool
        }

    fun canRecv (_, MM.Both) = true
      | canRecv (ClientSide, MM.ServerToClient) = true
      | canRecv (ServerSide, MM.ClientToServer) = true
      | canRecv _ = false

    fun canSend (_, MM.Both) = true
      | canSend (ClientSide, MM.ClientToServer) = true
      | canSend (ServerSide, MM.ServerToClient) = true
      | canSend _ = false

    fun filterReq sel pred (req : MM.request) = pred(sel req)
    fun filterNote sel pred (note : MM.notification) = pred(sel note)

    (* filter request messages by message direction *)
    fun filterReq pred (req : MM.request) = pred(#messageDirection req)

    (* filter notification messages by message direction *)
    fun filterNote pred (note : MM.notification) = pred(#messageDirection note)

    (* a request message is a JSON object with the following required fields:
     *
     *  "jsonrpc" : "2.0"
     *  "id" : <integer | string>
     *  "method" : <string>
     *
     * and an optional field
     *
     *  "params" : <array | object>
     *
     * The response to a request is either a message with the following fields:
     *
     *  "jsonrpc" : "2.0"
     *  "id" : <integer | string>
     *  "result" : <value>
     *
     * For a request, there are four possible functions that we can generate:
     * request input and output, and response input and output.
     *)

(* NOTE: this filtering is shallow; there are components, such as individual
 * enumeration entries that could be deprecated, but we preserve them for now.
 *)
    fun filterDeprecated (mm : MM.t) : MM.t = let
          fun keepReq (req : MM.request) = Option.isNone(#deprecated req)
          fun keepNote (note : MM.notification) = Option.isNone(#deprecated note)
          fun keepStruct (str : MM.data_struct) = Option.isNone(#deprecated str)
          fun keepEnum (enum : MM.enum) = Option.isNone(#deprecated enum)
          fun keepAlias (alias : MM.type_alias) = Option.isNone(#deprecated alias)
          in {
            metaData = #metaData mm,
            requests = List.filter keepReq (#requests mm),
            notifications = List.filter keepNote (#notifications mm),
            structures = List.filter keepStruct (#structures mm),
            enumerations = List.filter keepEnum (#enumerations mm),
            typeAliases = List.filter keepAlias (#typeAliases mm)
          } end

    (* a representation of nested modules *)
    datatype 'a module_nest = MOD of {
        name : string,
        items : 'a list,
        kids : 'a module_nest list
      }

    (* insert a specification into a module nest *)
    fun insert (root, mmName, items') = let
          fun ins (MOD{name, items, kids}, []) =
                MOD{name=name, items=items @ items', kids=kids}
            | ins (MOD{name, items, kids}, m::r) = let
                fun lp [] = [ins (MOD{name=m, items=[], kids=[]}, r)]
                  | lp ((kid as MOD{name, ...})::rkids) = if (name = m)
                      then ins (kid, r) :: rkids
                      else kid :: lp rkids
                in
                  MOD{name=name, items=items, kids=lp kids}
                end
          in
            ins(root, U.toStructName mmName)
          end

    (* generate the request-message-handler structure for one side of the protocol.
     * This structure is a module nest (we use the "/" symbol in the protocol
     * names to define the hierarchy) of structures; one per request/notification.
     * Specifically, for each request `R`, we generate
     *
     *    structure R = struct
     *        val name : string = "..."
     *        type params = { ... }
     *        type result = { ... }
     *          ... encode/decode functions ...
     *      end
     *
     * The "encode/decode" functions that are generated depend on the side of the
     * protocol (client or server) and the direction of the request.  If the request
     * can be received, then we generate the functions
     *
     *        fun decodeParams flds = ...
     *        fun encodeResult { ... } = ...
     *
     * and if the request can be sent, we generate the functions
     *
     *        fun encodeParams { ... } = ...
     *        fun decodeResult value = ...
     *
     * Likewise, for each notification `N`, we generate with the structure
     *
     *    structure N = struct
     *        val name : string = "..."
     *        type params = { ... }
     *          ... encode/decode functions ...
     *      end
     *
     * If the request can be received, then we generate the function
     *
     *        fun decodeParams flds = ...
     *
     * and if the request can be sent, we generate the function
     *
     *        fun encodeParams { ... } = ...
     *
     * Note that some requests/notifications can be sent and received by both sides
     * of the protocol.
     *)
    fun genRequestMessageStruct (mm : MM.t, flags : options, structName) =
          let
          (* the name component of a structure *)
          fun nameDec name = S.simpleVB("name", S.STRINGexp name)
          (* a type definition for the request/notification parameters type *)
          fun paramDec typs =
(* FIXME: actually generate the SML type *)
                S.TYPEdec([], "params", S.unitTy)
          (* a type definition for the request result type *)
          fun resultDec typs =
(* FIXME: actually generate the SML type *)
                S.TYPEdec([], "result", S.unitTy)
          (* a decoder for the request/notification parameters *)
          fun decodeParamsDec typs = let
(* FIXME: actually generate the decoder *)
                val body = S.failExp "UNIMPLEMENTED"
                in
                  S.simpleDec("decodeParams", ["params"], body)
                end
          (* an encoder for the request/notification parameters *)
          fun encodeParamsDec typs = let
(* FIXME: actually generate the encoder *)
                val body = S.failExp "UNIMPLEMENTED"
                in
                  S.simpleDec("encodeParams", ["params"], body)
                end
          (* an encoder for the request result *)
          fun encodeResultDec typ = let
(* FIXME: actually generate the encoder *)
                val body = S.failExp "UNIMPLEMENTED"
                in
                  S.simpleDec("encodeResult", ["result"], body)
                end
          (* an decoder for the request result *)
          fun decodeResultDec typ = let
(* FIXME: actually generate the decoder *)
                val body = S.failExp "UNIMPLEMENTED"
                in
                  S.simpleDec("decodeResult", ["result"], body)
                end
          (* create a structure for a request *)
          fun requestDecs (req : MM.request) =
                  nameDec (#method req) ::
                  paramDec (#params req) ::
                  resultDec (#result req) ::
                  (if canRecv(#side flags, #messageDirection req)
                    then [decodeParamsDec (#params req), encodeResultDec (#result req)]
                    else []) @
                  (if canSend(#side flags, #messageDirection req)
                    then [encodeParamsDec (#params req), decodeResultDec (#result req)]
                    else [])
          (* create a structure for a notification *)
          fun notifyDecs (note : MM.notification) =
                  nameDec (#method note) ::
                  paramDec (#params note) ::
                  (if canRecv(#side flags, #messageDirection note)
                    then [decodeParamsDec (#params note)]
                    else []) @
                  (if canSend(#side flags, #messageDirection note)
                    then [encodeParamsDec (#params note)]
                    else [])
          (* insert a request into the module nest *)
          fun insertReq (req : MM.request, nest) =
                if canRecv(#side flags, #messageDirection req)
                andalso not(#omitMessage flags (#side flags, Coder, #method req))
                  then insert (nest, #method req, requestDecs req)
                  else nest
          (* insert a notification into the module nest *)
          fun insertNote (note : MM.notification, nest) =
                if canRecv(#side flags, #messageDirection note)
                andalso not(#omitMessage flags (#side flags, Coder, #method note))
                  then insert (nest, #method note, notifyDecs note)
                  else nest
          val rootMod = MOD{name=structName, kids=[], items=[]}
          (* add requests to module nest *)
          val mNest = List.foldl insertReq rootMod (#requests mm)
          (* add notifications to module nest *)
          val mNest = List.foldl insertNote mNest (#notifications mm)
          (* convert the module nest to a signature *)
          val MOD{items, kids, ...} = mNest
          fun cvt (items, kids) = S.BASEstr(List.foldr cvtMod items kids)
          and cvtMod (MOD{name, items, kids}, decs) =
                S.STRdec(name, NONE, cvt (items, kids)) :: decs
          in
            S.DECtop(S.STRdec(structName, NONE, cvt(items, kids)))
          end

    (* each enumeration "E" in the meta-model is mapped to a structure with the form
     *
     *  structure E =
     *    struct
     *      type t = (* int | string *)
     *      val cEntry1 : t = ...
     *          ...
     *      val cEntryn : t = ...
     *    end
     *)
    fun genEnums (mm : MetaModel.t) = let
          fun strValue (MM.StrVal s) = S.STRINGexp s
            | strValue _ = raise Fail "invalid value for string-type enum entry"
          fun intValue (MM.NumVal n) = S.NUMexp(IntInf.toString n)
            | intValue _ = raise Fail "invalid value for int-type enum entry"
          fun wordValue (MM.NumVal n) =
                S.NUMexp("0wx" ^ Word.toString(Word.fromLargeInt n))
            | wordValue _ = raise Fail "invalid value for uint-type enum entry"
          fun genEnum (e : MM.enum) = let
                val (ty, toVal) = (case #rep e
                       of MM.ER_String => (SML.stringTy, strValue)
                        | MM.ER_Integer => (SML.intTy, intValue)
                        | MM.ER_UInteger => (SML.wordTy, wordValue)
                      (* end case *))
                fun mkDef (entry : MM.enum_entry) =
                      S.VALdec(
                        S.CONSTRAINTpat(S.IDpat("k" ^ U.toConName(#name entry)), ty),
                        toVal(#value entry))
                in
                  S.STRdec(
                    Atom.toString(#name e),
                    NONE,
                    S.BASEstr(
                      S.TYPEdec([], "t", ty) ::
                      List.map mkDef (#values e)))
                end
          in
            List.map genEnum (#enumerations mm)
          end

    fun genTypes (mm : MetaModel.t, info : Analyze.info) () = let
          in
(* FIXME: the enum structures should be substructures *)
            S.SEQtop(List.map S.DECtop (genEnums mm))
          end

    fun genClientCode (mm, flags, info : Analyze.info) () = let
          val reqStruct = genRequestMessageStruct (mm, flags, "LSPClient")
          in
            reqStruct
          end

    fun genServerCode (mm, flags, info : Analyze.info) () = let
          val reqStruct = genRequestMessageStruct (mm, flags, "LSPServer")
          in
            reqStruct
          end

    fun gen (mm : MetaModel.t, flags : options) = let
          (* prettyprint the generated declarations to an output file *)
          fun withFile fname (gen : unit -> S.top_decl) = let
                val outS = TextIO.openOut (OS.Path.concat(#outputDir flags, fname))
                val ppS = TextIOPP.openOut{dst=outS, wid=90}
                val output = PrintSML.output ppS
                in
(* TODO: file header *)
                  output (gen ());
                  (* all done; close the output *)
                  TextIOPP.closeStream ppS;
                  TextIO.closeOut outS
                end
          (* conditionally omit deprecated messages from the meta model *)
          val mm = if #omitDeprecated flags then filterDeprecated mm else mm
(* TODO: omit proposed *)
          val info = Analyze.analyze mm
          in
            if (#types flags)
              then withFile "lsp-types.sml" (genTypes (mm, info))
              else ();
            case (#side flags)
             of ClientSide =>
                  withFile "lsp-client.sml" (genClientCode (mm, flags, info))
              | ServerSide =>
                  withFile "lsp-server.sml" (genServerCode (mm, flags, info))
            (* end case *)
          end

  end
