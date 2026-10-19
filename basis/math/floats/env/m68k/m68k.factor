! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs
classes.struct combinators cpu.m68k.assembler kernel literals
math math.bitwise math.floats.env math.floats.env.private
sequences system ;
IN: math.floats.env.m68k

STRUCT: m68k-env
    { fpcr uint }
    { fpsr uint } ;

: get-m68k-env ( env -- )
    void { void* } cdecl [
        7 4 0 LOADA.L
        0 GET-FPCR 0 0 0 STORE.L
        0 GET-FPSR 0 0 4 STORE.L
    ] alien-assembly ;

: set-m68k-env ( env -- )
    void { void* } cdecl [
        7 4 0 LOADA.L
        0 0 0 LOAD.L 0 SET-FPCR
        0 4 0 LOAD.L 0 SET-FPSR
    ] alien-assembly ;

: <m68k-env> ( -- env )
    m68k-env (struct) [ get-m68k-env ] keep ;

M: m68k.32 (fp-env-registers) <m68k-env> 1array ;
M: m68k-env (set-fp-env-register) set-m68k-env ;

! FPSR has separate current and accrued exception bytes. Clear both when
! replacing the logical flags; leave the condition codes and quotient intact.
CONSTANT: m68k-exception-bits 0xfff8
CONSTANT: m68k-exception>bit
    H{
        { +fp-invalid-operation+ 0x80 }
        { +fp-overflow+          0x40 }
        { +fp-underflow+         0x20 }
        { +fp-zero-divide+       0x10 }
        { +fp-inexact+           0x08 }
    }

! Invalid operation includes unordered predicates, signaling NaNs and operand
! errors. Both inexact-operation and inexact-input enables belong to inexact.
CONSTANT: m68k-trap-bits 0xff00
CONSTANT: m68k-trap>bit
    H{
        { +fp-invalid-operation+ 0xe000 }
        { +fp-overflow+          0x1000 }
        { +fp-underflow+         0x0800 }
        { +fp-zero-divide+       0x0400 }
        { +fp-inexact+           0x0300 }
    }

CONSTANT: m68k-rounding-mode-bits 0x30
CONSTANT: m68k-rounding-mode>bit
    $[ H{
        { +round-nearest+ 0x00 }
        { +round-zero+    0x10 }
        { +round-down+    0x20 }
        { +round-up+      0x30 }
    } >biassoc ]

M: m68k-env (get-exception-flags)
    fpsr>> m68k-exception>bit mask> ; inline
M: m68k-env (set-exception-flags)
    '[ _ m68k-exception>bit >mask m68k-exception-bits remask ] change-fpsr ; inline

M: m68k-env (get-fp-traps)
    fpcr>> m68k-trap>bit mask> ; inline
M: m68k-env (set-fp-traps)
    '[ _ m68k-trap>bit >mask m68k-trap-bits remask ] change-fpcr ; inline

M: m68k-env (get-rounding-mode)
    fpcr>> m68k-rounding-mode-bits mask m68k-rounding-mode>bit value-at ; inline
M: m68k-env (set-rounding-mode)
    '[ _ m68k-rounding-mode>bit at m68k-rounding-mode-bits remask ] change-fpcr ; inline

! The 68881/68882/68040 have no flush-to-zero control.
ERROR: unsupported-m68k-denormal-mode mode ;
M: m68k.32 denormal-flush-supported? f ;
M: m68k-env (get-denormal-mode) drop +denormal-keep+ ;
M: m68k-env (set-denormal-mode)
    dup +denormal-keep+ eq? [ drop ] [ unsupported-m68k-denormal-mode ] if ;
