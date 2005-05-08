! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: assembler errors kernel math math-internals memory
namespaces words ;

: simple-overflow ( dest -- )
    #! If the previous arithmetic operation overflowed, then we
    #! turn the result into a bignum and leave it in EAX. This
    #! does not trigger a GC if memory is full -- is that bad?
    <label> "end" set
    "end" get JNO
    ! There was an overflow. Untag the fixnum and add the carry.
    ! Thanks to Dazhbog for figuring out this trick.
    dup RCR
    dup 2 SAR
    ! Create a bignum
    PUSH
    "s48_long_to_bignum" f compile-c-call
    ! An untagged pointer to the bignum is now in EAX; tag it
    EAX bignum-tag OR
    ESP 4 ADD
    "end" get save-xt ;

M: %fixnum+ generate-node ( vop -- )
    dest/src dupd ADD  simple-overflow ;

M: %fixnum- generate-node ( vop -- )
    dest/src dupd SUB  simple-overflow ;

M: %fixnum* generate-node ( vop -- )
    drop
    ! both inputs are tagged, so one of them needs to have its
    ! tag removed.
    EAX tag-bits SAR
    ECX IMUL
    <label> "end" set
    "end" get JNO
    ! make a bignum
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
    EAX 3 SHL
    ! Did it overflow?
    "end" get JNO
    ! There was an overflow, so make ECX into a bignum. we must
    ! save EDX since its volatile.
    EDX PUSH
    ECX PUSH
    "s48_long_to_bignum" f compile-c-call
    ! An untagged pointer to the bignum is now in EAX; tag it
    EAX bignum-tag OR
    ESP 4 ADD
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
    vop-dest v>operand dup NOT
    ! Mask off the low 3 bits to give a fixnum tag
    tag-mask XOR ;

: conditional ( dest cond -- )
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
    dup vop-dest v>operand dup rot vop-source v>operand CMP ;

M: %fixnum< generate-node ( vop -- )
    fixnum-compare  \ JL  conditional ;

M: %fixnum<= generate-node ( vop -- )
    fixnum-compare  \ JLE  conditional ;

M: %fixnum> generate-node ( vop -- )
    fixnum-compare  \ JG  conditional ;

M: %fixnum>= generate-node ( vop -- )
    fixnum-compare  \ JGE  conditional ;

M: %eq? generate-node ( vop -- )
    fixnum-compare  \ JE  conditional ;
! 
! \ arithmetic-type [
!     drop
!     EAX [ ESI -4 ] MOV
!     EAX BIN: 111 AND
!     EDX [ ESI ] MOV
!     EDX BIN: 111 AND
!     EAX EDX CMP
!     0 JE just-compiled >r
!     \ arithmetic-type compile-call
!     0 JMP just-compiled
!     compiled-offset r> patch
!     EAX 3 SHL
!     PUSH-DS
!     compiled-offset swap patch
! ] "generator" set-word-prop
! 
! \ arithmetic-type [ \ arithmetic-type self ] "infer" set-word-prop
