! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
cpu.sparc.assembler kernel literals math math.bitwise math.floats.env
math.floats.env.private system ;
IN: math.floats.env.sparc

! Native width preserves the V9 condition codes in the upper FSR word.
STRUCT: sparc-env { fsr ulong } ;
ERROR: unsupported-sparc-denormal-mode mode ;
! NS is implementation-dependent and is not a portable flush-to-zero mode.
M: sparc denormal-flush-supported? f ;

: get-sparc-env ( env -- )
    void { void* } cdecl [
        cpu sparc.64? [ 8 0 STXFSR ] [ 8 0 STFSR ] if
    ] alien-assembly ;
: set-sparc-env ( env -- )
    void { void* } cdecl [
        cpu sparc.64? [ 8 0 LDXFSR ] [ 8 0 LDFSR ] if
    ] alien-assembly ;
M: sparc (fp-env-registers)
    sparc-env (struct) [ get-sparc-env ] keep 1array ;
M: sparc-env (set-fp-env-register) set-sparc-env ;

! AEXC bits 5..9 are accrued exceptions; TEM bits 23..27 enable traps.
CONSTANT: sparc-exception>bit
    H{ { +fp-invalid-operation+ 0x200 } { +fp-overflow+ 0x100 }
       { +fp-underflow+ 0x80 } { +fp-zero-divide+ 0x40 } { +fp-inexact+ 0x20 } }
CONSTANT: sparc-trap>bit
    H{ { +fp-invalid-operation+ 0x8000000 } { +fp-overflow+ 0x4000000 }
       { +fp-underflow+ 0x2000000 } { +fp-zero-divide+ 0x1000000 }
       { +fp-inexact+ 0x800000 } }
CONSTANT: sparc-rounding-mode>bit
    $[ H{ { +round-nearest+ 0 } { +round-zero+ 0x40000000 }
          { +round-up+ 0x80000000 } { +round-down+ 0xc0000000 } } >biassoc ]
M: sparc-env (get-exception-flags) fsr>> sparc-exception>bit mask> ;
M: sparc-env (set-exception-flags)
    '[ _ sparc-exception>bit >mask 0x3e0 remask ] change-fsr ;
M: sparc-env (get-fp-traps) fsr>> sparc-trap>bit mask> ;
M: sparc-env (set-fp-traps)
    '[ _ sparc-trap>bit >mask 0xf800000 remask ] change-fsr ;
M: sparc-env (get-rounding-mode)
    fsr>> 0xc0000000 mask sparc-rounding-mode>bit value-at ;
M: sparc-env (set-rounding-mode)
    '[ _ sparc-rounding-mode>bit at 0xc0000000 remask ] change-fsr ;
M: sparc-env (get-denormal-mode) drop +denormal-keep+ ;
M: sparc-env (set-denormal-mode)
    dup +denormal-keep+ eq? [ drop ] [ unsupported-sparc-denormal-mode ] if ;
