! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs biassocs classes.struct
combinators cpu.openrisc.32.assembler
cpu.openrisc.32.assembler.registers kernel literals math math.bitwise
math.floats.env math.floats.env.private sequences sets system ;
IN: math.floats.env.openrisc.32

STRUCT: openrisc-env { fpcsr uint } ;

ERROR: unsupported-openrisc-fp-traps exceptions ;
ERROR: unsupported-openrisc-denormal-mode mode ;

: get-openrisc-env ( env -- )
    void { void* } cdecl [ temp ZERO 20 MFSPR temp arg1 0 SW ] alien-assembly ;
: set-openrisc-env ( env -- )
    void { void* } cdecl [ temp arg1 0 LWZ ZERO temp 20 MTSPR ] alien-assembly ;

M: openrisc.32 (fp-env-registers)
    openrisc-env (struct) [ get-openrisc-env ] keep 1array ;
M: openrisc-env (set-fp-env-register) set-openrisc-env ;

CONSTANT: openrisc-exception>bit
    H{ { +fp-invalid-operation+ 0x200 } { +fp-zero-divide+ 0x800 }
       { +fp-overflow+ 0x008 } { +fp-underflow+ 0x010 }
       { +fp-inexact+ 0x100 } }
CONSTANT: openrisc-rounding-mode>bit
    $[ H{ { +round-nearest+ 0x0 } { +round-zero+ 0x2 }
          { +round-up+ 0x4 } { +round-down+ 0x6 } } >biassoc ]

M: openrisc-env (get-exception-flags)
    fpcsr>> openrisc-exception>bit mask> ;
M: openrisc-env (set-exception-flags)
    '[ _ openrisc-exception>bit >mask 0xb18 remask ] change-fpcsr ;
M: openrisc-env (get-rounding-mode)
    fpcsr>> 0x6 mask openrisc-rounding-mode>bit value-at ;
M: openrisc-env (set-rounding-mode)
    '[ _ openrisc-rounding-mode>bit at 0x6 remask ] change-fpcsr ;

! OpenRISC has one global exception-enable bit, so it cannot select the
! individual exception sets required by the Factor interface.
M: openrisc-env (get-fp-traps)
    fpcsr>> 0 bit? all-fp-exceptions { } ? ;
M: openrisc-env (set-fp-traps)
    dup empty? [ drop [ 0 clear-bit ] change-fpcsr ] [
        dup all-fp-exceptions set= [ drop [ 0 set-bit ] change-fpcsr ]
        [ unsupported-openrisc-fp-traps ] if
    ] if ;

M: openrisc-env (get-denormal-mode) drop +denormal-keep+ ;
M: openrisc-env (set-denormal-mode)
    dup +denormal-keep+ eq? [ drop ] [ unsupported-openrisc-denormal-mode ] if ;
