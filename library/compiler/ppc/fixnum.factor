! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler kernel kernel-internals math
math-internals memory namespaces words ;

: >3-vop< ( -- out1 in1 in2 )
    0 output-operand 0 input-operand 1 input-operand ;

: simple-overflow ( inv word -- )
    >r >r
    <label> "end" set
    "end" get BNO
    >3-vop< r> execute
    0 input-operand dup untag-fixnum
    1 input-operand dup untag-fixnum
    >3-vop< r> execute
    "s48_long_to_bignum" f compile-c-call
    ! An untagged pointer to the bignum is now in r3; tag it
    0 output-operand dup bignum-tag ORI
    "end" get save-xt ; inline

M: %fixnum+ generate-node ( vop -- )
    drop 0 MTXER >3-vop< ADDO. \ SUBF \ ADD simple-overflow ;

M: %fixnum- generate-node ( vop -- )
    drop 0 MTXER >3-vop< SUBFO. \ ADD \ SUBF simple-overflow ;

M: %fixnum* generate-node ( vop -- )
    #! Note that this assumes the output will be in r3.
    drop
    <label> "end" set
    1 input-operand dup untag-fixnum
    0 MTXER
    0 scratch 0 input-operand 1 input-operand MULLWO.
    "end" get BNO
    1 scratch 0 input-operand 1 input-operand MULHW
    4 1 scratch MR
    3 0 scratch MR
    "s48_fixnum_pair_to_bignum" f compile-c-call
    ! now we have to shift it by three bits to remove the second
    ! tag
    tag-bits neg 4 LI
    "s48_bignum_arithmetic_shift" f compile-c-call
    ! An untagged pointer to the bignum is now in r3; tag it
    0 output-operand 0 scratch bignum-tag ORI
    "end" get save-xt
    0 output-operand 0 scratch MR ;

: generate-fixnum/i
    #! This VOP is funny. If there is an overflow, it falls
    #! through to the end, and the result is in 0 output-operand.
    #! Otherwise it jumps to the "no-overflow" label and the
    #! result is in 0 scratch.
    0 scratch 1 input-operand 0 input-operand DIVW
    ! if the result is greater than the most positive fixnum,
    ! which can only ever happen if we do
    ! most-negative-fixnum -1 /i, then the result is a bignum.
    <label> "end" set
    <label> "no-overflow" set
    most-positive-fixnum 1 scratch LOAD
    0 scratch 0 1 scratch CMP
    "no-overflow" get BLE
    most-negative-fixnum neg 3 LOAD
    "s48_long_to_bignum" f compile-c-call
    3 dup bignum-tag ORI ;

M: %fixnum/i generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop
    generate-fixnum/i
    "end" get B
    "no-overflow" get save-xt
    0 scratch 0 output-operand tag-fixnum
    "end" get save-xt ;

: generate-fixnum-mod
    #! PowerPC doesn't have a MOD instruction; so we compute
    #! x-(x/y)*y. Puts the result in 1 scratch.
    1 scratch 0 scratch 0 input-operand MULLW
    1 scratch 1 scratch 1 input-operand SUBF ;

M: %fixnum-mod generate-node ( vop -- )
    drop
    ! divide in2 by in1, store result in out1
    0 scratch 1 input-operand 0 input-operand DIVW
    generate-fixnum-mod
    0 output-operand 1 scratch MR ;

M: %fixnum/mod generate-node ( vop -- )
    #! This has specific vreg requirements. Note: if there's an
    #! overflow, (most-negative-fixnum 1 /mod) the modulus is
    #! always zero.
    drop
    generate-fixnum/i
    0 0 output-operand LI
    "end" get B
    "no-overflow" get save-xt
    generate-fixnum-mod
    0 scratch 1 output-operand tag-fixnum
    0 output-operand 1 scratch MR
    "end" get save-xt ;

M: %fixnum-bitand generate-node ( vop -- ) drop >3-vop< AND ;

M: %fixnum-bitor generate-node ( vop -- ) drop >3-vop< OR ;

M: %fixnum-bitxor generate-node ( vop -- ) drop >3-vop< XOR ;

M: %fixnum-bitnot generate-node ( vop -- )
    drop dest/src NOT
    0 output-operand dup untag ;

M: %fixnum>> generate-node ( vop -- )
    drop
    1 input-operand 0 output-operand 0 input SRAWI
    0 output-operand dup untag ;

M: %fixnum-sgn generate-node ( vop -- )
    drop dest/src cell-bits 1- SRAWI 0 output-operand dup untag ;

: fixnum-jump ( -- label )
    1 input-operand 0 0 input-operand CMP label ;

M: %jump-fixnum<  generate-node ( vop -- ) drop fixnum-jump BLT ;
M: %jump-fixnum<= generate-node ( vop -- ) drop fixnum-jump BLE ;
M: %jump-fixnum>  generate-node ( vop -- ) drop fixnum-jump BGT ;
M: %jump-fixnum>= generate-node ( vop -- ) drop fixnum-jump BGE ;
M: %jump-eq?      generate-node ( vop -- ) drop fixnum-jump BEQ ;
