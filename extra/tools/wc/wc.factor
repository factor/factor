! Copyright (C) 2016 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: accessors alien.data command-line formatting io
io.encodings io.encodings.binary io.files kernel math
math.bitwise math.vectors math.vectors.simd namespaces sequences
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
    input-stream get dup decoder? [ stream>> ] when
    [ count-lines ] with-input-stream* ;

PRIVATE>

: wc ( path -- n )
    binary [ count-lines ] with-file-reader ;

: run-wc ( -- )
    command-line get [
        wc-stdin "%8d\n" printf
    ] [
        [ [ wc ] keep dupd "%8d %s\n" printf ] map
        dup length 1 > [ sum "%8d total\n" printf ] [ drop ] if
    ] if-empty ;

MAIN: run-wc
