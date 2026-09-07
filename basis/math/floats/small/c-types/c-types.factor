! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types cpu.architecture
kernel math.floats.small ;
QUALIFIED: math
IN: math.floats.small.c-types

! These are memory element types. Passing a scalar half or bfloat by value
! requires an ABI definition; only the 128-bit vector types have one here.
SYMBOLS: half bfloat ;
TUPLE: small-float-c-type < abstract-c-type ;
ERROR: small-float-scalar-abi-unsupported ;
M: small-float-c-type c-type-rep drop small-float-scalar-abi-unsupported ;
M: small-float-c-type c-type-getter getter>> ;
M: small-float-c-type c-type-setter setter>> ;
M: small-float-c-type c-type-copier drop [ ] ;
M: small-float-c-type base-type ;

small-float-c-type new
    math:float >>class math:float >>boxed-class
    [ alien-unsigned-2 half-bits>float ] >>getter
    [ [ float>half-bits ] 2dip set-alien-unsigned-2 ] >>setter
    [ ] >>boxer-quot [ math:>float ] >>unboxer-quot
    2 >>size 2 >>align 2 >>align-first
\ half typedef

small-float-c-type new
    math:float >>class math:float >>boxed-class
    [ alien-unsigned-2 bfloat-bits>float ] >>getter
    [ [ float>bfloat-bits ] 2dip set-alien-unsigned-2 ] >>setter
    [ ] >>boxer-quot [ math:>float ] >>unboxer-quot
    2 >>size 2 >>align 2 >>align-first
\ bfloat typedef

M: half-8-rep rep-component-type drop half ;
M: bfloat-8-rep rep-component-type drop bfloat ;
