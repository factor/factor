! Copyright (C) 2009 Marc Fauconneau.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs constructors fry
hashtables io kernel locals math math.order math.parser
math.ranges multiline sequences ;
IN: compression.huffman

QUALIFIED-WITH: bitstreams bs

<PRIVATE

! huffman codes

TUPLE: huffman-code
    { value }
    { size }
    { code } ;

: <huffman-code> ( -- code ) 0 0 0 huffman-code boa ;
: next-size ( code -- ) [ 1+ ] change-size [ 2 * ] change-code drop ;
: next-code ( code -- ) [ 1+ ] change-code drop ;

:: all-patterns ( huff n -- seq )
    n log2 huff size>> - :> free-bits
    free-bits 0 >
    [ free-bits 2^ [0,b) [ huff code>> free-bits 2^ * + ] map ]
    [ huff code>> free-bits neg 2^ /i 1array ] if ;

:: huffman-each ( tdesc quot: ( huff -- ) -- )
    <huffman-code> :> code
    tdesc
    [
        code next-size
        [ code (>>value) code clone quot call code next-code ] each
    ] each ; inline

: update-reverse-table ( huff n table -- )
    [ drop all-patterns ]
    [ nip '[ _ swap _ set-at ] each ] 3bi ;

:: reverse-table ( tdesc n -- rtable )
   n f <array> <enum> :> table
   tdesc [ n table update-reverse-table ] huffman-each
   table seq>> ;

:: huffman-table ( tdesc max -- table )
   max f <array> :> table
   tdesc [ [ ] [ value>> ] bi table set-nth ] huffman-each
   table ;

PRIVATE>

! decoder

TUPLE: huffman-decoder
    { bs }
    { tdesc }
    { rtable }
    { bits/level } ;

CONSTRUCTOR: huffman-decoder ( bs tdesc -- decoder )
    16 >>bits/level
    [ ] [ tdesc>> ] [ bits/level>> 2^ ] tri reverse-table >>rtable ;

: read1-huff ( decoder -- elt )
    16 over [ bs>> bs:peek ] [ rtable>> nth ] bi ! first/last
    [ size>> swap bs>> bs:seek ] [ value>> ] bi ;

! %remove
: reverse-bits ( value bits -- value' )
    [ >bin ] [ CHAR: 0 pad-head <reversed> bin> ] bi* ;

: read1-huff2 ( decoder -- elt )
    16 over [ bs>> bs:peek 16 reverse-bits ] [ rtable>> nth ] bi ! first/last
    [ size>> swap bs>> bs:seek ] [ value>> ] bi ;

/*
: huff>string ( code -- str )
    [ value>> number>string ]
    [ [ code>> ] [ size>> bits>string ] bi ] bi
    " = " glue ;

: huff. ( code -- ) huff>string print ;

:: rtable. ( rtable -- )
    rtable length>> log2 :> n
    rtable <enum> [ swap n bits. [ huff. ] each ] assoc-each ;
*/
