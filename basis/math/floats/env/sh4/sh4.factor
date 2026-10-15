! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
combinators cpu.sh.assembler kernel literals
math math.bitwise math.floats.env math.floats.env.private sequences system ;
IN: math.floats.env.sh4

! The SH4 rounding field defines nearest and toward-zero only.
! Values 2 and 3 are reserved, so directed rounding cannot be selected.
M: sh4 rounding-mode-supported?
    { +round-nearest+ +round-zero+ } member? ;

STRUCT: sh4-env { fpscr uint } ;

: get-sh4-env ( env -- )
    void { void* } cdecl [ 0 STS-FPSCR 0 4 STORE.L ] alien-assembly ;
: set-sh4-env ( env -- )
    void { void* } cdecl [ 4 0 MOV.L 0 LDS-FPSCR ] alien-assembly ;
M: sh4 (fp-env-registers)
    sh4-env (struct) [ get-sh4-env ] keep 1array ;
! Clear transient cause bits before restoring the control register.
M: sh4-env (set-fp-env-register)
    [ 0x3f000 unmask ] change-fpscr set-sh4-env ;

CONSTANT: sh4-exception>bit
    H{ { +fp-invalid-operation+ 0x40 } { +fp-zero-divide+ 0x20 }
       { +fp-overflow+ 0x10 } { +fp-underflow+ 0x08 } { +fp-inexact+ 0x04 } }
CONSTANT: sh4-trap>bit
    H{ { +fp-invalid-operation+ 0x800 } { +fp-zero-divide+ 0x400 }
       { +fp-overflow+ 0x200 } { +fp-underflow+ 0x100 } { +fp-inexact+ 0x80 } }
CONSTANT: sh4-rounding-mode>bit
    $[ H{ { +round-nearest+ 0 } { +round-zero+ 1 } } >biassoc ]
M: sh4-env (get-exception-flags) fpscr>> sh4-exception>bit mask> ;
M: sh4-env (set-exception-flags)
    '[ _ sh4-exception>bit >mask 0x7c remask ] change-fpscr ;
M: sh4-env (get-fp-traps) fpscr>> sh4-trap>bit mask> ;
M: sh4-env (set-fp-traps)
    '[ _ sh4-trap>bit >mask 0xf80 remask ] change-fpscr ;
M: sh4-env (get-rounding-mode)
    fpscr>> 3 mask sh4-rounding-mode>bit value-at ;
ERROR: unsupported-sh4-rounding-mode mode ;

: sh4-rounding-bits ( mode -- bits )
    dup sh4-rounding-mode>bit at
    [ nip ] [ unsupported-sh4-rounding-mode ] if* ;

M: sh4-env (set-rounding-mode)
    sh4-rounding-bits '[ _ 3 remask ] change-fpscr ;
M: sh4-env (get-denormal-mode)
    fpscr>> 18 bit? +denormal-flush+ +denormal-keep+ ? ;
M: sh4-env (set-denormal-mode)
    '[ _ +denormal-flush+ eq? [ 18 set-bit ] [ 18 clear-bit ] if ] change-fpscr ;
