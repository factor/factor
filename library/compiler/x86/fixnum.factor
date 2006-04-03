! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: arrays assembler errors kernel kernel-internals
math math-internals memory namespaces words ;

: literal-overflow ( -- dest src )
    #! Called if the src operand is a literal.
    #! Untag the dest operand.
    dest/src over tag-bits SAR tag-bits neg shift ;

: computed-overflow ( -- dest src )
    #! Called if the src operand is a register.
    #! Untag both operands.
    dest/src 2dup tag-bits SAR tag-bits SAR ;

: simple-overflow ( inverse word -- )
    #! If the previous arithmetic operation overflowed, then we
    #! turn the result into a bignum and leave it in EAX.
    <label> "end" set
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    >r >r dest/src r> execute
    0 input integer? [ literal-overflow ] [ computed-overflow ] if
    ! Compute a result, this time it will fit.
    r> execute
    ! Create a bignum.
    "s48_long_to_bignum" f 0 output-operand
    1array compile-c-call*
    ! An untagged pointer to the bignum is now in EAX; tag it
    T{ int-regs } return-reg bignum-tag OR
    "end" get save-xt ; inline

M: %fixnum+ generate-node ( vop -- )
    drop dest/src ADD  \ SUB \ ADD simple-overflow ;

M: %fixnum- generate-node ( vop -- )
    drop dest/src SUB  \ ADD \ SUB simple-overflow ;

M: %fixnum* generate-node ( vop -- )
    drop
    ! both inputs are tagged, so one of them needs to have its
    ! tag removed.
    1 input-operand tag-bits SAR
    0 input-operand IMUL
    <label> "end" set
    "end" get JNO
    "s48_fixnum_pair_to_bignum" f
    1 input-operand remainder-reg 2array compile-c-call*
    ! now we have to shift it by three bits to remove the second
    ! tag
    "s48_bignum_arithmetic_shift" f
    1 input-operand tag-bits neg 2array compile-c-call*
    ! an untagged pointer to the bignum is now in EAX; tag it
    T{ int-regs } return-reg bignum-tag OR
    "end" get save-xt ;

M: %fixnum-mod generate-node ( vop -- )
    #! This has specific register requirements. Inputs are in
    #! ECX and EAX, and the result is in EDX.
    drop
    prepare-division
    0 input-operand IDIV ;

: generate-fixnum/mod
    #! The same code is used for %fixnum/i and %fixnum/mod.
    #! This has specific register requirements. Inputs are in
    #! ECX and EAX, and the result is in EDX.
    <label> "end" set
    prepare-division
    0 input-operand IDIV
    ! Make a copy since following shift is destructive
    0 input-operand 1 input-operand MOV
    ! Tag the value, since division cancelled tags from both
    ! inputs
    1 input-operand tag-bits SHL
    ! Did it overflow?
    "end" get JNO
    ! There was an overflow, so make ECX into a bignum. we must
    ! save EDX since its volatile.
    remainder-reg PUSH
    "s48_long_to_bignum" f
    0 input-operand 1array compile-c-call*
    ! An untagged pointer to the bignum is now in EAX; tag it
    T{ int-regs } return-reg bignum-tag OR
    ! the remainder is now in EDX
    remainder-reg POP
    "end" get save-xt ;

M: %fixnum/i generate-node drop generate-fixnum/mod ;

M: %fixnum/mod generate-node drop generate-fixnum/mod ;

M: %fixnum-bitand generate-node ( vop -- ) drop dest/src AND ;

M: %fixnum-bitor generate-node ( vop -- ) drop dest/src OR ;

M: %fixnum-bitxor generate-node ( vop -- ) drop dest/src XOR ;

M: %fixnum-bitnot generate-node ( vop -- )
    drop
    ! Negate the bits of the operand
    0 output-operand NOT
    ! Mask off the low 3 bits to give a fixnum tag
    0 output-operand tag-mask XOR ;

M: %fixnum>> generate-node
    drop
    ! shift register
    0 output-operand 0 input SAR
    ! give it a fixnum tag
    0 output-operand tag-mask bitnot AND ;

M: %fixnum-sgn generate-node
    #! This has specific register requirements.
    drop
    ! store 0 in EDX if EAX is >=0, otherwise store -1.
    prepare-division
    ! give it a fixnum tag.
    0 output-operand tag-bits SHL ;

: fixnum-jump ( -- label )
    1 input-operand 0 input-operand CMP label ;

M: %jump-fixnum<  generate-node ( vop -- ) drop fixnum-jump JL ;
M: %jump-fixnum<= generate-node ( vop -- ) drop fixnum-jump JLE ;
M: %jump-fixnum>  generate-node ( vop -- ) drop fixnum-jump JG ;
M: %jump-fixnum>= generate-node ( vop -- ) drop fixnum-jump JGE ;
M: %jump-eq?      generate-node ( vop -- ) drop fixnum-jump JE ;
