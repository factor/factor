! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: errors generic io kernel math namespaces sequences
vectors ;

TUPLE: line-reader cr ;

C: line-reader ( stream -- new-stream ) [ set-delegate ] keep ;

: cr> dup line-reader-cr f rot set-line-reader-cr ;

: (readln) ( ? line -- ? )
    #! The flag is set after the first character is read.
    dup delegate stream-read1 dup [
        >r >r drop t r> r> dup CHAR: \r number= [
            drop t swap set-line-reader-cr
        ] [
            dup CHAR: \n number= [
                drop dup cr> [ (readln) ] [ drop ] if
            ] [
                , (readln)
            ] if
        ] if
    ] [
        2drop
    ] if ;

M: line-reader stream-readln
    [ f swap (readln) ] "" make
    dup empty? [ f ? ] [ nip ] if ;

M: line-reader stream-read
    [ delegate stream-read ] keep dup cr> [
        over empty? [
            drop
        ] [
            >r 1 tail r> stream-read1 [ add ] when*
        ] if
    ] [
        drop
    ] if ;

: (lines) ( -- ) readln [ , (lines) ] when* ;

: lines ( stream -- seq ) [ [ (lines) ] { } make ] with-stream ;
