! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types classes combinators
combinators.short-circuit kernel math math.vectors.simd
math.vectors.simd.intrinsics sequences ;
FROM: alien.c-types =>
    char uchar short ushort int uint longlong ulonglong
    float double heap-size ;
IN: math.vectors.conversion

ERROR: bad-vconvert from-type to-type ;
ERROR: bad-vconvert-input value expected-type ;

<PRIVATE

: float-type? ( c-type -- ? )
    { float double } member-eq? ;
: unsigned-type? ( c-type -- ? )
    { uchar ushort uint ulonglong } member-eq? ;

: check-vconvert-type ( value expected-type -- value )
    2dup instance? [ drop ] [ bad-vconvert-input ] if ; inline

:: [vconvert] ( from-element to-element from-size to-size from-type to-type -- quot )
    {
        {
            [ from-element to-element eq? ]
            [ [ ] ]
        }
        {
            [ from-element to-element [ float-type? not ] both? ]
            [ [ underlying>> to-type boa ] ]
        }
        {
            [ from-element float-type? ]
            [ from-type new simd-rep '[ underlying>> _ (simd-v>integer) to-type boa ] ]
        }
        {
            [ to-element   float-type? ]
            [ from-type new simd-rep '[ underlying>> _ (simd-v>float)   to-type boa ] ]
        }
    } cond
    [ from-type check-vconvert-type ] prepose ;

:: check-vpack ( from-element to-element from-type to-type steps -- )
    {
        [ steps 1 = not ]
        [ from-element to-element [ float-type? ] bi@ xor ]
        [ from-element unsigned-type? to-element unsigned-type? not and ]
    } 0|| [ from-type to-type bad-vconvert ] when ;

:: ([vpack-unsigned]) ( from-type to-type -- quot )
    from-type new simd-rep
    '[
        [ from-type check-vconvert-type underlying>> ] bi@
        _ (simd-vpack-unsigned) to-type boa
    ] ;

:: ([vpack-signed]) ( from-type to-type -- quot )
    from-type new simd-rep
    '[
        [ from-type check-vconvert-type underlying>> ] bi@
        _ (simd-vpack-signed)   to-type boa
    ] ;

:: [vpack] ( from-element to-element from-size to-size from-type to-type -- quot )
    from-size to-size /i log2 :> steps

    from-element to-element from-type to-type steps check-vpack

    from-type to-type to-element unsigned-type?
    [ ([vpack-unsigned]) ] [ ([vpack-signed]) ] if ;

:: check-vunpack ( from-element to-element from-type to-type steps -- )
    {
        [ steps 1 = not ]
        [ from-element to-element [ float-type? ] bi@ xor ]
        [ from-element unsigned-type? not to-element unsigned-type? and ]
    } 0|| [ from-type to-type bad-vconvert ] when ;

:: ([vunpack]) ( from-type to-type -- quot )
    from-type new simd-rep
    '[
        from-type check-vconvert-type underlying>> _
        [ (simd-vunpack-head) to-type boa ]
        [ (simd-vunpack-tail) to-type boa ] 2bi
    ] ;

:: [vunpack] ( from-element to-element from-size to-size from-type to-type -- quot )
    to-size from-size /i log2 :> steps
    from-element to-element from-type to-type steps check-vunpack
    from-type to-type ([vunpack]) ;

PRIVATE>

MACRO:: vconvert ( from-type to-type -- quot )
    from-type new [ simd-element-type ] [ byte-length ] bi :> ( from-element from-length )
    to-type   new [ simd-element-type ] [ byte-length ] bi :> ( to-element   to-length   )
    from-element heap-size :> from-size
    to-element   heap-size :> to-size

    from-length to-length = [ from-type to-type bad-vconvert ] unless

    from-element to-element from-size to-size from-type to-type {
        { [ from-size to-size < ] [ [vunpack] ] }
        { [ from-size to-size = ] [ [vconvert] ] }
        { [ from-size to-size > ] [ [vpack] ] }
    } cond ;
