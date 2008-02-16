! Copyright (C) 2003, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.streams.string
USING: io kernel math namespaces sequences sbufs strings
generic splitting io.streams.plain io.streams.lines growable
continuations byte-vectors io.encodings byte-arrays ;

M: growable dispose drop ;

M: growable stream-write1 push ;
M: growable stream-write push-all ;
M: growable stream-flush drop ;

: <string-writer> ( -- stream )
    512 <sbuf> <plain-writer> ;

: string-out ( quot -- str )
    <string-writer> swap [ stdio get ] compose with-stream*
    >string ; inline

: <byte-writer> ( encoding -- stream )
    512 <byte-vector> swap <encoding> ;

: with-byte-writer ( encoding quot -- byte-array )
    >r <byte-writer> r> [ stdio get ] compose with-stream*
    >byte-array ; inline

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

M: growable stream-read1 dup empty? [ drop f ] [ pop ] if ;

: sbuf-read-until ( sbuf n -- str )
    tail-slice >string dup reverse-here ;

: find-last-sep swap [ memq? ] curry find-last drop ;

M: growable stream-read-until
    [ find-last-sep ] keep over [
        [ swap 1+ sbuf-read-until ] 2keep [ nth ] 2keep
        set-length
    ] [
        [ swap drop 0 sbuf-read-until f like f ] keep
        delete-all
    ] if ;

M: growable stream-read
    dup empty? [
        2drop f
    ] [
        [ length swap - 0 max ] keep
        [ swap sbuf-read-until ] 2keep
        set-length
    ] if ;

M: growable stream-read-partial
    stream-read ;

: <string-reader> ( str -- stream )
    >sbuf dup reverse-here <line-reader> ;

: string-in ( str quot -- )
    >r <string-reader> r> with-stream ; inline

: <byte-reader> ( byte-array encoding -- stream )
    >r >byte-vector dup reverse-here r> <decoding> ;

: with-byte-reader ( byte-array encoding quot -- )
    >r <byte-reader> r> with-stream ; inline
