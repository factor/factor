! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
combinators cpu.loongarch.64.assembler cpu.loongarch.64.assembler.registers
kernel literals math math.bitwise math.floats.env math.floats.env.private
sequences system ;
IN: math.floats.env.loongarch.64

STRUCT: loongarch-env { fcsr uint } ;
ERROR: unsupported-loongarch-fp-traps exceptions ;
ERROR: unsupported-loongarch-denormal-mode mode ;
: get-loongarch-env ( env -- )
    void { void* } cdecl [ temp 3 CSRR temp A0 0 SW ] alien-assembly ;
: set-loongarch-env ( env -- )
    void { void* } cdecl [ temp A0 0 LWU 3 temp CSRW ] alien-assembly ;
M: loongarch.64 (fp-env-registers)
    loongarch-env (struct) [ get-loongarch-env ] keep 1array ;
M: loongarch-env (set-fp-env-register) set-loongarch-env ;
CONSTANT: loongarch-exception>bit
    H{ { +fp-invalid-operation+ 0x100000 } { +fp-zero-divide+ 0x080000 }
       { +fp-overflow+ 0x040000 } { +fp-underflow+ 0x020000 } { +fp-inexact+ 0x010000 } }
CONSTANT: loongarch-rounding-mode>bit
    $[ H{ { +round-nearest+ 0x00 } { +round-zero+ 0x100 }
          { +round-down+ 0x300 } { +round-up+ 0x200 } } >biassoc ]
M: loongarch-env (get-exception-flags) fcsr>> loongarch-exception>bit mask> ;
M: loongarch-env (set-exception-flags)
    '[ _ loongarch-exception>bit >mask 0x1f1f0000 remask ] change-fcsr ;
M: loongarch-env (get-rounding-mode)
    fcsr>> 0x300 mask loongarch-rounding-mode>bit value-at ;
M: loongarch-env (set-rounding-mode)
    '[ _ loongarch-rounding-mode>bit at 0x300 remask ] change-fcsr ;
M: loongarch-env (get-fp-traps)
    fcsr>> 16 shift loongarch-exception>bit mask> ;
M: loongarch-env (set-fp-traps)
    '[ _ loongarch-exception>bit >mask -16 shift 0x1f remask ] change-fcsr ;
M: loongarch-env (get-denormal-mode) drop +denormal-keep+ ;
M: loongarch-env (set-denormal-mode)
    dup +denormal-keep+ eq? [ drop ] [ unsupported-loongarch-denormal-mode ] if ;
