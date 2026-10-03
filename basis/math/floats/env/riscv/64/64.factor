! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
combinators cpu.riscv.64.assembler cpu.riscv.64.assembler.registers
kernel literals math math.bitwise math.floats.env math.floats.env.private
sequences system ;
IN: math.floats.env.riscv.64

STRUCT: riscv-env { fcsr uint } ;
ERROR: unsupported-riscv-fp-traps exceptions ;
ERROR: unsupported-riscv-denormal-mode mode ;
: get-riscv-env ( env -- )
    void { void* } cdecl [ temp 3 CSRR temp A0 0 SW ] alien-assembly ;
: set-riscv-env ( env -- )
    void { void* } cdecl [ temp A0 0 LWU 3 temp CSRW ] alien-assembly ;
M: riscv.64 (fp-env-registers)
    riscv-env (struct) [ get-riscv-env ] keep 1array ;
M: riscv-env (set-fp-env-register) set-riscv-env ;
CONSTANT: riscv-exception>bit
    H{ { +fp-invalid-operation+ 0x10 } { +fp-zero-divide+ 0x08 }
       { +fp-overflow+ 0x04 } { +fp-underflow+ 0x02 } { +fp-inexact+ 0x01 } }
CONSTANT: riscv-rounding-mode>bit
    $[ H{ { +round-nearest+ 0x00 } { +round-zero+ 0x20 }
          { +round-down+ 0x40 } { +round-up+ 0x60 } } >biassoc ]
M: riscv-env (get-exception-flags) fcsr>> riscv-exception>bit mask> ;
M: riscv-env (set-exception-flags)
    '[ _ riscv-exception>bit >mask 0x1f remask ] change-fcsr ;
M: riscv-env (get-rounding-mode)
    fcsr>> 0xe0 mask riscv-rounding-mode>bit value-at ;
M: riscv-env (set-rounding-mode)
    '[ _ riscv-rounding-mode>bit at 0xe0 remask ] change-fcsr ;
! The standard RISC-V floating-point extensions accrue flags and retain
! subnormals. They have no hardware exception-enable or flush-mode bits.
M: riscv-env (get-fp-traps) drop { } ;
M: riscv-env (set-fp-traps)
    dup empty? [ drop ] [ unsupported-riscv-fp-traps ] if ;
M: riscv-env (get-denormal-mode) drop +denormal-keep+ ;
M: riscv-env (set-denormal-mode)
    dup +denormal-keep+ eq? [ drop ] [ unsupported-riscv-denormal-mode ] if ;
