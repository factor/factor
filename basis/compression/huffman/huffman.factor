! Copyright (C) 2009 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs fry
hashtables io kernel locals math math.order math.parser
math.ranges multiline sequences bitstreams bit-arrays ;
IN: compression.huffman

QUALIFIED-WITH: bitstreams bs

<PRIVATE

TUPLE: huffman-code
    { value fixnum }
    { size fixnum }
    { code fixnum } ;

: <huffman-code> ( -- huffman-code )
    0 0 0 huffman-code boa ; inline

: next-size ( huffman-code -- )
    [ 1 + ] change-size
    [ 2 * ] change-code drop ; inline

: next-code ( huffman-code -- )
    [ 1 + ] change-code drop ; inline

:: all-patterns ( huffman-code n -- seq )
    n log2 huffman-code size>> - :> free-bits
    free-bits 0 >
    [ free-bits 2^ <iota> [ huffman-code code>> free-bits 2^ * + ] map ]
    [ huffman-code code>> free-bits neg 2^ /i 1array ] if ;

:: huffman-each ( ... tdesc quot: ( ... huffman-code -- ... ) -- ... )
    <huffman-code> :> code
    tdesc
    [
        code next-size
        [ code value<< code clone quot call code next-code ] each
    ] each ; inline

: update-reverse-table ( huffman-code n table -- )
    [ drop all-patterns ]
    [ nip '[ _ swap _ set-at ] each ] 3bi ;

:: reverse-table ( tdesc n -- rtable )
   n f <array> <enumerated> :> table
   tdesc [ n table update-reverse-table ] huffman-each
   table seq>> ;

PRIVATE>

TUPLE: huffman-decoder
    { bs bit-reader }
    { tdesc array }
    { rtable array }
    { bits/level fixnum } ;

: <huffman-decoder> ( bs tdesc -- huffman-decoder )
    huffman-decoder new
        swap >>tdesc
        swap >>bs
        16 >>bits/level
        dup [ tdesc>> ] [ bits/level>> 2^ ] bi reverse-table >>rtable ; inline

: read1-huff ( huffman-decoder -- elt )
    16 over [ bs>> bs:peek ] [ rtable>> nth ] bi
    [ size>> swap bs>> bs:seek ] [ value>> ] bi ; inline

: reverse-bits ( value bits -- value' )
    [ integer>bit-array ] dip
    f pad-tail reverse bit-array>integer ; inline

: read1-huff2 ( huffman-decoder -- elt )
    16 over [ bs>> bs:peek 16 reverse-bits ] [ rtable>> nth ] bi
    [ size>> swap bs>> bs:seek ] [ value>> ] bi ; inline
