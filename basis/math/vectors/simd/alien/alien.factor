! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien accessors alien.c-types byte-arrays compiler.units
cpu.architecture locals kernel math math.vectors.simd
math.vectors.simd.intrinsics ;
IN: math.vectors.simd.alien

:: define-simd-128-type ( class rep -- )
    <c-type>
        byte-array >>class
        class >>boxed-class
        [ rep alien-vector class boa ] >>getter
        [ [ underlying>> ] 2dip rep set-alien-vector ] >>setter
        16 >>size
        8 >>align
        rep >>rep
    class name>> typedef ;

:: define-simd-256-type ( class rep -- )
    <c-type>
        class >>class
        class >>boxed-class
        [
            [ rep alien-vector ]
            [ 16 + >fixnum rep alien-vector ] 2bi
            class boa
        ] >>getter
        [
            [ [ underlying1>> ] 2dip rep set-alien-vector ]
            [ [ underlying2>> ] 2dip 16 + >fixnum rep set-alien-vector ]
            3bi
        ] >>setter
        32 >>size
        8 >>align
        rep >>rep
    class name>> typedef ;
[
    float-4 float-4-rep define-simd-128-type
    double-2 double-2-rep define-simd-128-type
    float-8 float-4-rep define-simd-256-type
    double-4 double-2-rep define-simd-256-type
] with-compilation-unit
