! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.syntax arrays assocs
biassocs classes.struct cpu.alpha.64.assembler
cpu.alpha.64.assembler.registers kernel literals math math.bitwise
math.floats.env math.floats.env.private system vocabs ;
IN: math.floats.env.alpha

! FPCR supplies dynamic rounding. The kernel's IEEE control word supplies
! exception status, trap enables and denormal mapping on all three OSes.
STRUCT: alpha-env { fpcr ulonglong } { control ulonglong } ;
STRUCT: alpha-control { control ulonglong } ;

GENERIC: get-alpha-control ( env -- )
GENERIC: set-alpha-control ( env -- )

: get-alpha-fpcr ( env -- )
    void { void* } cdecl [
        EXCB F0 MF-FPCR F0 R16 0 STT
        EXCB
    ] alien-assembly ;
: set-alpha-fpcr ( env -- )
    void { void* } cdecl [
        EXCB F0 R16 0 LDT F0 MT-FPCR
        EXCB
    ] alien-assembly ;

M: alpha.64 (fp-env-registers)
    alpha-env (struct)
    [ get-alpha-control ] [ get-alpha-fpcr ] [ 1array ] tri ;
M: alpha-env (set-fp-env-register)
    [ set-alpha-fpcr ] [ set-alpha-control ] bi ;

CONSTANT: alpha-exception>bit
    H{ { +fp-invalid-operation+ 0x20000 } { +fp-zero-divide+ 0x40000 }
       { +fp-overflow+ 0x80000 } { +fp-underflow+ 0x100000 }
       { +fp-inexact+ 0x200000 } }
CONSTANT: alpha-trap>bit
    H{ { +fp-invalid-operation+ 0x02 } { +fp-zero-divide+ 0x04 }
       { +fp-overflow+ 0x08 } { +fp-underflow+ 0x10 }
       { +fp-inexact+ 0x20 } }
CONSTANT: alpha-rounding-mode>bit
    $[ H{ { +round-zero+ 0 } { +round-down+ 1 }
          { +round-nearest+ 2 } { +round-up+ 3 } } >biassoc ]

M: alpha-env (get-exception-flags) control>> alpha-exception>bit mask> ;
M: alpha-env (set-exception-flags)
    '[ _ alpha-exception>bit >mask 0x3e0000 remask ] change-control ;
M: alpha-env (get-fp-traps) control>> alpha-trap>bit mask> ;
M: alpha-env (set-fp-traps)
    '[ _ alpha-trap>bit >mask 0x3e remask ] change-control ;
M: alpha-env (get-rounding-mode)
    fpcr>> -58 shift 3 mask alpha-rounding-mode>bit value-at ;
M: alpha-env (set-rounding-mode)
    '[ _ alpha-rounding-mode>bit at 58 shift 3 58 shift remask ] change-fpcr ;
M: alpha-env (get-denormal-mode)
    control>> 0x3000 mask zero? +denormal-keep+ +denormal-flush+ ? ;
M: alpha-env (set-denormal-mode)
    '[ _ +denormal-flush+ eq? 0x3000 0 ? 0x3000 remask ] change-control ;

os linux? [ "math.floats.env.alpha.linux" ]
[ "math.floats.env.alpha.bsd" ] if require
