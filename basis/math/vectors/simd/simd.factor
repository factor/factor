! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators fry kernel lexer math math.parser
math.vectors.simd.functor sequences splitting vocabs.generated
vocabs.loader vocabs.parser words ;
IN: math.vectors.simd

ERROR: bad-vector-size bits ;

<PRIVATE

: simd-vocab ( type -- vocab )
    "math.vectors.simd.instances." prepend ;

: parse-simd-name ( string -- c-type quot )
    "-" split1
    [ "alien.c-types" lookup dup heap-size ] [ string>number ] bi*
    * 8 * {
        { 128 [ [ define-simd-128 ] ] }
        { 256 [ [ define-simd-256 ] ] }
        [ bad-vector-size ]
    } case ;

PRIVATE>

: define-simd-vocab ( type -- vocab )
    [ simd-vocab ]
    [ '[ _ parse-simd-name call( type -- ) ] ] bi
    generate-vocab ;

SYNTAX: SIMD:
    scan define-simd-vocab use-vocab ;
