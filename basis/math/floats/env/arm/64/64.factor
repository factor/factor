! Copyright (C) 2025 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs
classes.struct combinators cpu.arm.64.assembler
cpu.arm.64.assembler.registers kernel literals math math.bitwise
math.floats.env math.floats.env.private ;
IN: math.floats.env.arm.64

STRUCT: arm64-env
    { fpcr longlong }
    { fpsr longlong } ;

: get-arm64-env ( arm64-env -- )
    void { void* } cdecl [
        temp1 FPCR MRS
        temp2 FPSR MRS
        temp1 temp2 arg1 [] STP
    ] alien-assembly ;

: set-arm64-env ( arm64-env -- )
    void { void* } cdecl [
        temp1 temp2 arg1 [] LDP
        FPCR temp1 MSR
        FPSR temp2 MSR
    ] alien-assembly ;

: <arm64-env> ( -- arm64-env )
    arm64-env (struct) [ get-arm64-env ] keep ;

M: arm64-env (fp-env-registers) ( -- fp-envs )
    <arm64-env> 1array ;

M: arm64-env (set-fp-env-register) ( fp-env -- )
    set-arm64-env ;

SINGLETON: +fp-denormal+

CONSTANT: arm64-exception-bits 0x9f
CONSTANT: arm64-exception>bit
    H{
        { +fp-invalid-operation+ 0x01 }
        { +fp-zero-divide+       0x02 }
        { +fp-overflow+          0x04 }
        { +fp-underflow+         0x08 }
        { +fp-inexact+           0x10 }
        { +fp-denormal+          0x80 }
    }

CONSTANT: arm64-trap-bits 0x9f00
CONSTANT: arm64-trap>bit
    H{
        { +fp-invalid-operation+ 0x0100 }
        { +fp-zero-divide+       0x0200 }
        { +fp-overflow+          0x0400 }
        { +fp-underflow+         0x0800 }
        { +fp-inexact+           0x1000 }
        { +fp-denormal+          0x8000 }
    }

CONSTANT: arm64-rounding-mode-bits 0xc00000
CONSTANT: arm64-rounding-mode>bit
    $[ H{
        { +round-nearest+ 0x000000 }
        { +round-up+      0x400000 }
        { +round-down+    0x800000 }
        { +round-zero+    0xc00000 }
    } >biassoc ]

CONSTANT: arm64-denormal-mode-bit 24

M: arm64-env (get-exception-flags) ( fp-env -- exceptions )
    fpsr>> arm64-exception>bit mask> ; inline

M: arm64-env (set-exception-flags) ( fp-env exceptions -- fp-env )
    '[ _ arm64-exception>bit >mask arm64-exception-bits remask ] change-fpsr ;

M: arm64-env (get-fp-traps) ( fp-env -- exceptions )
    fpcr>> arm64-trap>bit mask> ; inline

M: arm64-env (set-fp-traps) ( fp-env mode -- fp-env )
    '[ _ arm64-trap>bit >mask arm64-trap-bits remask ] change-fpcr ;

M: arm64-env (get-rounding-mode) ( fp-env -- mode )
    fpcr>> arm64-rounding-mode-bits mask arm64-rounding-mode>bit value-at ; inline

M: arm64-env (set-rounding-mode) ( fp-env mode -- fp-env )
    '[ _ arm64-rounding-mode>bit at arm64-rounding-mode-bits remask ] change-fpcr ; inline

M: arm64-env (get-denormal-mode) ( fp-env -- mode )
    fpcr>> arm64-denormal-mode-bit bit? +denormal-keep+ +denormal-flush+ ? ; inline

M: arm64-env (set-denormal-mode) ( fp-env mode -- fp-env )
    '[
        _ {
            { +denormal-keep+ [ arm64-denormal-mode-bit set-bit ] }
            { +denormal-flush+ [ arm64-denormal-mode-bit clear-bit ] }
        } case
    ] change-fpcr ;
