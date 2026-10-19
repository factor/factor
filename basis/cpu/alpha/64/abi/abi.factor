! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays classes.struct
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
cpu.architecture kernel layouts
locals math math.complex namespaces sequences system ;
QUALIFIED-WITH: alien.c-types c
IN: cpu.alpha.64.abi
! GNU Alpha returns C99 complex components in F0/F1 and passes them
! in consecutive floating-point argument slots. Ordinary aggregates use
! integer argument slots and a hidden result pointer.
M: alpha.64 value-struct? drop t ;
: alpha-complex? ( c-type -- ? ) c-type-boxed-class complex eq? ;
: alpha-complex-rep ( c-type -- rep )
    heap-size 8 = float-rep double-rep ? ;
M: alpha.64 return-struct-in-registers? alpha-complex? ;
M:: alpha.64 flatten-struct-type ( c-type -- reps )
    c-type alpha-complex? [
        c-type alpha-complex-rep dup rep-size f f rot 4array 2 swap <array>
    ] [
        c-type heap-size cell align cell /i { int-rep f f } <array>
    ] if record-reg-reps ;
M:: alpha.64 struct-components ( reps c-type -- offsets types )
    c-type alpha-complex? [
        c-type heap-size 8 = c:float c:double ? base-type :> component
        { 0 } component heap-size suffix 2 component <array>
    ] [ reps c-type integer-struct-components ] if ;
