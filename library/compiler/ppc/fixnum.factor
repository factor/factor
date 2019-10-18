! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler kernel math math-internals memory
namespaces words ;

: >3-imm< ( vop -- out1 in2 in1 )
    [ vop-out-1 v>operand ] keep
    [ vop-in-2 v>operand ] keep
    vop-in-1 ;

: >3-vop< ( vop -- out1 in1 in2 )
    >3-imm< v>operand swap ;

: simple-overflow ( vop inv word -- )
    >r >r
    <label> "end" set
    "end" get BNO
    dup >3-vop< 3dup r> execute
    2dup
    dup tag-bits SRAWI
    dup tag-bits SRAWI
    3 -rot r> execute
    drop
    "s48_long_to_bignum" f compile-c-call
    ! An untagged pointer to the bignum is now in r3; tag it
    3 swap vop-out-1 v>operand bignum-tag ORI
    "end" get save-xt ; inline

M: %fixnum+ generate-node ( vop -- )
    0 MTXER
    dup >3-vop< ADDO.
    \ SUBF \ ADD simple-overflow ;

M: %fixnum- generate-node ( vop -- )
    0 MTXER
    dup >3-vop< SUBFO.
    \ ADD \ SUBF simple-overflow ;

M: %fixnum* generate-node ( vop -- )
    dup >3-vop< dup dup tag-bits SRAWI
    0 MTXER
    [ >r >r drop 4 r> r> MULLWO. 3 ] 2keep
    <label> "end" set
    "end" get BNO
    MULHW
    "s48_long_long_to_bignum" f compile-c-call
    ! now we have to shift it by three bits to remove the second
    ! tag
    tag-bits neg 4 LI
    "s48_bignum_arithmetic_shift" f compile-c-call
    ! An untagged pointer to the bignum is now in r3; tag it
    3 4 bignum-tag ORI
    "end" get save-xt
    vop-out-1 v>operand 4 MR ;

M: %fixnum/i generate-node ( vop -- )
    dup >3-vop< swap DIVW
    vop-out-1 v>operand dup tag-fixnum ;

: generate-fixnum/mod ( -- )
    #! The same code is used for %fixnum/i and %fixnum/mod.
    #! mdest is vreg where to put the modulus. Note this has
    #! precise vreg requirements.
    20 17 18 DIVW  ! divide in2 by in1, store result in out1
    21 20 18 MULLW ! multiply out1 by in1, store result in in1
    19 21 17 SUBF  ! subtract in2 from in1, store result in out1.
    ;

M: %fixnum-mod generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop generate-fixnum/mod ;

M: %fixnum/mod generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop generate-fixnum/mod
    17 20 MR
    17 17 tag-fixnum ;

M: %fixnum-bitand generate-node ( vop -- )
    >3-vop< AND ;

M: %fixnum-bitor generate-node ( vop -- )
    >3-vop< OR ;

M: %fixnum-bitxor generate-node ( vop -- )
    >3-vop< XOR ;

M: %fixnum-bitnot generate-node ( vop -- )
    dest/src dupd NOT dup untag ;

M: %fixnum<< generate-node ( vop -- )
    ! This has specific register requirements.
    <label> "no-overflow" set
    <label> "end" set
    vop-in-1
    ! check for potential overflow
    dup shift-add dup 19 LOAD
    18 17 19 ADD
    0 18 rot 2 * 1 - CMPLI
    ! is there going to be an overflow?
    "no-overflow" get BGE
    ! there is going to be an overflow, make a bignum
    3 17 tag-bits SRAWI
    "s48_long_to_bignum" f compile-c-call
    dup 4 LI
    "s48_bignum_arithmetic_shift" f compile-c-call
    ! tag the result
    3 17 bignum-tag ORI
    "end" get B
    ! there is not going to be an overflow
    "no-overflow" get save-xt
    17 17 rot SLWI
    "end" get save-xt ;

M: %fixnum>> generate-node ( vop -- )
    >3-imm< pick >r SRAWI r> dup untag ;

M: %fixnum-sgn generate-node ( vop -- )
    dest/src dupd 31 SRAWI dup untag ;

: MULLW 0 0 (MULLW) ;
: MULLW. 0 1 (MULLW) ;

: compare ( vop -- )
    dup vop-in-2 v>operand swap vop-in-1 dup integer? [
        0 -rot address CMPI
    ] [
        0 swap v>operand CMP
    ] ifte ;

: load-boolean ( dest cond -- )
    #! Compile this after a conditional jump to store f or t
    #! in dest depending on the jump being taken or not.
    <label> "true" set
    <label> "end" set
    "true" get swap execute
    f address over LI
    "end" get B
    "true" get save-xt
    t load-indirect
    "end" get save-xt ; inline

: fixnum-pred ( vop word -- dest )
    >r [ compare ] keep vop-out-1 v>operand r> load-boolean ;
    inline

M: %fixnum<  generate-node ( vop -- ) \ BLT fixnum-pred ;
M: %fixnum<= generate-node ( vop -- ) \ BLE fixnum-pred ;
M: %fixnum>  generate-node ( vop -- ) \ BGT fixnum-pred ;
M: %fixnum>= generate-node ( vop -- ) \ BGE fixnum-pred ;
M: %eq?      generate-node ( vop -- ) \ BEQ fixnum-pred ;

: fixnum-jump ( vop -- label )
    [ compare ] keep vop-label ;

M: %jump-fixnum<  generate-node ( vop -- ) fixnum-jump BLT ;
M: %jump-fixnum<= generate-node ( vop -- ) fixnum-jump BLE ;
M: %jump-fixnum>  generate-node ( vop -- ) fixnum-jump BGT ;
M: %jump-fixnum>= generate-node ( vop -- ) fixnum-jump BGE ;
M: %jump-eq?      generate-node ( vop -- ) fixnum-jump BEQ ;
