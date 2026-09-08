! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.accessors alien.c-types compiler.units
cpu.architecture kernel math.floats.small ;
QUALIFIED: math
IN: math.floats.small.c-types

! Scalar ABI support uses numeric conversion and raw 16-bit FP payloads.
SYMBOLS: half bfloat ;

<PRIVATE
SYMBOLS: half-vararg bfloat-vararg ;
PRIVATE>

[
    ! Apple promotes scalar small floats to double in variadic calls.
    ! Quantize before promotion, as a C expression of the declared type does.
    double lookup-c-type clone
        [ math:>float float>half-bits half-bits>float ] >>unboxer-quot
    \ half-vararg typedef
    double lookup-c-type clone
        [ math:>float float>bfloat-bits bfloat-bits>float ] >>unboxer-quot
    \ bfloat-vararg typedef

    small-float-c-type new
        math:fixnum >>class math:float >>boxed-class
        [ alien-unsigned-2 ] >>getter
        [ set-alien-unsigned-2 ] >>setter
        [ half-bits>float ] >>boxer-quot [ math:>float float>half-bits ] >>unboxer-quot
        "from_unsigned_4" >>boxer "to_unsigned_4" >>unboxer
        half-rep >>rep half-vararg >>vararg-type
        2 >>size 2 >>align 2 >>align-first
    \ half typedef

    small-float-c-type new
        math:fixnum >>class math:float >>boxed-class
        [ alien-unsigned-2 ] >>getter
        [ set-alien-unsigned-2 ] >>setter
        [ bfloat-bits>float ] >>boxer-quot [ math:>float float>bfloat-bits ] >>unboxer-quot
        "from_unsigned_4" >>boxer "to_unsigned_4" >>unboxer
        bfloat-rep >>rep bfloat-vararg >>vararg-type
        2 >>size 2 >>align 2 >>align-first
    \ bfloat typedef
] with-compilation-unit

M: half-8-rep rep-component-type drop half ;
M: bfloat-8-rep rep-component-type drop bfloat ;
