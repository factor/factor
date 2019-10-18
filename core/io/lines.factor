! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors generic io kernel math namespaces sequences
vectors ;

TUPLE: line-reader cr ;

C: line-reader ( stream -- new-stream ) [ set-delegate ] keep ;

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

: fix\r ( stream string -- string )
    "\n" ?head [ swap stream-read1 [ add ] when* ] [ nip ] if ;

M: line-reader stream-read
    tuck delegate stream-read over line-reader-cr
    [ over cr- fix\r ] [ nip ] if ;

: lines-loop ( -- ) readln [ , lines-loop ] when* ;

: (lines) ( -- seq ) [ lines-loop ] { } make ;

: lines ( stream -- seq ) [ (lines) ] with-stream ;
