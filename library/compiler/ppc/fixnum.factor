! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler kernel math math-internals memory
namespaces words ;

: >3-vop< ( vop -- out1 in2 in1 )
    [ vop-out-1 v>operand ] keep
    [ vop-in-2 v>operand ] keep
    vop-in-1 ;

: maybe-immediate ( vop imm comp -- )
    pick vop-in-1 integer? [
        >r >r >3-vop< v>operand r> execute r> drop
    ] [
        >r >r >3-vop< v>operand swap r> drop r> execute
    ] ifte ; inline

M: %fixnum+ generate-node ( vop -- )
    \ ADDI \ ADD maybe-immediate ;

M: %fixnum- generate-node ( vop -- )
    \ SUBI \ SUBF maybe-immediate ;

M: %fixnum* generate-node ( vop -- )
    dup \ MULLI \ MULLW maybe-immediate
    vop-out-1 v>operand dup tag-bits SRAWI ;

M: %fixnum/i generate-node ( vop -- )
    dup >3-vop< v>operand DIVW
    vop-out-1 v>operand dup tag-fixnum ;

: generate-fixnum/mod ( -- )
    #! The same code is used for %fixnum/i and %fixnum/mod.
    #! mdest is vreg where to put the modulus. Note this has
    #! precise vreg requirements.
    20 17 18 DIVW  ! divide in2 by in1, store result in out1
    18 20 18 MULLW ! multiply out1 by in1, store result in in1
    19 18 17 SUBF  ! subtract in2 from in1, store result in out1.
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
    \ ANDI \ AND maybe-immediate ;

M: %fixnum-bitor generate-node ( vop -- )
    \ ORI \ OR maybe-immediate ;

M: %fixnum-bitxor generate-node ( vop -- )
    \ XORI \ XOR maybe-immediate ;

M: %fixnum-bitnot generate-node ( vop -- )
    dup vop-in-1 v>operand swap vop-out-1 v>operand
    2dup NOT untag ;

M: %fixnum<< generate-node ( vop -- )
    dup vop-in-1 20 LI
    dup vop-out-1 v>operand swap vop-in-2 v>operand 20 SLW ;

M: %fixnum>> generate-node ( vop -- )
    >3-vop< >r 2dup r> SRAWI untag ;

M: %fixnum-sgn generate-node ( vop -- )
    >3-vop< >r 2dup r> drop 31 SRAWI untag ;

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
