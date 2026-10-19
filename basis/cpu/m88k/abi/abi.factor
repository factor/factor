! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! GNU OpenBSD 88100 ABI: one GPR argument bank, even 64-bit pairs.
USING: accessors alien.c-types arrays compiler.cfg.builder.alien.boxing
compiler.cfg.builder.alien.params compiler.cfg.hats compiler.cfg.instructions
cpu.architecture cpu.m88k cpu.m88k.assembler.registers kernel literals
locals math namespaces sequences system ;
IN: cpu.m88k.abi
M: m88k return-regs
    { { int-regs ${ R2 R3 } } { float-regs ${ R2 } } } ;
M: m88k param-regs
    drop { { int-regs ${ R2 R3 R4 R5 R6 R7 R8 R9 } } { float-regs { } } } ;
M: m88k dummy-stack-params? f ;
M: m88k dummy-int-params? f ;
M: m88k dummy-fp-params? f ;
M: m88k long-long-on-stack? f ;
M: m88k long-long-odd-register? f ;
M: m88k float-right-align-on-stack? f ;
M: m88k value-struct? drop t ;
M: m88k return-struct-in-registers? drop f ;
M: m88k struct-return-on-stack? f ;
M: m88k struct-return-register R12 ;
M: m88k return-struct-pointer? f ;
M: m88k flatten-struct-type
    call-next-method [ first t f 3array ] map ;
:: mark-argument ( reps alignment -- reps' )
    reps [| rep i | rep first3 rep param-natural-size 4array 0 suffix
        i zero? alignment 1 ? suffix ] map-index ;
: integer-fp-argument? ( c-type -- ? ) c-type-rep { float-rep double-rep } member? ;
:: integer-fp-reps ( c-type -- reps )
    c-type heap-size 4 align 4 /i { int-rep f f } <array> record-reg-reps ;
M:: m88k unbox-scalar-parameter ( src c-type -- vregs reps )
    src c-type unbox :> ( vregs reps )
    c-type integer-fp-argument? [
        reps unrecord-reg-reps drop
        c-type heap-size 8 = [
            8 8 f ^^local-allot :> buffer
            vregs first buffer 0 double-rep f ##store-memory-imm,
            buffer 0 int-rep f ^^load-memory-imm
            buffer 4 int-rep f ^^load-memory-imm 2array
        ] [ vregs first c-type c-type-rep ^^scalar>integer 1array ] if
        c-type integer-fp-reps
    ] [ vregs reps ] if c-type c-type-align mark-argument ;
M:: m88k flatten-scalar-parameter ( c-type -- reps )
    c-type integer-fp-argument? [ c-type integer-fp-reps ]
    [ c-type flatten-c-type ] if c-type c-type-align mark-argument ;
M:: m88k box-scalar-parameter ( vregs reps c-type -- dst )
    c-type integer-fp-argument? [
        c-type heap-size 8 = [
            8 8 f ^^local-allot :> buffer
            vregs first buffer 0 int-rep f ##store-memory-imm,
            vregs second buffer 4 int-rep f ##store-memory-imm,
            buffer 0 double-rep f ^^load-memory-imm
        ] [ vregs first c-type c-type-rep ^^integer>scalar ] if 1array
        c-type c-type-rep 1array c-type box
    ] [ vregs reps c-type box ] if ;
! A double spilled with only R9 free does not consume R9. The following
! scalar still uses it; both chunks of this double must go to the stack.
SYMBOL: stack-pair-remaining
M:: m88k prepare-abi-parameter-group ( rep -- )
    stack-pair-remaining get 0 or 0 > [
        t 1 rep set-nth -1 stack-pair-remaining +@
    ] [ rep length 5 > [ 5 rep nth 8 >= [
        int-regs get :> regs
        regs length 1 = [
            t 1 rep set-nth 1 stack-pair-remaining set
        ] [ regs empty? [ ] [ regs last n>> odd? [ regs pop* ] when ] if ] if
        stack-params get 8 align stack-params set
    ] when ] when ] if ;
