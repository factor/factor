! Copyright (C) 2016 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien.data command-line io io.encodings
io.encodings.binary io.files kernel math math.bitwise
math.parser math.vectors math.vectors.simd namespaces sequences
specialized-arrays ;

SPECIALIZED-ARRAY: uchar-16

IN: tools.wc

<PRIVATE

: aligned-slices ( seq -- head tail )
    dup length 0xf unmask cut-slice ; inline

: count-characters ( -- n )
    0 [ length + ] each-block-slice ; inline

: count-lines ( -- n )
    0 [
        aligned-slices [
            uchar-16 cast-array swap
            [ CHAR: \n uchar-16-with v= vcount + >fixnum ] reduce
        ] [ [ CHAR: \n = ] count + >fixnum ] bi*
    ] each-block-slice ; inline

: wc-stdin ( -- n )
    input-stream get binary re-decode
    [ count-lines ] with-input-stream* ;

: print-wc ( n name/f -- )
    [ number>string 8 CHAR: \s pad-head write ]
    [ bl [ write ] when* ] bi* nl ;

PRIVATE>

: wc ( path -- n )
    binary [ count-lines ] with-file-reader ;

: run-wc ( -- )
    command-line get [
        wc-stdin f print-wc
    ] [
        [
            dup file-exists? [
                [ wc ] keep dupd print-wc
            ] [
                write ": not found" print flush f
            ] if
        ] map sift dup length 1 > [ sum "total" print-wc ] [ drop ] if
    ] if-empty ;

MAIN: run-wc
