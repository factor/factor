! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler kernel math memory namespaces words ;

: maybe-immediate ( vop imm comp -- )
    pick vop-in-1 integer? [
        >r >r dest/src dupd r> execute r> drop
    ] [
        >r >r dest/src over r> drop r> execute
    ] ifte ; inline

M: %fixnum+ generate-node ( vop -- )
    \ ADDI \ ADD maybe-immediate ;

M: %fixnum- generate-node ( vop -- )
    \ SUBI \ SUBF maybe-immediate ;

M: %fixnum-bitand generate-node ( vop -- )
    \ ANDI \ AND maybe-immediate ;

M: %fixnum-bitor generate-node ( vop -- )
    \ ORI \ OR maybe-immediate ;

M: %fixnum-bitxor generate-node ( vop -- )
    \ XORI \ XOR maybe-immediate ;

M: %fixnum-bitnot generate-node ( vop -- )
    dup vop-in-1 swap vop-out-1 NOT ;

M: %fixnum<< generate-node ( vop -- )
    dup vop-in-1 20 LI
    dup vop-out-1 v>operand swap vop-in-2 v>operand 20 SLW ;

M: %fixnum>> generate-node ( vop -- )
    dup vop-out-1 v>operand over vop-in-2 v>operand
    rot vop-in-1 >r 2dup r> SRAWI untag ;

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

: fixnum-compare ( vop -- dest )
    dup vop-out-1 v>operand
    dup rot vop-in-1 v>operand
    0 swap CMP ;

M: %fixnum< generate-node ( vop -- )
    fixnum-compare  \ BLT load-boolean ;

M: %fixnum<= generate-node ( vop -- )
    fixnum-compare  \ BLE load-boolean ;

M: %fixnum> generate-node ( vop -- )
    fixnum-compare  \ BGT load-boolean ;

M: %fixnum>= generate-node ( vop -- )
    fixnum-compare  \ BGE load-boolean ;

M: %eq? generate-node ( vop -- )
    fixnum-compare  \ BEQ load-boolean ;
