(* lsp-types.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * A canonical representation of the types used in the LSP protocol.
 * We use hash-consing to uniquely identify types and type expressions
 * so that we do not have redundant SML type definitions in the
 * generated code.
 *
 * COMMENTS:
 *  - a common use of the "or" kind is `ty | null`.  Should map this to
 *    and SML option type.
 *)

structure LSPTypes : sig

    type typ
    type property
    type struct_lit_ty

    (* convert a meta-model type to a hash-consed type *)
    val mkTyp : MetaModel.typ -> typ

    (* predefined base types *)
    val tyURI : typ
    val tyDocumentUri : typ
    val tyInteger : typ
    val tyUInteger : typ
    val tyDecimal : typ
    val tyRegExp : typ
    val tyString : typ
    val tyBoolean : typ
    val tyNull : typ

    structure Typ : sig

        type t = typ

        val compare : t * t -> order
        val same : t * t -> bool
        val hash : t -> word

        datatype rep
          = T_Base of MetaModel.base_ty
          | T_Reference of Atom.atom
          | T_Array of typ
          | T_Map of {key : typ, value : typ}
          | T_And of typ list
          | T_Or of typ list
          | T_Tuple of typ list
          | T_StructureLit of struct_lit_ty
          | T_StringLit of string
          | T_IntegerLit of int
          | T_BooleanLit of bool

        val view : typ -> rep

      end (* structure Typ *)

    structure Prop : sig

        type t = property

        val compare : t * t -> order
        val same : t * t -> bool
        val hash : t -> word

        type rep = {
            name : string,
            ty : typ,
            optional : bool
          }

        val view : t -> rep

      end (* structure Prop *)

    structure StructLit : sig

        type t = struct_lit_ty

        val compare : t * t -> order
        val same : t * t -> bool
        val hash : t -> word

        datatype rep = StructLit of property list

        val view : t -> rep

      end (* structure StructLit *)

  end = struct

    structure MM = MetaModel
    structure HC = HashCons

    (* for type constructors, like '&' and '|', we sort the arguments
     * into a canonical order by tag value.
     *)
    fun sort (xs : 'a HC.obj list) =
          ListMergeSort.sort (fn ({tag=a, ...}, {tag=b, ...}) => (a > b)) xs

    (* hash-consed base types *)
    type hc_bool = HashConsBool.obj
    type hc_int = HashConsInt.obj
    type hc_string = HashConsString.obj
    type hc_atom = HashConsAtom.obj

    structure BaseTy = HashConsGroundFn (
      struct
        type hash_key = MM.base_ty
        fun sameKey (h1 : hash_key, h2) = (h1 = h2)
        fun hashVal MM.T_URI = 0w7
          | hashVal MM.T_DocumentUri = 0w13
          | hashVal MM.T_Integer = 0w17
          | hashVal MM.T_UInteger = 0w19
          | hashVal MM.T_Decimal = 0w23
          | hashVal MM.T_RegExp = 0w29
          | hashVal MM.T_String = 0w31
          | hashVal MM.T_Boolean = 0w37
          | hashVal MM.T_Null = 0w41
      end)

    type base_ty = BaseTy.obj

    type reference_ty = hc_atom

    datatype typ_node
      = T_BaseNd of base_ty
      | T_ReferenceNd of reference_ty
      | T_ArrayNd of typ
      | T_MapNd of {key : typ, value : typ}
      | T_AndNd of typ list
      | T_OrNd of typ list
      | T_TupleNd of typ list
      | T_StructureLitNd of struct_lit_ty
      | T_StringLitNd of hc_string
      | T_IntegerLitNd of hc_int
      | T_BooleanLitNd of hc_bool

    and prop_node = PropNd of {
        name : HashConsString.obj,
        ty : typ,
        optional : hc_bool
      }

    and struct_node = StructLitNd of property list

    withtype typ = typ_node HC.obj
         and property = prop_node HC.obj
         and struct_lit_ty = struct_node HC.obj

    (* equality function for typ_node *)
    fun sameTyp (T_BaseNd x, T_BaseNd y) = HC.same(x, y)
      | sameTyp (T_ReferenceNd x, T_ReferenceNd y) = HC.same(x, y)
      | sameTyp (T_ArrayNd x, T_ArrayNd y) = HC.same(x, y)
      | sameTyp (T_MapNd x, T_MapNd y) =
          HC.same(#key x, #key y) andalso HC.same(#value x, #value y)
      | sameTyp (T_AndNd x, T_AndNd y) = ListPair.allEq HC.same (x, y)
      | sameTyp (T_OrNd x, T_OrNd y) = ListPair.allEq HC.same (x, y)
      | sameTyp (T_TupleNd x, T_TupleNd y) = ListPair.allEq HC.same (x, y)
      | sameTyp (T_StructureLitNd x, T_StructureLitNd y) = HC.same(x, y)
      | sameTyp (T_StringLitNd x, T_StringLitNd y) = HC.same(x, y)
      | sameTyp (T_IntegerLitNd x, T_IntegerLitNd y) = HC.same(x, y)
      | sameTyp (T_BooleanLitNd x, T_BooleanLitNd y) = HC.same(x, y)
      | sameTyp _ = false

    (* equality function for prop_node *)
    fun sameProp (PropNd x, PropNd y) =
          HC.same(#name x, #name y) andalso
          HC.same(#ty x, #ty y) andalso
          HC.same(#optional x, #optional y)

    (* equality function for struct_node *)
    fun sameStructLit (StructLitNd x, StructLitNd y) = ListPair.allEq HC.same (x, y)

    val typTbl = HC.new {eq = sameTyp}
    val propTbl = HC.new {eq = sameProp}
    val structTbl = HC.new {eq = sameStructLit}

    val consBase = HC.cons1 typTbl (0w73, T_BaseNd)
    val consReference = HC.cons1 typTbl (0w79, T_ReferenceNd)
    val consArray = HC.cons1 typTbl (0w83, T_ArrayNd)
    val consMap = HC.cons2 typTbl (0w89, fn (k, v) => T_MapNd{key=k, value=v})
    val consAnd = HC.consList typTbl (0w97, T_AndNd)
    val consOr = HC.consList typTbl (0w101, T_OrNd)
    val consTuple = HC.consList typTbl (0w103, T_TupleNd)
    val consStructureLiteral = HC.cons1 typTbl (0w107, T_StructureLitNd)
    val consStringLiteral = HC.cons1 typTbl (0w109, T_StringLitNd)
    val consIntegerLiteral = HC.cons1 typTbl (0w113, T_IntegerLitNd)
    val consBooleanLiteral = HC.cons1 typTbl (0w127, T_BooleanLitNd)

    val consProp = HC.cons3 propTbl
          (0w179, fn (n, ty, opt) => PropNd{name=n, ty=ty, optional=opt})

    val consStruct = HC.consList structTbl (0w181, StructLitNd)

    (* convert a meta-model type to a hash-consed type *)
    fun mkTyp (MM.T_Base arg) = consBase (BaseTy.mk arg)
      | mkTyp (MM.T_Reference arg) = consReference (HashConsAtom.mk arg)
      | mkTyp (MM.T_Array arg) = consArray (mkTyp arg)
      | mkTyp (MM.T_Map{key, value}) = consMap(mkTyp key, mkTyp value)
      | mkTyp (MM.T_And arg) =
          (* canonicalize the argument order *)
          consAnd(sort (List.map mkTyp arg))
      | mkTyp (MM.T_Or arg) =
          (* canonicalize the argument order *)
          consOr(sort (List.map mkTyp arg))
      | mkTyp (MM.T_Tuple arg) = consTuple (List.map mkTyp arg)
      | mkTyp (MM.T_StructureLiteral arg) = consStructureLiteral (mkStruct arg)
      | mkTyp (MM.T_StringLiteral arg) = consStringLiteral (HashConsString.mk arg)
      | mkTyp (MM.T_IntegerLiteral arg) =
          consIntegerLiteral (HashConsInt.mk (Int.fromLarge arg))
      | mkTyp (MM.T_BooleanLiteral arg) = consBooleanLiteral (HashConsBool.mk arg)

    and mkProp ({name, ty, optional, ...} : MM.property) : property =
          consProp (HashConsString.mk name, mkTyp ty, HashConsBool.mk optional)

    and mkStruct ({properties, ...} : MM.struct_lit_ty) : struct_lit_ty =
          consStruct (sort (List.map mkProp properties))

    val tyURI = consBase (BaseTy.mk MM.T_URI)
    val tyDocumentUri = consBase (BaseTy.mk MM.T_DocumentUri)
    val tyInteger = consBase (BaseTy.mk MM.T_Integer)
    val tyUInteger = consBase (BaseTy.mk MM.T_UInteger)
    val tyDecimal = consBase (BaseTy.mk MM.T_Decimal)
    val tyRegExp = consBase (BaseTy.mk MM.T_RegExp)
    val tyString = consBase (BaseTy.mk MM.T_String)
    val tyBoolean = consBase (BaseTy.mk MM.T_Boolean)
    val tyNull = consBase (BaseTy.mk MM.T_Null)

    structure Typ = struct

        type t = typ

        val compare : t * t -> order = HC.compare
        val same : t * t -> bool = HC.same
        val hash : t -> word = HC.tag

        datatype rep
          = T_Base of MetaModel.base_ty
          | T_Reference of Atom.atom
          | T_Array of typ
          | T_Map of {key : typ, value : typ}
          | T_And of typ list
          | T_Or of typ list
          | T_Tuple of typ list
          | T_StructureLit of struct_lit_ty
          | T_StringLit of string
          | T_IntegerLit of int
          | T_BooleanLit of bool

        fun view (t : t) = (case #nd t
               of T_BaseNd{nd, ...} => T_Base nd
                | T_ReferenceNd{nd, ...} => T_Reference nd
                | T_ArrayNd typ => T_Array typ
                | T_MapNd arg => T_Map arg
                | T_AndNd arg => T_And arg
                | T_OrNd arg => T_Or arg
                | T_TupleNd arg => T_Tuple arg
                | T_StructureLitNd arg => T_StructureLit arg
                | T_StringLitNd{nd, ...} => T_StringLit nd
                | T_IntegerLitNd{nd, ...} => T_IntegerLit nd
                | T_BooleanLitNd{nd, ...} => T_BooleanLit nd
              (* end case *))

      end (* structure Typ *)

    structure Prop = struct

        type t = property

        val compare : t * t -> order = HC.compare
        val same : t * t -> bool = HC.same
        val hash : t -> word = HC.tag

        type rep = {
            name : string,
            ty : typ,
            optional : bool
          }

        fun view (t : t) = let
              val PropNd{name, ty, optional} = #nd t
              in
                {name = #nd name, ty = ty, optional = #nd optional}
              end

      end (* structure Prop *)

    structure StructLit = struct

        type t = struct_lit_ty

        val compare : t * t -> order = HC.compare
        val same : t * t -> bool = HC.same
        val hash : t -> word = HC.tag

        datatype rep = StructLit of property list

        fun view (t : t) = let
              val StructLitNd arg = #nd t
              in
                StructLit arg
              end

      end (* structure StructLit *)

  end
