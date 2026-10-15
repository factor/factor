! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
cpu.s390x.assembler cpu.s390x.assembler.registers kernel literals math
math.bitwise math.floats.env math.floats.env.private system ;
IN: math.floats.env.s390x

STRUCT: s390x-env { fpc uint } ;
ERROR: unsupported-s390x-denormal-mode mode ;
M: s390x denormal-flush-supported? f ;

: get-s390x-env ( env -- )
    void { void* } cdecl [ R0 EFPC R0 R0 R2 0 STY ] alien-assembly ;
: set-s390x-env ( env -- )
    void { void* } cdecl [ R0 R0 R2 0 LLGF R0 SFPC ] alien-assembly ;
M: s390x (fp-env-registers)
    s390x-env (struct) [ get-s390x-env ] keep 1array ;
M: s390x-env (set-fp-env-register) set-s390x-env ;

CONSTANT: s390x-exception>bit
    H{ { +fp-invalid-operation+ 0x00800000 } { +fp-zero-divide+ 0x00400000 }
       { +fp-overflow+ 0x00200000 } { +fp-underflow+ 0x00100000 }
       { +fp-inexact+ 0x00080000 } }
CONSTANT: s390x-trap>bit
    H{ { +fp-invalid-operation+ 0x80000000 } { +fp-zero-divide+ 0x40000000 }
       { +fp-overflow+ 0x20000000 } { +fp-underflow+ 0x10000000 }
       { +fp-inexact+ 0x08000000 } }
CONSTANT: s390x-rounding-mode>bit
    $[ H{ { +round-nearest+ 0 } { +round-zero+ 1 }
          { +round-down+ 3 } { +round-up+ 2 } } >biassoc ]

M: s390x-env (get-exception-flags) fpc>> s390x-exception>bit mask> ;
M: s390x-env (set-exception-flags)
    '[ _ s390x-exception>bit >mask 0x00f80000 remask ] change-fpc ;
M: s390x-env (get-fp-traps) fpc>> s390x-trap>bit mask> ;
M: s390x-env (set-fp-traps)
    '[ _ s390x-trap>bit >mask 0xf8000000 remask ] change-fpc ;
M: s390x-env (get-rounding-mode)
    fpc>> 3 mask s390x-rounding-mode>bit value-at ;
M: s390x-env (set-rounding-mode)
    '[ _ s390x-rounding-mode>bit at 3 remask ] change-fpc ;
! BFP arithmetic always retains subnormals; FPC has no flush-to-zero bit.
M: s390x-env (get-denormal-mode) drop +denormal-keep+ ;
M: s390x-env (set-denormal-mode)
    dup +denormal-keep+ eq? [ drop ] [ unsupported-s390x-denormal-mode ] if ;
