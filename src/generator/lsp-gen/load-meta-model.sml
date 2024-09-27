(* load-meta-model.sml
 *
 * COPYRIGHT (c) 2023 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Load the LSP "meta model" from a JSON file.
 *)

structure LoadMetaModel : sig

    val load : string -> MetaModel.t

  end = struct

    structure J = JSON
    structure JU = JSONUtil
    structure MM = MetaModel

    (* print a JSON value (for debugging purposes) *)
    val prValue = JSONPrinter.print' {strm=TextIO.stdOut, pretty=true}

    datatype edge = datatype JU.edge

    fun getString (v, path) = JU.asString(JU.get(v, path))

    fun lookupField v fld = (case JU.findField v fld
           of NONE => raise Fail(concat["field '", fld, "' not found"])
            | SOME v => v
          (* end case *))

    fun lookupOptString (v, fld) = (case JU.findField v fld
           of NONE => NONE
            | SOME v => SOME(JU.asString v)
          (* end case *))

    (* get an optional boolean field, where abscence maps to `false` *)
    fun lookupOptBool (v, fld) = (case JU.findField v fld
           of NONE => false
            | SOME v => JU.asBool v
          (* end case *))

    (* a version of `arrayMap` that allows for optional fields (which map to the
     * empty list.
     *)
    fun optArrayMap getElem (v, fld) = (case JU.findField v fld
           of NONE => []
            | SOME arr => JU.arrayMap getElem arr
          (* end case *))

    (* convert a name (i.e., JSON string) to an atom *)
    fun asAtom v = Atom.atom(JU.asString v)

    (* the root JSON object in the meta model is an object with the
     * following fields:
     *   "metaData"             -- an object that specifies the protocol version
     *   "requests"             -- an array of request method-message descriptions
     *   "notifications"        -- an array of notification-message descriptions
     *   "structures"           -- an array of struct-type descriptions
     *   "enumerations"         -- an array of enumeration-type descriptions
     *   "typeAliases"          -- an array of defined type expressions
     *)
    fun loadJSON path = let
          val obj = JSONParser.parseFile path
          val field = lookupField obj
          in {
            md = field "metaData",
            reqs = field "requests",
            notifs = field "notifications",
            structs = field "structures",
            enums = field "enumerations",
            tys = field "typeAliases"
          } end

    (* extract a map-key type from a JSON object *)
    fun getMapKeyType (v : JSON.value) : MM.map_key_ty = let
          val lookup = lookupField v
          in
            case JU.asString(lookup "kind")
             of "base" => (case JU.asString(lookup "name")
                   of "URI" => MM.T_Base MM.T_URI
                    | "DocumentUri" => MM.T_Base MM.T_DocumentUri
                    | "string" => MM.T_Base MM.T_String
                    | "integer" => MM.T_Base MM.T_Integer
                    | n => raise Fail(concat["invalid base map-key-type name '", n, "'"])
                  (* end case *))
              | "reference" => MM.T_Reference(asAtom(lookup "name"))
              | k => raise Fail(concat["unknown type kind '", k, "'"])
            (* end case *)
          end
(* DEBUG *)handle ex => raise ex

    (* extract a type description from a JSON object *)
    fun getType (v : JSON.value) : MM.typ = let
          val lookup = lookupField v
          fun cvtArray field getElem = JU.arrayMap getElem (lookup field)
          in
            case JU.asString(lookup "kind")
             of "base" => (case JU.asString(lookup "name")
                   of "URI" => MM.T_Base MM.T_URI
                    | "DocumentUri" => MM.T_Base MM.T_DocumentUri
                    | "integer" => MM.T_Base MM.T_Integer
                    | "uinteger" => MM.T_Base MM.T_UInteger
                    | "decimal" => MM.T_Base MM.T_Decimal
                    | "RegExp" => MM.T_Base MM.T_RegExp
                    | "string" => MM.T_Base MM.T_String
                    | "boolean" => MM.T_Base MM.T_Boolean
                    | "null" => MM.T_Base MM.T_Null
                    | n => raise Fail(concat["invalid base type name '", n, "'"])
                  (* end case *))
              | "reference" => MM.T_Reference(asAtom(lookup "name"))
              | "array" => MM.T_Array(getType(lookup "element"))
              | "map" => MM.T_Map{
                    key = getMapKeyType(lookup "key"),
                    value = getType(lookup "value")
                  }
              | "and" => MM.T_And(JU.arrayMap getType (lookup "items"))
              | "or" => MM.T_Or(JU.arrayMap getType (lookup "items"))
              | "tuple" => MM.T_Tuple(JU.arrayMap getType (lookup "items"))
              | "literal" => MM.T_StructureLiteral(getStructLit(lookup "value"))
              | "stringLiteral" => MM.T_StringLiteral(JU.asString(lookup "value"))
              | "integerLiteral" => MM.T_IntegerLiteral(JU.asIntInf(lookup "value"))
              | "booleanLiteral" => MM.T_BooleanLiteral(JU.asBool(lookup "value"))
              | k => raise Fail(concat["unknown type kind '", k, "'"])
            (* end case *)
          end
(* DEBUG *)handle ex => raise ex

    (* extract a property from a JSON object *)
    and getProperty (v : JSON.value) : MM.property = let
          val lookup = lookupField v
          in {
	    name = JU.asString(lookup "name"),
            ty = getType(lookup "type"),
            optional = lookupOptBool(v, "proposed"),
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end
(* DEBUG *)handle ex => raise ex

    and getStructure (v : JSON.value) : MM.data_struct = let
          val lookup = lookupField v
          in {
	    name = asAtom(lookup "name"),
            extends = optArrayMap getType (v, "extends"),
            mixins = optArrayMap getType (v, "mixins"),
            properties = JU.arrayMap getProperty (lookup "properties"),
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end
(* DEBUG *)handle ex => raise ex

    and getStructLit (v : JSON.value) : MM.struct_lit_ty = let
          val lookup = lookupField v
          in {
            properties = JU.arrayMap getProperty (lookup "properties"),
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end
(* DEBUG *)handle ex => raise ex

    fun getParams v = (case JU.findField v "params"
           of NONE => []
            | SOME(J.ARRAY vs) => List.map getType vs
            | SOME v => [getType v]
          (* end case *))


    fun getMsgDir (J.STRING "clientToServer") = MM.ClientToServer
      | getMsgDir (J.STRING "serverToClient") = MM.ServerToClient
      | getMsgDir (J.STRING "both") = MM.Both
      | getMsgDir _ = raise Fail "invalid message direction"

    (* get a request description from a JSON object *)
    fun getRequest (v : JSON.value) : MM.request = let
          val lookup = lookupField v
          fun getOptType fld = Option.map getType (JU.findField v fld)
          in {
            method = JU.asString(lookup "method"),
            params = getParams v,
            result = getType(lookup "result"),
            partialResult = getOptType "partialResult",
            errorData = getOptType "errorData",
            registrationMethod = lookupOptString(v, "registrationMethod"),
            registrationOptions = getOptType "registrationOptions",
            messageDirection = getMsgDir(lookup "messageDirection"),
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end

    (* get a notification description from a JSON object *)
    fun getNotification (v : JSON.value) : MM.notification = let
          val lookup = lookupField v
          fun getOptType fld = Option.map getType (JU.findField v fld)
          in {
            method = JU.asString(lookup "method"),
            params = getParams v,
            registrationMethod = lookupOptString(v, "registrationMethod"),
            registrationOptions = getOptType "registrationOptions",
            messageDirection = getMsgDir(lookup "messageDirection"),
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end
(* DEBUG *)handle ex => raise ex

    (* extract an enumeration entry from a JSON object *)
    fun getEnumValue (v : JSON.value) : MM.enum_entry = let
          val lookup = lookupField v
          val name = JU.asString(lookup "name")
          val value = (case lookup "value"
                 of J.INT n => MM.NumVal n
                  | J.STRING s => MM.StrVal s
                  | _ => raise Fail "unexpected type of value"
                (* end case *))
          in {
            name = name,
            value = value,
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end
(* DEBUG *)handle ex => raise ex

    (* extract an enumeration definition from a JSON object *)
    fun getEnum (v : JSON.value) : MM.enum = let
          val lookup = lookupField v
          val name = asAtom(lookup "name")
          val rep = (case JU.findField (lookup "type") "name"
                 of SOME(J.STRING "string") => MM.ER_String
                  | SOME(J.STRING "integer") => MM.ER_Integer
                  | SOME(J.STRING "uinteger") => MM.ER_UInteger
                  | _ => raise Fail(concat[
                        "invalid 'type' field in enum element '", Atom.toString name, "'"
                      ])
                (* end case *))
          in {
            name = name,
            rep = rep,
            values = JU.arrayMap getEnumValue (lookup "values"),
            supportsCustomValues = lookupOptBool(v, "supportsCustomValues"),
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end
(* DEBUG *)handle ex => raise ex

    (* extract a type alias from a JSON object *)
    fun getTypeAlias (v : JSON.value) : MM.type_alias = let
          val lookup = lookupField v
          in {
            name = asAtom(lookup "name"),
            ty = getType (lookup "type"),
            documentation = lookupOptString(v, "documentation"),
            since = lookupOptString(v, "since"),
            proposed = lookupOptBool(v, "proposed"),
            deprecated = lookupOptString(v, "deprecated")
          } end
(* DEBUG *)handle ex => raise ex

    fun getMetaData v = {version = JU.asString(lookupField v "version")}

    fun load file = if OS.FileSys.access(file, [OS.FileSys.A_READ])
          then let
            val contents = loadJSON file
            in {
              metaData = getMetaData (#md contents),
              requests = JU.arrayMap getRequest (#reqs contents),
              notifications = JU.arrayMap getNotification (#notifs contents),
              structures = JU.arrayMap getStructure (#structs contents),
              enumerations = JU.arrayMap getEnum (#enums contents),
              typeAliases = JU.arrayMap getTypeAlias (#tys contents)
            } end
          else raise Fail(concat["meta-model file '", file, "' not found"])

  end
