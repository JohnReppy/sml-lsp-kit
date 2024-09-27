(* add a HTTP header to the content of a message *)

fun addHeader nn = let
      val contentFile = "content" ^ nn ^ ".txt"
      val messageFile = "message" ^ nn ^ ".txt"
      val inS = TextIO.openIn contentFile
      val content = TextIO.inputAll inS
      val () = TextIO.closeIn inS
      val outS = TextIO.openOut messageFile
      in
        TextIO.output(outS, concat [
            "Content-Length: ", Int.toString(size content), "\r\n\r\n"
          ]);
        TextIO.output(outS, content);
        TextIO.closeOut outS
      end;
