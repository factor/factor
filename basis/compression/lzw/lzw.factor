! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io kernel math namespaces
prettyprint sequences vectors ;
QUALIFIED-WITH: bitstreams bs
IN: compression.lzw

SYMBOL: current-lzw

TUPLE: lzw
input
output
table
code
old-code
initial-code-size
code-size
clear-code
end-of-information-code ;

TUPLE: tiff-lzw < lzw ;
TUPLE: gif-lzw < lzw ;

: initial-uncompress-table ( -- seq )
    current-lzw get end-of-information-code>> 1 +
    iota [ 1vector ] V{ } map-as ;

: reset-lzw-uncompress ( lzw -- lzw )
    initial-uncompress-table >>table
    dup initial-code-size>> >>code-size ;

: <lzw-uncompress> ( input code-size class -- obj )
    new
        swap >>code-size
        dup code-size>> >>initial-code-size
        dup code-size>> 1 - 2^ >>clear-code
        dup clear-code>> 1 + >>end-of-information-code
        swap >>input
        BV{ } clone >>output ;

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

GENERIC: code-space-full? ( lzw -- ? )

M: tiff-lzw code-space-full?
    [ table>> length ] [ code-size>> 2^ 1 - ] bi = ;

M: gif-lzw code-space-full?
    [ table>> length ] [ code-size>> 2^ ] bi = ;

: maybe-increment-code-size ( lzw -- lzw )
    dup code-space-full? [ [ 1 + ] change-code-size ] when ;

: add-to-table ( seq lzw -- )
    [ table>> push ]
    [ maybe-increment-code-size 2drop ] 2bi ;

: lzw-read ( lzw -- lzw n )
    [ ] [ code-size>> ] [ input>> ] tri bs:read ;

DEFER: lzw-uncompress-char
: handle-clear-code ( lzw -- )
    reset-lzw-uncompress
    lzw-read dup current-lzw get end-of-information-code>> = [
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
        dup code>> current-lzw get end-of-information-code>> = [
            drop
        ] [
            dup code>> current-lzw get clear-code>> = [
                handle-clear-code
            ] [
                handle-uncompress-code
                lzw-uncompress-char
            ] if
        ] if
    ] [
        drop
    ] if* ;

: lzw-uncompress ( bitstream code-size class -- byte-array )
    <lzw-uncompress> dup current-lzw [
        [ reset-lzw-uncompress drop ] [ lzw-uncompress-char ] [ output>> ] tri
    ] with-variable ;

: tiff-lzw-uncompress ( seq -- byte-array )
    bs:<msb0-bit-reader> 9 tiff-lzw lzw-uncompress ;

: gif-lzw-uncompress ( seq code-size -- byte-array )
    [ bs:<lsb0-bit-reader> ] dip gif-lzw lzw-uncompress ;
