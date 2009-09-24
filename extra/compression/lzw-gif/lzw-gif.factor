! Copyright (C) 2009 Doug Coleman, Keith Lazuka
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io kernel math namespaces
prettyprint sequences vectors ;
QUALIFIED-WITH: bitstreams bs
IN: compression.lzw-gif

SYMBOL: clear-code
4 clear-code set-global

SYMBOL: end-of-information
5 end-of-information set-global

TUPLE: lzw input output table code old-code initial-code-size code-size ;

SYMBOL: table-full

: initial-uncompress-table ( -- seq )
    end-of-information get 1 + iota [ 1vector ] V{ } map-as ;

: reset-lzw-uncompress ( lzw -- lzw )
    initial-uncompress-table >>table
    dup initial-code-size>> >>code-size ;

: <lzw-uncompress> ( code-size input -- obj )
    lzw new
        swap >>input
        swap >>initial-code-size
        dup initial-code-size>> >>code-size
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

: maybe-increment-code-size ( lzw -- lzw )
    dup [ table>> length ] [ code-size>> 2^ ] bi =
    [ [ 1 + ] change-code-size ] when ;

: add-to-table ( seq lzw -- )
    [ table>> push ]
    [ maybe-increment-code-size 2drop ] 2bi ;

: lzw-read ( lzw -- lzw n )
    [ ] [ code-size>> ] [ input>> ] tri bs:read ;

DEFER: lzw-uncompress-char
: handle-clear-code ( lzw -- )
    reset-lzw-uncompress
    lzw-read dup end-of-information get = [
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
        dup code>> end-of-information get = [
            drop
        ] [
            dup code>> clear-code get = [
                handle-clear-code
            ] [
                handle-uncompress-code
                lzw-uncompress-char
            ] if
        ] if
    ] [
        drop
    ] if* ;

: register-special-codes ( first-code-size -- )
    [
        1 - 2^ dup clear-code set
        1 + end-of-information set
    ] keep ;

: lzw-uncompress ( code-size seq -- byte-array )
    [ register-special-codes ] dip
    bs:<lsb0-bit-reader>
    <lzw-uncompress>
    [ lzw-uncompress-char ] [ output>> ] bi ;
