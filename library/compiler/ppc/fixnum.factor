! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler kernel kernel-internals math
math-internals memory namespaces words ;

: >3-imm< ( -- out1 in2 in1 )
    0 output-operand 1 input-operand 0 input ;

: >3-vop< ( -- out1 in1 in2 )
    >3-imm< v>operand swap ;

: simple-overflow ( inv word -- )
    >r >r
    <label> "end" set
    "end" get BNO
    >3-vop< 3dup r> execute
    2dup
    dup untag-fixnum
    dup untag-fixnum
    3 -rot r> execute
    drop
    "s48_long_to_bignum" f compile-c-call
    ! An untagged pointer to the bignum is now in r3; tag it
    3 0 output-operand bignum-tag ORI
    "end" get save-xt ; inline

M: %fixnum+ generate-node ( vop -- )
    drop 0 MTXER >3-vop< ADDO. \ SUBF \ ADD simple-overflow ;

M: %fixnum- generate-node ( vop -- )
    drop 0 MTXER >3-vop< SUBFO. \ ADD \ SUBF simple-overflow ;

M: %fixnum* generate-node ( vop -- )
    #! Note that this assumes the output will be in r3.
    drop >3-vop< dup dup untag-fixnum
    0 MTXER
    [ >r >r drop 6 r> r> MULLWO. 3 ] 2keep
    <label> "end" set
    "end" get BNO
    MULHW
    4 6 MR
    "s48_long_long_to_bignum" f compile-c-call
    ! now we have to shift it by three bits to remove the second
    ! tag
    tag-bits neg 4 LI
    "s48_bignum_arithmetic_shift" f compile-c-call
    ! An untagged pointer to the bignum is now in r3; tag it
    3 6 bignum-tag ORI
    "end" get save-xt
    3 6 MR ;

: generate-fixnum/i
    6 3 4 DIVW  ! divide in2 by in1, store result in out1
    ! if the result is greater than the most positive fixnum,
    ! which can only ever happen if we do
    ! most-negative-fixnum -1 /i, then the result is a bignum.
    <label> "end" set
    <label> "no-overflow" set
    most-positive-fixnum 7 LOAD
    6 0 7 CMP
    "no-overflow" get BLE
    most-negative-fixnum neg 3 LOAD
    "s48_long_to_bignum" f compile-c-call
    3 3 bignum-tag ORI ;

M: %fixnum/i generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop
    generate-fixnum/i
    "end" get B
    "no-overflow" get save-xt
    6 3 tag-fixnum
    "end" get save-xt ;

: generate-fixnum-mod
    7 6 4 MULLW ! multiply out1 by in1, store result in in1
    5 7 3 SUBF  ! subtract in2 from in1, store result in out1.
    ;

M: %fixnum-mod generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop
    6 3 4 DIVW  ! divide in2 by in1, store result in out1
    generate-fixnum-mod ;

M: %fixnum/mod generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop
    generate-fixnum/i
    0 5 LI
    "end" get B
    "no-overflow" get save-xt
    generate-fixnum-mod
    6 3 tag-fixnum
    "end" get save-xt ;

M: %fixnum-bitand generate-node ( vop -- ) drop >3-vop< AND ;

M: %fixnum-bitor generate-node ( vop -- ) drop >3-vop< OR ;

M: %fixnum-bitxor generate-node ( vop -- ) drop >3-vop< XOR ;

M: %fixnum-bitnot generate-node ( vop -- )
    drop dest/src dupd NOT dup untag ;

M: %fixnum<< generate-node ( vop -- )
    ! This has specific register requirements.
    drop
    <label> "no-overflow" set
    <label> "end" set
    ! check for potential overflow
    0 input dup shift-add dup 5 LOAD
    4 3 5 ADD
    2 * 1- 5 LOAD
    5 0 4 CMPL
    ! is there going to be an overflow?
    "no-overflow" get BGE
    ! there is going to be an overflow, make a bignum
    3 3 untag-fixnum
    "s48_long_to_bignum" f compile-c-call
    dup 4 LI
    "s48_bignum_arithmetic_shift" f compile-c-call
    ! tag the result
    3 3 bignum-tag ORI
    "end" get B
    ! there is not going to be an overflow
    "no-overflow" get save-xt
    3 3 rot SLWI.
    "end" get save-xt ;

M: %fixnum>> generate-node ( vop -- )
    drop >3-imm< pick >r SRAWI r> dup untag ;

M: %fixnum-sgn generate-node ( vop -- )
    drop dest/src 31 SRAWI 0 output-operand dup untag ;

: fixnum-jump ( -- label )
    1 input-operand 0 0 input-operand CMP label ;

M: %jump-fixnum<  generate-node ( vop -- ) drop fixnum-jump BLT ;
M: %jump-fixnum<= generate-node ( vop -- ) drop fixnum-jump BLE ;
M: %jump-fixnum>  generate-node ( vop -- ) drop fixnum-jump BGT ;
M: %jump-fixnum>= generate-node ( vop -- ) drop fixnum-jump BGE ;
M: %jump-eq?      generate-node ( vop -- ) drop fixnum-jump BEQ ;
