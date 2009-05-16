! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors assocs byte-arrays combinators
io.encodings.binary io.streams.byte-array kernel math sequences
vectors ;
IN: compression.lzw

QUALIFIED-WITH: bitstreams bs

CONSTANT: clear-code 256
CONSTANT: end-of-information 257

TUPLE: lzw input output table code old-code ;

SYMBOL: table-full

: lzw-bit-width ( n -- n' )
    {
        { [ dup 510 <= ] [ drop 9 ] }
        { [ dup 1022 <= ] [ drop 10 ] }
        { [ dup 2046 <= ] [ drop 11 ] }
        { [ dup 4094 <= ] [ drop 12 ] }
        [ drop table-full ]
    } cond ;

: lzw-bit-width-uncompress ( lzw -- n )
    table>> length lzw-bit-width ;

: initial-uncompress-table ( -- seq )
    258 iota [ 1vector ] V{ } map-as ;

: reset-lzw-uncompress ( lzw -- lzw )
    initial-uncompress-table >>table ;

: <lzw-uncompress> ( input -- obj )
    lzw new
        swap >>input
        BV{ } clone >>output
        reset-lzw-uncompress ;

ERROR: not-in-table value ;

: lookup-old-code ( lzw -- vector )
    [ old-code>> ] [ table>> ] bi nth ;

: lookup-code ( lzw -- vector )
    [ code>> ] [ table>> ] bi nth ;

: code-in-table? ( lzw -- ? )
    [ code>> ] [ table>> length ] bi < ;

: code>old-code ( lzw -- lzw )
    dup code>> >>old-code ;

: write-code ( lzw -- )
    [ lookup-code ] [ output>> ] bi push-all ;

: add-to-table ( seq lzw -- ) table>> push ;

: lzw-read ( lzw -- lzw n )
    [ ] [ lzw-bit-width-uncompress ] [ input>> ] tri bs:read ;

DEFER: lzw-uncompress-char
: handle-clear-code ( lzw -- )
    reset-lzw-uncompress
    lzw-read dup end-of-information = [
        2drop
    ] [
        >>code
        [ write-code ]
        [ code>old-code ] bi
        lzw-uncompress-char
    ] if ;

: handle-uncompress-code ( lzw -- lzw )
    dup code-in-table? [
        [ write-code ]
        [
            [
                [ lookup-old-code ]
                [ lookup-code first ] bi suffix
            ] [ add-to-table ] bi
        ] [ code>old-code ] tri
    ] [
        [
            [ lookup-old-code dup first suffix ] keep
            [ output>> push-all ] [ add-to-table ] 2bi
        ] [ code>old-code ] bi
    ] if ;
    
: lzw-uncompress-char ( lzw -- )
    lzw-read [
        >>code
        dup code>> end-of-information = [
            drop
        ] [
            dup code>> clear-code = [
                handle-clear-code
            ] [
                handle-uncompress-code
                lzw-uncompress-char
            ] if
        ] if
    ] [
        drop
    ] if* ;

: lzw-uncompress ( seq -- byte-array )
    bs:<msb0-bit-reader>
    <lzw-uncompress>
    [ lzw-uncompress-char ] [ output>> ] bi ;
