! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler

M: %type generate-node ( vop -- )
    #! Intrinstic version of type primitive.
    drop
    <label> "header" set
    <label> "f" set
    <label> "end" set
    ! Make a copy
    0 scratch 0 output-operand MOV
    ! Get the tag
    0 output-operand tag-mask AND
    ! Compare with object tag number (3).
    0 output-operand object-tag CMP
    ! Jump if the object doesn't store type info in its header
    "header" get JE
    ! It doesn't store type info in its header
    0 output-operand tag-bits SHL
    "end" get JMP
    "header" get save-xt
    ! It does store type info in its header
    ! Is the pointer itself equal to 3? Then its F_TYPE (9).
    0 scratch object-tag CMP
    "f" get JE
    ! The pointer is not equal to 3. Load the object header.
    0 output-operand 0 scratch object-tag neg [+] MOV
    ! Mask off header tag, making a fixnum.
    0 output-operand object-tag XOR
    "end" get JMP
    "f" get save-xt
    ! The pointer is equal to 3. Load F_TYPE (9).
    0 output-operand f type tag-bits shift MOV
    "end" get save-xt ;

M: %tag generate-node ( vop -- )
    drop
    0 input-operand tag-mask AND
    0 input-operand tag-bits SHL ;

M: %untag generate-node ( vop -- )
    drop
    0 output-operand tag-mask bitnot AND ;

M: %slot generate-node ( vop -- )
    drop
    ! turn tagged fixnum slot # into an offset, multiple of 4
    0 input-operand fixnum>slot@
    ! compute slot address
    dest/src ADD
    ! load slot value
    0 output-operand dup [] MOV ;

: card-offset 1 getenv ; inline

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    drop
    0 input-operand card-bits SHR
    0 input-operand card-offset ADD rel-absolute-cell rel-cards
    0 input-operand [] card-mark OR ;

M: %set-slot generate-node ( vop -- )
    drop
    ! turn tagged fixnum slot # into an offset
    2 input-operand fixnum>slot@
    ! compute slot address
    2 input-operand 1 input-operand ADD
    ! store new slot value
    2 input-operand [] 0 input-operand MOV ;

: >register-16 ( reg -- reg )
    "register" word-prop { AX CX DX } nth ;

: scratch-16 ( n -- reg ) scratch >register-16 ;

M: %char-slot generate-node ( vop -- )
    drop
    0 input-operand 2 SHR
    0 scratch dup XOR
    dest/src ADD
    0 scratch-16 0 output-operand string-offset [+] MOV
    0 scratch tag-bits SHL
    0 output-operand 0 scratch MOV ;

M: %set-char-slot generate-node ( vop -- )
    drop
    0 input-operand tag-bits SHR
    2 input-operand 2 SHR
    2 input-operand 1 input-operand ADD
    2 input-operand string-offset [+]
    0 input-operand >register-16 MOV ;

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

M: %fixnum+fast generate-node ( vop -- ) drop dest/src ADD ;

M: %fixnum- generate-node ( vop -- )
    drop dest/src SUB  \ ADD \ SUB simple-overflow ;

M: %fixnum-fast generate-node ( vop -- ) drop dest/src SUB ;

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
