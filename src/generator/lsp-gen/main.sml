(* main.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure Main =
  struct

    val mmPath = "../meta-model/3.17/metaModel.json"

    fun testServer () = let
          val mm = LoadMetaModel.load mmPath
          in
            CodeGen.gen mm {
                outputDir = "out",
                (*! if true, generate code that allows for logging the message traffic. *)
                enableLogging = false,
                (*! if true, then omit deprecated messages *)
                omitDeprecated = true,
                (*! if true, then omit requests and notifications that are not final *)
                omitProposed = true,
                (*! if true, then generate the type definitions *)
                types = true,
                (*! specifies which side of the protocol is generated *)
                side = CodeGen.ServerSide
              }
              "output"
          end

    fun testClient () = let
          val mm = LoadMetaModel.load mmPath
          in
            CodeGen.gen mm {
                outputDir = "out",
                (*! if true, generate code that allows for logging the message traffic. *)
                enableLogging = false,
                (*! if true, then omit deprecated messages *)
                omitDeprecated = true,
                (*! if true, then omit requests and notifications that are not final *)
                omitProposed = true,
                (*! if true, then generate the type definitions *)
                types = true,
                (*! specifies which side of the protocol is generated *)
                side = CodeGen.ClientSide
              }
              "output"
          end

  end
