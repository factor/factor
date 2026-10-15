! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
cpu.hppa.assembler cpu.hppa.assembler.registers kernel literals math
math.bitwise math.floats.env math.floats.env.private system ;
IN: math.floats.env.hppa

! FR0 contains the status word followed by the first exception word.
! A double-width field provides the alignment required by FSTD/FLDD.
STRUCT: hppa-env { fpsr ulonglong } ;
ERROR: unsupported-hppa-denormal-mode mode ;
M: hppa denormal-flush-supported? f ;

: get-hppa-env ( env -- )
    void { void* } cdecl [ F0 R26 0 FSTD F0 R26 0 FLDD ] alien-assembly ;
: set-hppa-env ( env -- )
    void { void* } cdecl [ F0 R26 0 FLDD ] alien-assembly ;
M: hppa (fp-env-registers)
    hppa-env (struct) [ get-hppa-env ] keep 1array ;
M: hppa-env (set-fp-env-register) set-hppa-env ;

! PA-RISC big-endian FR0: flags are status bits27..31, enables bits0..4.
CONSTANT: hppa-exception>bit
    H{ { +fp-invalid-operation+ 0x8000000000000000 }
       { +fp-zero-divide+ 0x4000000000000000 }
       { +fp-overflow+ 0x2000000000000000 }
       { +fp-underflow+ 0x1000000000000000 }
       { +fp-inexact+ 0x0800000000000000 } }
CONSTANT: hppa-trap>bit
    H{ { +fp-invalid-operation+ 0x1000000000 }
       { +fp-zero-divide+ 0x0800000000 }
       { +fp-overflow+ 0x0400000000 }
       { +fp-underflow+ 0x0200000000 }
       { +fp-inexact+ 0x0100000000 } }
CONSTANT: hppa-rounding-mode>bit
    $[ H{ { +round-nearest+ 0 } { +round-zero+ 0x20000000000 }
          { +round-up+ 0x40000000000 } { +round-down+ 0x60000000000 } } >biassoc ]
M: hppa-env (get-exception-flags) fpsr>> hppa-exception>bit mask> ;
M: hppa-env (set-exception-flags)
    '[ _ hppa-exception>bit >mask 0xf800000000000000 remask ] change-fpsr ;
M: hppa-env (get-fp-traps) fpsr>> hppa-trap>bit mask> ;
M: hppa-env (set-fp-traps)
    '[ _ hppa-trap>bit >mask 0x1f00000000 remask ] change-fpsr ;
M: hppa-env (get-rounding-mode)
    fpsr>> 0x60000000000 mask hppa-rounding-mode>bit value-at ;
M: hppa-env (set-rounding-mode)
    '[ _ hppa-rounding-mode>bit at 0x60000000000 remask ] change-fpsr ;
M: hppa-env (get-denormal-mode) drop +denormal-keep+ ;
M: hppa-env (set-denormal-mode)
    dup +denormal-keep+ eq? [ drop ] [ unsupported-hppa-denormal-mode ] if ;
