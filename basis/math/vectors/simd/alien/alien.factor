! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien accessors alien.c-types byte-arrays compiler.units
cpu.architecture locals kernel math math.vectors.simd
math.vectors.simd.intrinsics ;
IN: math.vectors.simd.alien

:: define-simd-type ( class rep -- )
    <c-type>
        byte-array >>class
        class >>boxed-class
        [ rep alien-vector ] >>getter
        [ [ underlying>> ] 2dip rep set-alien-vector ] >>setter
        16 >>size
        8 >>align
        rep >>rep
        [ class boa ] >>boxer-quot
        [ underlying>> ] >>unboxer-quot
    class name>> typedef ;

: define-4double-array-type ( -- )
    <c-type>
        4double-array >>class
        4double-array >>boxed-class
        [
            [ 2double-array-rep alien-vector ]
            [ 16 + >fixnum 2double-array-rep alien-vector ] 2bi
            4double-array boa
        ] >>getter
        [
            [ [ underlying1>> ] 2dip 2double-array-rep set-alien-vector ]
            [ [ underlying2>> ] 2dip 16 + >fixnum 2double-array-rep set-alien-vector ]
            3bi
        ] >>setter
        32 >>size
        8 >>align
        2double-array-rep >>rep
    "4double-array" typedef ;
[
    4float-array 4float-array-rep define-simd-type
    2double-array 2double-array-rep define-simd-type
    define-4double-array-type
] with-compilation-unit
