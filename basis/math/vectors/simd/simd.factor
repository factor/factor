! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types combinators fry kernel parser math math.parser
math.vectors.simd.functor sequences splitting vocabs.generated
vocabs.loader vocabs.parser words accessors vocabs compiler.units
definitions ;
QUALIFIED-WITH: alien.c-types c
IN: math.vectors.simd

ERROR: bad-base-type type ;

<PRIVATE

: simd-vocab ( base-type -- vocab )
    name>> "math.vectors.simd.instances." prepend ;

: parse-base-type ( c-type -- c-type )
    dup { c:char c:uchar c:short c:ushort c:int c:uint c:longlong c:ulonglong c:float c:double } memq?
    [ bad-base-type ] unless ;

: forget-instances ( -- )
    [
        "math.vectors.simd.instances" child-vocabs
        [ forget-vocab ] each
    ] with-compilation-unit ;

PRIVATE>

: define-simd-vocab ( type -- vocab )
    parse-base-type
    [ simd-vocab ] keep '[
        _
        [ define-simd-128 ]
        [ define-simd-256 ] bi
    ] generate-vocab ;

SYNTAX: SIMD:
    scan-word define-simd-vocab use-vocab ;

