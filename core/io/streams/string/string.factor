! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.string
USING: io kernel math namespaces sequences sbufs strings
generic splitting io.streams.plain io.streams.lines ;

M: sbuf stream-write1 push ;
M: sbuf stream-write push-all ;
M: sbuf stream-close drop ;
M: sbuf stream-flush drop ;

: <string-writer> ( -- stream )
    512 <sbuf> <plain-writer> ;

: string-out ( quot -- str )
    <string-writer> [ call stdio get >string ] with-stream* ;
    inline

: format-column ( seq ? -- seq )
    [
        [ 0 [ length max ] reduce ] keep
        swap [ CHAR: \s pad-right ] curry map
    ] unless ;

: map-last ( seq quot -- seq )
    swap dup length <reversed>
    [ zero? rot [ call ] keep swap ] 2map nip ; inline

: format-table ( table -- seq )
    flip [ format-column ] map-last
    flip [ " " join ] map ;

M: plain-writer stream-write-table
    [ drop format-table [ print ] each ] with-stream* ;

M: plain-writer make-cell-stream 2drop <string-writer> ;

M: sbuf stream-read1 dup empty? [ drop f ] [ pop ] if ;

: sbuf-read-until ( sbuf n -- str )
    tail-slice >string dup reverse-here ;

: find-last-sep swap [ memq? ] curry find-last drop ;

M: sbuf stream-read-until
    [ find-last-sep ] keep over [
        [ swap 1+ sbuf-read-until ] 2keep [ nth ] 2keep
        set-length
    ] [
        [ swap drop 0 sbuf-read-until f like f ] keep
        delete-all
    ] if ;

M: sbuf stream-read
    dup empty? [
        2drop f
    ] [
        [ length swap - 0 max ] keep
        [ swap sbuf-read-until ] 2keep
        set-length
    ] if ;

M: sbuf stream-read-partial
    stream-read ;

: <string-reader> ( str -- stream )
    >sbuf dup reverse-here <line-reader> ;

: string-in ( str quot -- )
    >r <string-reader> r> with-stream ; inline
