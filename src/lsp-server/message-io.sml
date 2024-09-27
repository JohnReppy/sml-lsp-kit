(* message-io.sml
 *
 * COPYRIGHT (c) 2024 John Reppy (https://cs.uchicago.edu/~jhr)
 * All rights reserved.
 *)

structure MessageIO : sig

    val read : TextIO.StreamIO.instream -> string * TextIO.StreamIO.instream

    val write : TextIO.StreamIO.outstream * string -> unit

    (* `testRd fname` tests by reading from the file `fname` *)
    val testRd : string -> string

    (* `testWr (fname, msg)` tests by writing `msg` to the file `fname` *)
    val testWr : string * string -> unit

  end = struct

    structure TIO = TextIO.StreamIO

    (* integer addition w/o overflow checking *)
    fun ++ (a, b) = Word.toIntX(Word.fromInt a + Word.fromInt b)

    infix 6 ++

    val sub = Unsafe.CharVector.sub

    (* error reporting; no attempt at recovery for now *)
    fun error msg = let
          val msg = String.concat msg
          in
            TextIO.output(TextIO.stdErr, msg);
            TextIO.output1(TextIO.stdErr, #"\n");
            raise Fail msg
          end

    (* `inputN (inS, n)` returns a pair `(s, inS')`, where `s` is a string of
     * length `n` that was read from the input stream `inS` and `inS'` is the
     * rest of the input stream.  An error is signaled if an EOF is encountered
     * before `n` characters are read.
     *)
    fun inputN (inS, 0) = ("", inS)
      | inputN (inS, n) = let
          fun input (inS, n) = (case TIO.inputN (inS, n)
                 of ("", _) => error ["unexpected EOF"]
                  | (s, inS') => (s, inS')
                (* end case *))
          val (s, inS) = input (inS, n)
          in
            if (size s < n)
              then let
                (* input comes in multiple chunks *)
                fun lp (inS, n, chunks) = if (n > 0)
                      then let
                        val (s, inS) = input (inS, n)
                        in
                          lp (inS, n - size s, s::chunks)
                        end
                      else (String.concat(List.rev chunks), inS)
                in
                  lp (inS, n - size s, [s])
                end
              else (s, inS)
          end

    (* scan an HTTP header field, which is a line that terminates with
     * a "\r\n" sequence.  If successful, the contents of the line (but
     * not the terminator) are returned along with the rest of the stream.
     * otherwise `NONE` is returned.
     *)
    fun scanHeaderField startS = let
          fun scan (n, inS) = (case TIO.input1 inS
                 of SOME(#"\r", inS) => (case TIO.input1 inS
                       of SOME(#"\n", inS) => let
                            val (hdr, _) = inputN(startS, n)
                            in
                              (hdr, inS)
                            end
                        | SOME(c, _) => error[
                              "invalid header terminator '\\r",
                              Char.toString c, "'"
                            ]
                        | NONE => error["unexpected EOF in header"]
                      (* end case *))
                  | SOME(c, inS) => if Char.isPrint c orelse (c = #"\t")
                      then scan (n++1, inS)
                      else error["invalid character '", Char.toString c, "' in header"]
                  | NONE => error["unexpected EOF in header"]
                (* end case *))
          in
            scan (0, startS)
          end

    (* is the lower-case string `s1` a prefix of the string `s2`? *)
    fun prefixCaseMatch (s1, s2) = let
          val n1 = size s1
          val n2 = size s2
          in
            if (n1 > n2) then NONE
            else let
              fun caseCmp i = (sub(s1, i) = Char.toLower(sub(s2, i)))
              fun lp i = if (i >= n1)
                      then SOME(Substring.extract(s2, i, NONE))
                    else if caseCmp i
                      then lp (i++1)
                      else NONE
              in
                lp 0
              end
          end

    val scanInt = Int.scan StringCvt.DEC Substring.getc

    fun read inS = let
          fun getHeader1 inS = (case scanHeaderField inS
                 of ("", inS) => error["no 'content-length' field in header"]
                  | (ln, inS) => (case prefixCaseMatch ("content-length:", ln)
                      of SOME rest => (case scanInt rest
                            of SOME(n, _) => getHeader2 (inS, n)
                             | NONE => error["invalid content length in header"]
                          (* end case *))
                       | NONE => getHeader1 inS (* ignore other fields *)
                    (* end case *))
                (* end case *))
          and getHeader2 (inS, len) = (case scanHeaderField inS
                 of ("", inS) => (len, inS)
                  | (_, inS) => getHeader2 (inS, len) (* ignore other fields *)
                (* end case *))
          val (contentLength, inS) = getHeader1 inS
          val (content, inS) = inputN (inS, contentLength)
          in
            (content, inS)
          end

    fun write (outS, "") = ()
      | write (outS, msg) = (
          TIO.output(outS, "Content-Length:");
          TIO.output(outS, Int.toString(size msg));
          TIO.output(outS, "\r\n\r\n");
          TIO.output(outS, msg))

    fun testRd file = let
          val inS = TextIO.openIn file
          val inS' = TextIO.getInstream inS
          in
            #1(read inS') before TextIO.closeIn inS
          end

    fun testWr (file, msg) = let
          val outS = TextIO.openOut file
          val outS' = TextIO.getOutstream outS
          in
            write (outS', msg) before TextIO.closeOut outS
          end

  end (* structure ReadMessage *)
