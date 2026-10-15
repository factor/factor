! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
combinators cpu.mips.assembler cpu.mips.assembler.registers kernel literals
math math.bitwise math.floats.env math.floats.env.private system ;
IN: math.floats.env.mips

STRUCT: mips-env { fcsr uint } ;

: get-mips-env ( env -- )
    void { void* } cdecl [ temp F31 CFC1 NOP temp A0 0 SW ] alien-assembly ;
: set-mips-env ( env -- )
    void { void* } cdecl [ temp A0 0 LW NOP temp F31 CTC1 NOP NOP NOP ] alien-assembly ;
M: mips (fp-env-registers)
    mips-env (struct) [ get-mips-env ] keep 1array ;
! Cause bits reflect the last operation, not accrued exception flags.
! Clear them before CTC1 so enabling a trap cannot retrigger an old cause.
M: mips-env (set-fp-env-register)
    [ 0x3f000 unmask ] change-fcsr set-mips-env ;

CONSTANT: mips-exception>bit
    H{ { +fp-invalid-operation+ 0x40 } { +fp-zero-divide+ 0x20 }
       { +fp-overflow+ 0x10 } { +fp-underflow+ 0x08 } { +fp-inexact+ 0x04 } }
CONSTANT: mips-trap>bit
    H{ { +fp-invalid-operation+ 0x800 } { +fp-zero-divide+ 0x400 }
       { +fp-overflow+ 0x200 } { +fp-underflow+ 0x100 } { +fp-inexact+ 0x80 } }
CONSTANT: mips-rounding-mode>bit
    $[ H{ { +round-nearest+ 0 } { +round-zero+ 1 }
          { +round-up+ 2 } { +round-down+ 3 } } >biassoc ]
M: mips-env (get-exception-flags) fcsr>> mips-exception>bit mask> ;
M: mips-env (set-exception-flags)
    '[ _ mips-exception>bit >mask 0x7c remask ] change-fcsr ;
M: mips-env (get-fp-traps) fcsr>> mips-trap>bit mask> ;
M: mips-env (set-fp-traps)
    '[ _ mips-trap>bit >mask 0xf80 remask ] change-fcsr ;
M: mips-env (get-rounding-mode)
    fcsr>> 3 mask mips-rounding-mode>bit value-at ;
M: mips-env (set-rounding-mode)
    '[ _ mips-rounding-mode>bit at 3 remask ] change-fcsr ;
M: mips-env (get-denormal-mode)
    fcsr>> 24 bit? +denormal-flush+ +denormal-keep+ ? ;
M: mips-env (set-denormal-mode)
    '[ _ +denormal-flush+ eq? [ 24 set-bit ] [ 24 clear-bit ] if ] change-fcsr ;
