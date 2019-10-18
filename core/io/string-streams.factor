! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io
USING: io kernel math namespaces sequences sbufs strings ;

M: sbuf stream-write1 push ;
M: sbuf stream-write nappend ;
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
        [ swap CHAR: \s pad-right ] map-with
    ] unless ;

: map-last ( seq quot -- seq )
    swap dup length <reversed>
    [ zero? rot [ call ] keep swap ] 2map nip ; inline

M: plain-writer with-stream-table
    [
        drop swap
        [ [ swap string-out ] map-with ] map-with
        flip [ format-column ] map-last
        flip [ " " join ] map
        [ print ] each
    ] with-stream* ;

M: sbuf stream-read1 dup empty? [ drop f ] [ pop ] if ;

: sbuf-read-until ( sbuf n -- str )
    tail-slice >string dup nreverse ;

: find-last-sep [ swap memq? ] find-last-with drop ;

M: sbuf stream-read-until
    [ find-last-sep ] keep over -1 = [
        [ swap 1+ sbuf-read-until f like f ] keep
        delete-all
    ] [
        [ swap 1+ sbuf-read-until ] 2keep [ nth ] 2keep
        set-length
    ] if ;

M: sbuf stream-read
    dup empty? [
        2drop f
    ] [
        [ length swap - 0 max ] keep
        [ swap sbuf-read-until ] 2keep
        set-length
    ] if ;

: <string-reader> ( str -- stream )
    >sbuf dup nreverse <line-reader> ;

: string-in ( str quot -- )
    >r <string-reader> r> with-stream ; inline

: contents ( stream -- str )
    <string-writer> [ stream-copy ] keep >string ;

: string-lines ( string -- seq )
    "\r\n" append <string-reader> [ (lines) ] with-stream* ;
