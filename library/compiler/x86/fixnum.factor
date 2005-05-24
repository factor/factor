! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler errors kernel math math-internals
memory namespaces words ;

: literal-overflow
    #! If the src operand is a literal.
    ! Untag the operand.
    over tag-bits SAR
    tag-bits neg shift ;

: computed-overflow
    #! If the src operand is a register.
    ! Untag both operands.
    2dup  tag-bits SAR  tag-bits SAR ;

: simple-overflow ( dest src inv word -- )
    #! If the previous arithmetic operation overflowed, then we
    #! turn the result into a bignum and leave it in EAX.
    >r >r
    <label> "end" set
    "end" get JNO
    ! There was an overflow. Recompute the original operand.
    2dup r> execute
    dup integer? [
        literal-overflow
    ] [
        computed-overflow
    ] ifte
    ! Compute a result, this time it will fit.
    dupd r> execute
    ! Create a bignum.
    PUSH
    "s48_long_to_bignum" f compile-c-call
    ! An untagged pointer to the bignum is now in EAX; tag it
    EAX bignum-tag OR
    ESP 4 ADD
    "end" get save-xt ; inline

M: %fixnum+ generate-node ( vop -- )
    dest/src 2dup ADD  \ SUB \ ADD simple-overflow ;

M: %fixnum- generate-node ( vop -- )
    dest/src 2dup SUB  \ ADD \ SUB simple-overflow ;

M: %fixnum* generate-node ( vop -- )
    drop
    ! both inputs are tagged, so one of them needs to have its
    ! tag removed.
    EAX tag-bits SAR
    ECX IMUL
    <label> "end" set
    "end" get JNO
    EDX PUSH
    EAX PUSH
    "s48_long_long_to_bignum" f compile-c-call
    ESP 8 ADD
    ! now we have to shift it by three bits to remove the second
    ! tag
    tag-bits neg PUSH
    EAX PUSH
    "s48_bignum_arithmetic_shift" f compile-c-call
    ! an untagged pointer to the bignum is now in EAX; tag it
    EAX bignum-tag OR
    ESP 8 ADD
    "end" get save-xt ;

M: %fixnum-mod generate-node ( vop -- )
    #! This has specific register requirements. Inputs are in
    #! EAX and ECX, and the result is in EDX.
    drop
    CDQ
    ECX IDIV ;

: generate-fixnum/mod
    #! The same code is used for %fixnum/i and %fixnum/mod.
    #! This has specific register requirements. Inputs are in
    #! EAX and ECX, and the result is in EDX.
    <label> "end" set
    drop
    CDQ
    ECX IDIV
    ! Make a copy since following shift is destructive
    ECX EAX MOV
    ! Tag the value, since division cancelled tags from both
    ! inputs
    EAX tag-bits SHL
    ! Did it overflow?
    "end" get JNO
    ! There was an overflow, so make ECX into a bignum. we must
    ! save EDX since its volatile.
    EDX PUSH
    ECX PUSH
    "s48_long_to_bignum" f compile-c-call
    ! An untagged pointer to the bignum is now in EAX; tag it
    EAX bignum-tag OR
    ESP cell ADD
    ! the remainder is now in EDX
    EDX POP
    "end" get save-xt ;

M: %fixnum/i generate-node generate-fixnum/mod ;

M: %fixnum/mod generate-node generate-fixnum/mod ;

M: %fixnum-bitand generate-node ( vop -- ) dest/src AND ;

M: %fixnum-bitor generate-node ( vop -- ) dest/src OR ;

M: %fixnum-bitxor generate-node ( vop -- ) dest/src XOR ;

M: %fixnum-bitnot generate-node ( vop -- )
    ! Negate the bits of the operand
    vop-out-1 v>operand dup NOT
    ! Mask off the low 3 bits to give a fixnum tag
    tag-mask XOR ;

M: %fixnum<< generate-node
    ! This has specific register requirements.
    <label> "no-overflow" set
    <label> "end" set
    ! make a copy
    ECX EAX MOV
    vop-in-1
    ! check for potential overflow
    1 over cell 8 * swap 1 - - shift ECX over ADD
    2 * 1 - ECX swap CMP
    ! is there going to be an overflow?
    "no-overflow" get JBE
    ! there is going to be an overflow, make a bignum
    EAX tag-bits SAR
    dup ( n) PUSH
    EAX PUSH
    "s48_long_to_bignum" f compile-c-call
    EDX POP
    EAX PUSH
    "s48_bignum_arithmetic_shift" f compile-c-call
    ! tag the result
    EAX bignum-tag OR
    ESP cell 2 * ADD
    "end" get JMP
    ! there is not going to be an overflow
    "no-overflow" get save-xt
    EAX swap SHL
    "end" get save-xt ;

M: %fixnum>> generate-node
    ! shift register
    dup vop-out-1 v>operand dup rot vop-in-1 SAR
    ! give it a fixnum tag
    tag-mask bitnot AND ;

M: %fixnum-sgn generate-node
    ! store 0 in EDX if EAX is >=0, otherwise store -1.
    CDQ
    ! give it a fixnum tag.
    vop-out-1 v>operand tag-bits SHL ;

: load-boolean ( dest cond -- )
    #! Compile this after a conditional jump to store f or t
    #! in dest depending on the jump being taken or not.
    <label> "true" set
    <label> "end" set
    "true" get swap execute
    dup f address MOV
    "end" get JMP
    "true" get save-xt
    t load-indirect
    "end" get save-xt ; inline

: fixnum-compare ( vop -- dest )
    dup vop-out-1 v>operand dup rot vop-in-1 v>operand CMP ;

M: %fixnum< generate-node ( vop -- )
    fixnum-compare  \ JL  load-boolean ;

M: %fixnum<= generate-node ( vop -- )
    fixnum-compare  \ JLE  load-boolean ;

M: %fixnum> generate-node ( vop -- )
    fixnum-compare  \ JG  load-boolean ;

M: %fixnum>= generate-node ( vop -- )
    fixnum-compare  \ JGE  load-boolean ;

M: %eq? generate-node ( vop -- )
    fixnum-compare  \ JE  load-boolean ;

: fixnum-branch ( vop -- label )
    dup vop-in-2 v>operand over vop-in-1 v>operand CMP
    vop-label ;

M: %jump-fixnum< generate-node ( vop -- )
    fixnum-branch JL ;

M: %jump-fixnum<= generate-node ( vop -- )
    fixnum-branch JLE ;

M: %jump-fixnum> generate-node ( vop -- )
    fixnum-branch JG ;

M: %jump-fixnum>= generate-node ( vop -- )
    fixnum-branch JGE ;

M: %jump-eq? generate-node ( vop -- )
    fixnum-branch JE ;
