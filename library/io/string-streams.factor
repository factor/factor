! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: io kernel math namespaces sequences strings ;

M: sbuf stream-write1 push ;
M: sbuf stream-write swap nappend ;
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

M: sbuf stream-read1
    dup empty? [ drop f ] [ pop ] if ;

M: sbuf stream-read
    dup empty? [
        2drop f
    ] [
        swap over length min 0 <string>
        [ [ drop pop ] inject-with ] keep
    ] if ;

: <string-reader> ( str -- stream )
    <reversed> >sbuf <line-reader> ;

: string-in ( str quot -- )
    >r <string-reader> r> with-stream ; inline

: contents ( stream -- str )
    <string-writer> [ stream-copy ] keep >string ;
