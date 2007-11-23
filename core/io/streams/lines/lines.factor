! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.lines
USING: arrays generic io kernel math namespaces sequences
vectors combinators splitting ;

TUPLE: line-reader cr ;

: <line-reader> ( stream -- new-stream )
    line-reader construct-delegate ;

: cr+ t swap set-line-reader-cr ; inline

: cr- f swap set-line-reader-cr ; inline

: line-ends/eof ( stream str -- str ) f like swap cr- ; inline

: line-ends\r ( stream str -- str ) swap cr+ ; inline

: line-ends\n ( stream str -- str )
    over line-reader-cr over empty? and
    [ drop dup cr- stream-readln ] [ swap cr- ] if ; inline

: handle-readln ( stream str ch -- str )
    {
        { f [ line-ends/eof ] }
        { CHAR: \r [ line-ends\r ] }
        { CHAR: \n [ line-ends\n ] }
    } case ;

M: line-reader stream-readln ( stream -- str )
    "\r\n" over delegate stream-read-until handle-readln ;

: fix-read ( stream string -- string )
    over line-reader-cr [
        over cr-
        "\n" ?head [
            swap stream-read1 [ add ] when*
        ] [ nip ] if
    ] [ nip ] if ;

M: line-reader stream-read
    tuck delegate stream-read fix-read ;

M: line-reader stream-read-partial
    tuck delegate stream-read-partial fix-read ;

: fix-read1 ( stream char -- char )
    over line-reader-cr [
        over cr-
        dup CHAR: \n = [
            drop stream-read1
        ] [ nip ] if
    ] [ nip ] if ;

M: line-reader stream-read1 ( stream -- char )
    dup delegate stream-read1 fix-read1 ;
