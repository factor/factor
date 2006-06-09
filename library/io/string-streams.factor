! Copyright (C) 2003, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: io
USING: io kernel math namespaces sequences strings ;

! String buffers support the stream output protocol.
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

: map-last ( seq quot -- seq | quot: elt last? )
    swap dup length <reversed>
    [ zero? rot [ call ] keep swap ] 2map nip ;

M: plain-writer with-stream-table ( quot grid stream -- )
    -rot [ [ swap string-out ] map-with ] map-with
    flip [ format-column ] map-last
    flip [ " " join ] map
    [ swap stream-print ] each-with ;

! Reversed string buffers support the stream input protocol.
M: sbuf stream-read1 ( sbuf -- char/f )
    dup empty? [ drop f ] [ pop ] if ;

M: sbuf stream-read ( count sbuf -- string )
    dup empty? [
        2drop f
    ] [
        swap over length min 0 <string>
        [ [ drop dup pop ] inject drop ] keep
    ] if ;

: <string-reader> ( string -- stream )
    <reversed> >sbuf <line-reader> ;

: string-in ( str quot -- )
    >r <string-reader> r> with-stream ; inline

: contents ( stream -- string )
    #! Read the entire stream into a string.
    <string-writer> [ stream-copy ] keep >string ;
