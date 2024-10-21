(* analyze.sml
 *
 * COPYRIGHT (c) 2023 John Reppy (http://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *
 * Analyze the types used in the LSP protocol.
 *)

structure Analyze : sig

    type property = LSPTypes.property

    type data_struct = {
	name : Atom.atom,
	extends : LSPTypes.typ list,
        properties : property list (* includes mixins *)
      }

    type info = {
	structures : data_struct list,
	enumerations : MetaModel.enum AtomTable.hash_table,
        typeAliases : LSPTypes.typ AtomTable.hash_table
      }

    val analyze : MetaModel.t -> info

  end = struct

    structure ATbl = AtomTable
    structure LTy = LSPTypes
    structure MM = MetaModel

    type property = LTy.property

    type data_struct = {
	name : Atom.atom,
	extends : LTy.typ list,
        properties : property list (* includes properties from mixins *)
      }

    type info = {
	structures : data_struct list,
	enumerations : MM.enum ATbl.hash_table,
        typeAliases : LTy.typ ATbl.hash_table
      }

    datatype env = E of {
        structMap : Atom.atom -> MM.data_struct option,
	enumMap : Atom.atom -> MM.enum option,
        aliasMap : Atom.atom -> MM.type_alias option
      }

    datatype named_ty
      = StructTy of MM.data_struct
      | EnumTy of MM.enum
      | AliasTy of MM.type_alias

    (* resolve a "reference" to a named type *)
    fun resolveRef (E{structMap, enumMap, aliasMap}, id) = (
          case structMap id
           of NONE => (case aliasMap id
                 of NONE => (case enumMap id
                       of NONE => raise Fail(concat[
                              "unknown type name '", Atom.toString id, "'"
                            ])
                        | SOME enum => EnumTy enum
                      (* end case *))
                  | SOME alias => AliasTy alias
                (* end case *))
            | SOME str => StructTy str
          (* end case *))

    (* initial pass over the meta model to construct the environment *)
    fun initializeEnv (mm : MM.t) = let
          val sTbl = ATbl.mkTable (length (#structures mm), Fail "structures")
          val eTbl = ATbl.mkTable (length (#enumerations mm), Fail "enumerations")
          val aTbl = ATbl.mkTable (length (#typeAliases mm), Fail "aliases")
          val env = E{
                  structMap = ATbl.find sTbl,
                  enumMap = ATbl.find eTbl,
                  aliasMap = ATbl.find aTbl
                }
          in
            List.app
              (fn (s : MM.data_struct) => ATbl.insert sTbl (#name s, s))
                (#structures mm);
            List.app
              (fn (e : MM.enum) => ATbl.insert eTbl (#name s, s))
                (#enumerations mm);
            List.app
              (fn (e : MM.type_alias) => ATbl.insert aTbl (#name a, a))
                (#typeAliases mm);
            env
          end

    fun processStruct (env, s : MM.data_struct) =

    and processAlias (env, a : MM.type_alias) = let
          val typ = processType (env, ty)
          in
            ??
          end

    and processType (env, ty) = (case ty
           of MM.T_Base of base_ty
            | MM.T_Reference name => (case resolveRef(env, name)
                 of StructTy s =>
                  | EnumTy e =>
                  | AliasTy a =>
                (* end case *))
            | MM.T_Array ty =>
            | MM.T_Map{key, value} =>
            | MM.T_And tys =>
            | MM.T_Or[ty1, MM.T_Base MM.T_Null] =>
            | MM.T_Or tys =>
            | MM.T_Tuple tys =>
            | MM.T_StructureLiteral strLit =>
            | MM.T_StringLiteral sLit =>
            | MM.T_IntegerLiteral iLit =>
            | MM.T_BooleanLiteral bLit =>
          (* end case *))

    fun processEnums (enums : MM.enum list) = let
          val tbl = AtomTable.mkTable(List.length enums, Fail "enums")
          val ins = AtomTable.insert tbl
          in
            List.app (fn (e : MM.enum) => ins (#name e, e)) enums;
            tbl
          end

    fun analyze (mm : MM.t) = let
          val env = initializeEnv mm
          val enumTbl = processEnums (#enumerations mm)
          val typeAliases = AtomTable.mkTable(64, Fail "typeAliases")
          in {
            structures = [],
            enumerations = enumTbl,
            typeAliases = typeAliases
          } end

  end
