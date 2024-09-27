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
        properties : property list (* includes mixins *)
      }

    type info = {
	structures : data_struct list,
	enumerations : MM.enum AtomTable.hash_table,
        typeAliases : LTy.typ AtomTable.hash_table
      }

    fun processEnums (enums : MM.enum list) = let
          val tbl = AtomTable.mkTable(List.length enums, Fail "enums")
          val ins = AtomTable.insert tbl
          in
            List.app (fn (e : MM.enum) => ins (#name e, e)) enums;
            tbl
          end

    fun analyze (mm : MM.t) = let
          val enumTbl = processEnums (#enumerations mm)
          val typeAliases = AtomTable.mkTable(64, Fail "typeAliases")
          in {
            structures = [],
            enumerations = enumTbl,
            typeAliases = typeAliases
          } end

  end
