! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler kernel math math-internals memory
namespaces words ;

: >3-imm< ( vop -- out1 in2 in1 )
    [ 0 vop-out v>operand ] keep
    [ 1 vop-in v>operand ] keep
    0 vop-in ;

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
    3 swap 0 vop-out v>operand bignum-tag ORI
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
    #! Note that this assumes the output will be in r3.
    >3-vop< dup dup tag-bits SRAWI
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

: first-bignum ( -- n )
    1 cell 8 * tag-bits - 1 - shift ; inline

: most-positive-fixnum ( -- n )
    first-bignum 1 - >fixnum ; inline

: most-negative-fixnum ( -- n )
    first-bignum neg >fixnum ; inline

M: %fixnum/i generate-node ( vop -- )
    #! This has specific vreg requirements.
    <label> "end" set
    drop
    5 3 4 DIVW
    most-positive-fixnum 4 LOAD
    5 3 tag-fixnum
    5 0 4 CMP
    "end" get BLE
    most-negative-fixnum neg 3 LOAD
    "s48_long_to_bignum" f compile-c-call
    3 3 bignum-tag ORI
    "end" get save-xt ;

: generate-fixnum/mod ( -- )
    #! The same code is used for %fixnum/i and %fixnum/mod.
    #! mdest is vreg where to put the modulus. Note this has
    #! precise vreg requirements.
    6 3 4 DIVW  ! divide in2 by in1, store result in out1
    7 6 4 MULLW ! multiply out1 by in1, store result in in1
    5 7 3 SUBF  ! subtract in2 from in1, store result in out1.
    ;

M: %fixnum-mod generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop generate-fixnum/mod ;

M: %fixnum/mod generate-node ( vop -- )
    #! This has specific vreg requirements.
    drop generate-fixnum/mod
    3 6 MR
    3 3 tag-fixnum ;

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
    0 vop-in
    ! check for potential overflow
    dup shift-add dup 5 LOAD
    4 3 5 ADD
    2 * 1 - 5 LOAD
    5 0 4 CMPL
    ! is there going to be an overflow?
    "no-overflow" get BGE
    ! there is going to be an overflow, make a bignum
    3 3 tag-bits SRAWI
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
    >3-imm< pick >r SRAWI r> dup untag ;

M: %fixnum-sgn generate-node ( vop -- )
    dest/src dupd 31 SRAWI dup untag ;

: compare ( vop -- )
    dup 1 vop-in v>operand swap 0 vop-in dup integer? [
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
    >r [ compare ] keep 0 vop-out v>operand r> load-boolean ;
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
