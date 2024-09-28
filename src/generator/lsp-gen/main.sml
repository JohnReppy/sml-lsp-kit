(* main.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure Main =
  struct

    val mmPath = "../meta-model/3.17/metaModel.json"

    (* a predicate on request/notify messages to mark them for omission
     * from the generated code.
     *)
    fun omitMessage (_, CodeGen.Registration, "initialize") = true
      | omitMessage (_, CodeGen.Registration, "initialized") = true
      | omitMessage (_, CodeGen.Registration, "shutdown") = true
      | omitMessage (_, CodeGen.Registration, "exit") = true
      | omitMessage _ = false

    fun testServer () = let
          val mm = LoadMetaModel.load mmPath
          in
            CodeGen.gen (mm, {
                outputDir = "out",
                enableLogging = false,
                omitDeprecated = true,
                omitProposed = true,
                types = true,
                side = CodeGen.ServerSide,
                omitMessage = omitMessage
              })
          end

    fun testClient () = let
          val mm = LoadMetaModel.load mmPath
          in
            CodeGen.gen (mm, {
                outputDir = "out",
                enableLogging = false,
                omitDeprecated = true,
                omitProposed = true,
                types = true,
                side = CodeGen.ClientSide,
                omitMessage = omitMessage
              })
          end

    fun listMethods (dir : MetaModel.message_dir) = let
          val mm = LoadMetaModel.load mmPath
          fun pred MetaModel.Both = true
            | pred dir' = (dir = dir')
          val reqs = List.mapPartial
                (fn (r : MetaModel.request) => if pred(#messageDirection r)
                   then SOME(#method r)
                   else NONE)
                (#requests mm)
          val notes = List.mapPartial
                (fn (r : MetaModel.notification) => if pred(#messageDirection r)
                   then SOME(#method r)
                   else NONE)
                (#notifications mm)
          in
            print "(* requests *)\n";
            List.app (fn id => print(concat["  ", id, "\n"])) reqs;
            print "(* notifications *)\n";
            List.app (fn id => print(concat["  ", id, "\n"])) notes
          end

  end
