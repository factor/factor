! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators fry kernel lexer math math.parser
math.vectors.simd.functor sequences splitting vocabs.generated
vocabs.loader vocabs.parser words ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors.simd

ERROR: bad-base-type type ;

<PRIVATE

: simd-vocab ( base-type -- vocab )
    "math.vectors.simd.instances." prepend ;

: parse-base-type ( string -- c-type )
    {
        { "char" [ c:char ] }
        { "uchar" [ c:uchar ] }
        { "short" [ c:short ] }
        { "ushort" [ c:ushort ] }
        { "int" [ c:int ] }
        { "uint" [ c:uint ] }
        { "longlong" [ c:longlong ] }
        { "ulonglong" [ c:ulonglong ] }
        { "float" [ c:float ] }
        { "double" [ c:double ] }
        [ bad-base-type ]
    } case ;

PRIVATE>

: define-simd-vocab ( type -- vocab )
    [ simd-vocab ] keep '[
        _ parse-base-type
        [ define-simd-128 ]
        [ define-simd-256 ] bi
    ] generate-vocab ;

SYNTAX: SIMD:
    scan define-simd-vocab use-vocab ;
