! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs
classes.struct combinators cpu.arm.32.assembler
cpu.arm.32.assembler.registers kernel literals math math.bitwise
math.floats.env math.floats.env.private system ;
IN: math.floats.env.arm.32

STRUCT: arm32-env
    { fpscr uint } ;

: get-arm32-env ( arm32-env -- )
    void { void* } cdecl [
        R1 VMRS
        R1 R0 0 <+> STR
    ] alien-assembly ;

: set-arm32-env ( arm32-env -- )
    void { void* } cdecl [
        R1 R0 0 <+> LDR
        R1 VMSR
    ] alien-assembly ;

! Exception trapping is optional in ARMv7 VFP. The baseline backend
! does not advertise it; VFPv3 implementations may ignore enable bits.
M: arm.32 fp-traps-supported? f ;

: <arm32-env> ( -- arm32-env )
    arm32-env (struct) [ get-arm32-env ] keep ;

M: arm.32 (fp-env-registers) ( -- fp-envs )
    <arm32-env> 1array ;

M: arm32-env (set-fp-env-register) ( fp-env -- )
    set-arm32-env ;

SINGLETON: +fp-denormal+

CONSTANT: arm32-exception-bits 0x9f
CONSTANT: arm32-exception>bit
    H{
        { +fp-invalid-operation+ 0x01 }
        { +fp-zero-divide+       0x02 }
        { +fp-overflow+          0x04 }
        { +fp-underflow+         0x08 }
        { +fp-inexact+           0x10 }
        { +fp-denormal+          0x80 }
    }

CONSTANT: arm32-trap-bits 0x9f00
CONSTANT: arm32-trap>bit
    H{
        { +fp-invalid-operation+ 0x0100 }
        { +fp-zero-divide+       0x0200 }
        { +fp-overflow+          0x0400 }
        { +fp-underflow+         0x0800 }
        { +fp-inexact+           0x1000 }
        { +fp-denormal+          0x8000 }
    }

CONSTANT: arm32-rounding-mode-bits 0xc00000
CONSTANT: arm32-rounding-mode>bit
    $[ H{
        { +round-nearest+ 0x000000 }
        { +round-up+      0x400000 }
        { +round-down+    0x800000 }
        { +round-zero+    0xc00000 }
    } >biassoc ]

CONSTANT: arm32-denormal-mode-bit 24

M: arm32-env (get-exception-flags) ( fp-env -- exceptions )
    fpscr>> arm32-exception>bit mask> ; inline

M: arm32-env (set-exception-flags) ( fp-env exceptions -- fp-env )
    '[ _ arm32-exception>bit >mask arm32-exception-bits remask ] change-fpscr ;

M: arm32-env (get-fp-traps) ( fp-env -- exceptions )
    fpscr>> arm32-trap>bit mask> ; inline

M: arm32-env (set-fp-traps) ( fp-env mode -- fp-env )
    '[ _ arm32-trap>bit >mask arm32-trap-bits remask ] change-fpscr ;

M: arm32-env (get-rounding-mode) ( fp-env -- mode )
    fpscr>> arm32-rounding-mode-bits mask arm32-rounding-mode>bit value-at ; inline

M: arm32-env (set-rounding-mode) ( fp-env mode -- fp-env )
    '[ _ arm32-rounding-mode>bit at arm32-rounding-mode-bits remask ] change-fpscr ; inline

M: arm32-env (get-denormal-mode) ( fp-env -- mode )
    fpscr>> arm32-denormal-mode-bit bit? +denormal-flush+ +denormal-keep+ ? ; inline

M: arm32-env (set-denormal-mode) ( fp-env mode -- fp-env )
    '[
        _ {
            { +denormal-flush+ [ arm32-denormal-mode-bit set-bit ] }
            { +denormal-keep+ [ arm32-denormal-mode-bit clear-bit ] }
        } case
    ] change-fpscr ;
