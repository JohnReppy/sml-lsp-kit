(* meta-model.sml
 *
 * COPYRIGHT (c) 2023 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * SML representation of the "meta model"; these type definitions are essentially
 * a translation of the `metaModel.ts` definitions to SML types.
 *
 * Note: there are a number of types that are represented as JSON objects
 * with a "kind" field that has a fixed value (e.g., "ReferenceType", which
 * maps to the SML type "reference_ty").
 *)

structure MetaModel =
  struct

    type number = IntInf.int

    (*! Indicates in which direction a message is sent in the protocol. *)
    datatype message_dir = ClientToServer | ServerToClient | Both

    (* ========== Types ========== *)

    datatype typ
      = T_Base of base_ty
      | T_Reference of reference_ty
      | T_Array of array_ty
      | T_Map of map_ty
      | T_And of and_ty
      | T_Or of or_ty
      | T_Tuple of tuple_ty
      | T_StructureLiteral of struct_lit_ty
      | T_StringLiteral of string_lit_ty
      | T_IntegerLiteral of integer_lit_ty
      | T_BooleanLiteral of boolean_lit_ty

    and base_ty
      = T_URI | T_DocumentUri | T_Integer | T_UInteger
      | T_Decimal | T_RegExp | T_String | T_Boolean | T_Null

    (*! Represents a type that can be used as a key in a map type.
     *
     * Map keys are restricted to either one of the following base types: T_URI,
     * T_DocumentUri, T_Integer, T_String, or a reference type that resolves to
     * either T_String or T_Integer (e.g., `type ChangeAnnotationIdentifier === string`).
     *
     * In the JSON file, this is either an object with a "kind" field (== "base"),
     * or a reference_ty value.
     *)
    withtype map_key_ty = typ

    (*! Represents a reference to another type (e.g., `TextDocument`).
     * This is either a `Structure`, a `Enumeration` or a `TypeAlias`
     * in the same meta model.
     *
     * In the JSON file, this is an object with two fields: "kind" (== "reference")
     * and "name".
     *)
    and reference_ty = Atom.atom

    (*! Represents an array type (e.g. `TextDocument[]`).
     *
     * In the JSON file, this is an object with two fields: "kind" (== "array")
     * and "element".
     *)
    and array_ty = typ

    (*! Represents a JSON object map
     * (e.g., `interface Map<K extends string | integer, V> { [key: K] => V; }`).
     *
     * In the JSON file, this is an object with fields "kind" (== "map"),
     * "key", and "value".
     *)
    and map_ty = {
	key : map_key_ty,
	value : typ
      }

    (*! Represents an `and` type
     * (e.g., TextDocumentParams & WorkDoneProgressParams`).
     *
     * The JSON representation is an object with two fields: "kind" (== 'and')
     * and "items".
     *)
    and and_ty = typ list

    (*! Represents an `or` type (e.g., `Location | LocationLink`).
     *
     * The JSON representation is an object with two fields: "kind" (== 'or')
     * and "items".
     *)
    and or_ty = typ list

    (*! Represents a `tuple` type (e.g., `[integer, integer]`).
     *
     * The JSON representation is an object with two fields: "kind" (== 'tuple')
     * and "items".
     *)
    and tuple_ty = typ list

    (*! Represents a string literal type (e.g., `kind: 'rename'`).
     *
     * The JSON representation is an object with two fields: "kind" (== 'stringLiteral')
     * and "value".
     *)
    and string_lit_ty = string

    (*! Represents an integer literal type (e.g., `kind: 1`).
     *
     * The JSON representation is an object with two fields: "kind" (== 'integerLiteral')
     * and "value".
     *)
    and integer_lit_ty = number

    (*! Represents a boolean literal type (e.g., `kind: true`).
     *
     * The JSON representation is an object with two fields: "kind" (== 'booleanLiteral')
     * and "value".
     *)
    and boolean_lit_ty = bool

    (* ========== Structures ========== *)

    (*! Represents an object property. *)
    and property = {
	(*! The property name; *)
	name: string,
	(*! The type of the property *)
	ty : typ,
	(*! Whether the property is optional. If omitted, the property is
         *  mandatory (i.e., the value is false).
         *)
	optional : bool,
	(*! An optional documentation. *)
	documentation : string option,
	(*! Since when (release number) this property is
	 * available. Is undefined if not known.
	 *)
	since : string option,
	(*! Whether this is a proposed property. If omitted,
	 * the structure is final (i.e., the value is `false`).
	 *)
	proposed : bool,
	(*! Whether the property is deprecated or not. If deprecated
	 * the property contains the deprecation message.
	 *)
	deprecated : string option
      }

    (*! Defines the structure of an object literal. *)
    and data_struct = {
	(*! The name of the structure. *)
	name : Atom.atom,
	(*! Structures extended from. These structures form
	 * a polymorphic type hierarchy.
	 *)
	extends : typ list,
	(*! Structures to mix in. The properties of these structures are `copied`
         * into this structure.  Mixins don't form a polymorphic type hierarchy in
	 * LSP.
	 *)
	mixins : typ list,
	(*! The properties. *)
	properties : property list,
	(*! An optional documentation; *)
	documentation : string option,
	(*! Since when (release number) this structure is
	 * available. Is undefined if not known.
	 *)
	since : string option,
	(*! Whether this is a proposed structure. If omitted,
	 * the structure is final (i.e., the value is `false`).
	 *)
	proposed : bool,
	(*! Whether the structure is deprecated or not. If deprecated
	 * the property contains the deprecation message.
	 *)
	deprecated : string option
      }

    (*! Defines an unnamed structure of an object literal.  We also flatten
     *  the "StructureLiteralType", which is an object with "kind" (== 'literal')
     *  and "value" fields, and use this SML type to represent it as well.
     *)
    and struct_lit_ty = {
	(*! The properties. *)
	properties : property list,
	(*! An optional documentation. *)
	documentation : string option,
	(*! Since when (release number) this structure is
	 *  available. Is undefined if not known.
	 *)
	since : string option,
	(*! Whether this is a proposed structure. If omitted,
	 *  the structure is final (i.e., the value is `false`).
	 *)
	proposed : bool,
	(*! Whether the literal is deprecated or not. If deprecated
	 * the property contains the deprecation message.
	 *)
	deprecated : string option
      }

    (* ========== Type Aliases ========== *)

    (*! Defines a type alias.
     * (e.g. `type Definition = Location | LocationLink`)
     *)
    type type_alias = {
	(*! The name of the type alias. *)
	name : Atom.atom,
	(*! The aliased type. *)
	ty : typ,
	(*! An optional documentation. *)
        documentation : string option,
	(*! Since when (release number) this structure is
	 *  available. Is undefined if not known.
	 *)
	since : string option,
        (*! Whether this is a proposed type alias. If omitted,
         *  the type alias is final (i.e., the value is false).
         *)
	proposed : bool,
	(*! Whether the type alias is deprecated or not. If deprecated
	 *  the property contains the deprecation message.
	 *)
	deprecated : string option
      }

    (* ========== Enumerations ========== *)

    datatype str_or_num_val = StrVal of string | NumVal of number

    type enum_entry = {
        (*! The name of the enum item. *)
        name : string,
        (*! the value *)
        value : str_or_num_val,
        (*! An optional documentation. *)
        documentation : string option,
        (*! Since when (release number) this enumeration entry is
         *  available. Is undefined if not known.
         *)
        since : string option,
        (*! Whether this is a proposed enumeration entry. If omitted, the
         *  enumeration entry is final (i.e., the value is `false`).
         *)
        proposed : bool,
        (*! Whether the enum entry is deprecated or not. If deprecated
         *  the property contains the deprecation message.
         *)
        deprecated : string option
      }

    datatype enum_rep_ty = ER_String | ER_Integer | ER_UInteger

    (* enumerations, which are groups of named constants *)
    type enum = {
        (*! The name of the enumeration. *)
        name : Atom.atom,
        (*! The type of the elements. *)
        rep : enum_rep_ty,
        (*! The enum values. *)
        values : enum_entry list,
        (*! Whether the enumeration supports custom values (e.g. values which are not
	 *  part of the set defined in `values`). If omitted no custom values are
	 *  supported (i.e., the value is false).
         *)
        supportsCustomValues : bool,
        (*! An optional documentation. *)
        documentation : string option,
        (*! Since when (release number) this enumeration is available.
         *  Is undefined if not known.
         *)
        since : string option,
        (*! Whether this is a proposed enumeration. If omitted, the enumeration
         *  entry is final (i.e., the value is `false`).
         *)
        proposed : bool,
        (*! Whether the enumeration is deprecated or not. If deprecated the
         *  property contains the deprecation message.
         *)
        deprecated : string option
      }

    (* ========== Requests ========== *)

    (*! Represents a LSP request *)
    type request = {
	(*! The request's method name. *)
	method: string,
	(*! The parameter type(s) if any. *)
	params : typ list,
	(*! The result type. *)
	result: typ,
	(*! Optional partial result type if the request
	 *  supports partial result reporting.
	 *)
	partialResult : typ option,
	(*! An optional error data type. *)
	errorData : typ option,
	(*! Optional dynamic registration method if it is
	 *  different from the request's method.
	 *)
	registrationMethod : string option,
	(*! Optional registration options if the request supports
	 *  dynamic registration.
	 *)
	registrationOptions : typ option,
	(*! The direction in which this request is sent in the protocol. *)
	messageDirection : message_dir,
	(*! An optional documentation string *)
	documentation : string option,
	(*! Since when (release number) this request is
	 *  available. Is undefined if not known.
	 *)
	since : string option,
	(*! Whether this is a proposed feature. If omitted the
         *  feature is final (i.e., the value is false).
	 *)
	proposed : bool,
	(*! Whether the request is deprecated or not. If deprecated
	 *  the property contains the deprecation message.
	 *)
	deprecated : string option
      }

    (* ========== Notifications ========== *)

    (*! Represents a LSP notification *)
    type notification = {
	(*! The request's method name. *)
	method : string,
	(*! The parameter type(s) if any. *)
	params : typ list,
	(*! Optional a dynamic registration method if it
	 * different from the request's method.
	 *)
	registrationMethod : string option,
	(*! Optional registration options if the notification
	 * supports dynamic registration.
	 *)
	registrationOptions : typ option,
	(*! The direction in which this notification is sent in the protocol. *)
	messageDirection : message_dir,
	(*! An optional documentation; *)
	documentation : string option,
	(*! Since when (release number) this notification is
	 * available. Is undefined if not known.
	 *)
	since : string option,
        (*! Whether this is a proposed notification. If omitted
	 * the notification is final (i.e., the value is false).
	 *)
	proposed : bool,
	(*! Whether the notification is deprecated or not. If deprecated
	 * the property contains the deprecation message.
	 *)
	deprecated : string option
      }

    (* ========== The Meta Model ========== *)

    (* meta data; currently this is just the protocol version string, but
     * we keep it as a record in case additional meta-data is added in
     * some future version of the model.
     *)
    type meta_data = {
	(*! The protocol version. *)
	version: string
      }

    (*! The actual meta model. *)
    type t = {
	(*! Additional meta data. *)
	metaData : meta_data,
	(*! The requests. *)
	requests : request list,
	(*! The notifications. *)
	notifications : notification list,
	(*! The structures. *)
	structures : data_struct list,
	(*! The enumerations. *)
	enumerations : enum list,
	(*! The type aliases. *)
	typeAliases : type_alias list
      }

  end
