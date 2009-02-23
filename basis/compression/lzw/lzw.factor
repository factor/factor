! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs bitstreams byte-vectors combinators io
io.encodings.binary io.streams.byte-array kernel math sequences
vectors ;
IN: compression.lzw

CONSTANT: clear-code 256
CONSTANT: end-of-information 257

TUPLE: lzw input output end-of-input? table count k omega omega-k #bits
code old-code ;

SYMBOL: table-full

ERROR: index-too-big n ;

: lzw-bit-width ( n -- n' )
    {
        { [ dup 510 <= ] [ drop 9 ] }
        { [ dup 1022 <= ] [ drop 10 ] }
        { [ dup 2046 <= ] [ drop 11 ] }
        { [ dup 4094 <= ] [ drop 12 ] }
        [ drop table-full ]
    } cond ;

: lzw-bit-width-compress ( lzw -- n )
    count>> lzw-bit-width ;

: lzw-bit-width-uncompress ( lzw -- n )
    table>> length lzw-bit-width ;

: initial-compress-table ( -- assoc )
    258 iota [ [ 1vector ] keep ] H{ } map>assoc ;

: initial-uncompress-table ( -- seq )
    258 iota [ 1vector ] V{ } map-as ;

: reset-lzw ( lzw -- lzw )
    257 >>count
    V{ } clone >>omega
    V{ } clone >>omega-k
    9 >>#bits ;

: reset-lzw-compress ( lzw -- lzw )
    f >>k
    initial-compress-table >>table reset-lzw ;

: reset-lzw-uncompress ( lzw -- lzw )
    initial-uncompress-table >>table reset-lzw ;

: <lzw-compress> ( input -- obj )
    lzw new
        swap >>input
        binary <byte-writer> <bitstream-writer> >>output
        reset-lzw-compress ;

: <lzw-uncompress> ( input -- obj )
    lzw new
        swap >>input
        BV{ } clone >>output
        reset-lzw-uncompress ;

: push-k ( lzw -- lzw )
    [ ]
    [ k>> ]
    [ omega>> clone [ push ] keep ] tri >>omega-k ;

: omega-k-in-table? ( lzw -- ? )
    [ omega-k>> ] [ table>> ] bi key? ;

ERROR: not-in-table value ;

: write-output ( lzw -- )
    [
        [ omega>> ] [ table>> ] bi ?at [ not-in-table ] unless
    ] [
        [ lzw-bit-width-compress ]
        [ output>> write-bits ] bi
    ] bi ;

: omega-k>omega ( lzw -- lzw )
    dup omega-k>> clone >>omega ;

: k>omega ( lzw -- lzw )
    dup k>> 1vector >>omega ;

: add-omega-k ( lzw -- )
    [ [ 1+ ] change-count count>> ]
    [ omega-k>> clone ]
    [ table>> ] tri set-at ;

: lzw-compress-char ( lzw k -- )
    >>k push-k dup omega-k-in-table? [
        omega-k>omega drop
    ] [
        [ write-output ]
        [ add-omega-k ]
        [ k>omega drop ] tri
    ] if ;

: (lzw-compress-chars) ( lzw -- )
    dup lzw-bit-width-compress table-full = [
        drop
    ] [
        dup input>> stream-read1
        [ [ lzw-compress-char ] [ drop (lzw-compress-chars) ] 2bi ]
        [ t >>end-of-input? drop ] if*
    ] if ;

: lzw-compress-chars ( lzw -- )
    {
        ! [ [ clear-code lzw-compress-char ] [ drop ] bi ] ! reset-lzw-compress drop ] bi ]
        [
            [ clear-code ] dip
            [ lzw-bit-width-compress ]
            [ output>> write-bits ] bi
        ]
        [ (lzw-compress-chars) ]
        [
            [ k>> ]
            [ lzw-bit-width-compress ]
            [ output>> write-bits ] tri
        ]
        [
            [ end-of-information ] dip
            [ lzw-bit-width-compress ]
            [ output>> write-bits ] bi
        ]
        [ ]
    } cleave dup end-of-input?>> [ drop ] [ lzw-compress-chars ] if ;

: lzw-compress ( byte-array -- seq )
    binary <byte-reader> <lzw-compress>
    [ lzw-compress-chars ] [ output>> stream>> ] bi ;

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
    [ ] [ lzw-bit-width-uncompress ] [ input>> ] tri read-bits 2drop ;

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
    binary <byte-reader> <bitstream-reader>
    <lzw-uncompress> [ lzw-uncompress-char ] [ output>> ] bi ;
