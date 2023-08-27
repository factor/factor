! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators kernel math math.order
sequences vectors ;
QUALIFIED-WITH: bitstreams bs
IN: compression.lzw

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

: initial-uncompress-table ( size -- seq )
    <iota> [ 1vector ] V{ } map-as ;

: reset-lzw-uncompress ( lzw -- lzw )
    dup end-of-information-code>> 1 + initial-uncompress-table >>table
    dup initial-code-size>> >>code-size ;

ERROR: code-size-zero ;

: <lzw-uncompress> ( input code-size class -- obj )
    new
        swap [ code-size-zero ] when-zero >>code-size
        dup code-size>> >>initial-code-size
        dup code-size>> 1 - 2^ >>clear-code
        dup clear-code>> 1 + >>end-of-information-code
        swap >>input
        BV{ } clone >>output
        reset-lzw-uncompress ;

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

: size-and-limit ( lzw -- m n ) [ table>> length ] [ code-size>> 2^ ] bi ;

M: tiff-lzw code-space-full? size-and-limit 1 - = ;
M: gif-lzw code-space-full? size-and-limit = ;

GENERIC: increment-code-size ( lzw -- lzw )

M: lzw increment-code-size [ 1 + ] change-code-size ;
M: gif-lzw increment-code-size [ 1 + 12 min ] change-code-size ;

: maybe-increment-code-size ( lzw -- lzw )
    dup code-space-full? [ increment-code-size ] when ;

: add-to-table ( seq lzw -- )
    [ table>> push ]
    [ maybe-increment-code-size 2drop ] 2bi ;

: lzw-read ( lzw -- lzw n )
    [ ] [ code-size>> ] [ input>> ] tri bs:read ;

: end-of-information? ( lzw code -- ? ) swap end-of-information-code>> = ;
: clear-code? ( lzw code -- ? ) swap clear-code>> = ;

DEFER: handle-clear-code
: lzw-process-next-code ( lzw quot: ( lzw code -- ) -- )
    [ lzw-read ] dip {
        { [ 2over end-of-information? ] [ 3drop ] }
        { [ 2over clear-code? ] [ 2drop handle-clear-code ] }
        [ call( lzw code -- ) ]
    } cond ; inline

DEFER: lzw-uncompress-char
: handle-clear-code ( lzw -- )
    reset-lzw-uncompress
    [
        >>code
        [ write-code ]
        [ code>old-code ] bi
        lzw-uncompress-char
    ] lzw-process-next-code ;

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
    [ >>code handle-uncompress-code lzw-uncompress-char ]
    lzw-process-next-code ;

: lzw-uncompress ( bitstream code-size class -- byte-array )
    <lzw-uncompress>
    [ lzw-uncompress-char ] [ output>> ] bi ;

: tiff-lzw-uncompress ( seq -- byte-array )
    bs:<msb0-bit-reader> 9 tiff-lzw lzw-uncompress ;

: gif-lzw-uncompress ( seq code-size -- byte-array )
    [ bs:<lsb0-bit-reader> ] dip gif-lzw lzw-uncompress ;
