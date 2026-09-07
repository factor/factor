! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax continuations cpu.arm.64.features kernel
locals math.bitwise sequences system ;
IN: cpu.arm.64.features.linux

LIBRARY: libc
FUNCTION: ulong getauxval ( ulong type )

M:: linux probe-arm64-features
    [
        16 getauxval 26 getauxval :> ( hwcap hwcap2 )
        {
            { "dotprod" 20 }
            { "fp16" 10 }
        } [ second hwcap swap bit? ] filter [ first ] map
        {
            { "bf16" 14 }
            { "i8mm" 13 }
        } [ second hwcap2 swap bit? ] filter [ first ] map append
    ] [ drop { } ] recover ;
