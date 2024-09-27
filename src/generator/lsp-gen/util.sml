(* util.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure Util : sig

    (* convert a name to the variable convention; i.e., Caml case with leading
     * lowercase letter.  Note that the LSP names are already in Caml case, so
     * we only need to handle the first character.
     *)
    val toVarName : string -> string

    (* convert a name to the constructor/structure convention; i.e., Caml case
     * with leading uppercase letter.  Note that the LSP names are already in
     * Caml case, so we only need to handle the first character.
     *)
    val toConName : string -> string

    (* convert a request/notification method name to a qualified structure name.
     * Names that begin with a "$/" prefix are mapped to the "Protocol"
     * structure, while names that do not have a prefix are mapped to the
     * "Server" structure.
     *)
    val toStructName : string -> string list

  end = struct

    fun toVarName "" = raise Fail "empty variable name"
      | toVarName s = if Char.isUpper(String.sub(s, 0))
          then (case String.explode s
             of (c::r) => String.implode(Char.toLower c :: r)
              | _ => raise Fail "impossible"
            (* end case *))
          else s

    fun toConName "" = raise Fail "empty variable name"
      | toConName s = if Char.isLower(String.sub(s, 0))
          then (case String.explode s
             of (c::r) => String.implode(Char.toUpper c :: r)
              | _ => raise Fail "impossible"
            (* end case *))
          else s

    fun toStructName s = (
          case String.tokens (fn #"/" => true | _ => false) s
           of [name] => ["Server", toConName name]
            | ["$", name] => ["Protocol", toConName name]
            | qid => List.map toConName qid
          (* end case *))

(*
    fun messageName s = let
          fun cvtModuleName "$" = "Protocol"
            | cvtModuleName s = toConName s
          fun cvtName [name] = [toVarName name]
            | cvtName (modName::r) = cvtModuleName modName :: cvtName r
            | cvtName [] = []
          in
            case cvtName (String.tokens (fn #"/" => true | _ => false) s)
             of [name] => ["Server", toVarName name]
              | qid => qid
            (* end case *)
          end
*)

  end
