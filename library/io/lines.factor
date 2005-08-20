! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: errors generic io kernel math namespaces sequences
vectors ;

TUPLE: line-reader cr ;

C: line-reader ( stream -- line ) [ set-delegate ] keep ;

: cr> dup line-reader-cr f rot set-line-reader-cr ;

: (readln) ( ? line -- ? )
    #! The flag is set after the first character is read.
    dup delegate stream-read1 dup [
        >r >r drop t r> r> dup CHAR: \r = [
            drop t swap set-line-reader-cr
        ] [
            dup CHAR: \n = [
                drop dup cr> [ (readln) ] [ drop ] ifte
            ] [
                , (readln)
            ] ifte
        ] ifte
    ] [
        2drop
    ] ifte ;

M: line-reader stream-readln ( line -- string )
    [ f swap (readln) ] make-string
    dup empty? [ f ? ] [ nip ] ifte ;

M: line-reader stream-read ( count line -- string )
    [ delegate stream-read ] keep dup cr> [
        over empty? [
            drop
        ] [
            >r 1 swap tail r> stream-read1 [ add ] when*
        ] ifte
    ] [
        drop
    ] ifte ;

: (lines) ( seq -- seq )
    readln [ over push (lines) ] when* ;

: lines ( stream -- seq )
    #! Read all lines from the stream into a sequence.
    [ 100 <vector> (lines) ] with-stream ;
