! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: alien arrays assembler kernel kernel-internals math
sequences ;

GENERIC: store-insn ( offset reg-class -- )

GENERIC: load-insn ( elt parameter reg-class -- )

: stack@ R10 RSP MOV  R10 swap 2array ;

M: int-regs store-insn
    drop stack@ RAX MOV ;

M: int-regs load-insn
    fastcall-regs nth swap stack@ MOV ;

: MOVSS/LPD float-regs-size 4 = [ MOVSS ] [ MOVLPD ] if ;

M: float-regs store-insn
    >r stack@ XMM0 r> MOVSS/LPD ;

M: float-regs load-insn
    [ fastcall-regs nth swap stack@ ] keep MOVSS/LPD ;

M: stack-params load-insn
    drop >r R11 swap stack@ MOV r> stack@ R11 MOV ;

M: %unbox generate-node ( vop -- )
    drop
    ! Call the unboxer
    2 input f compile-c-call
    ! Store the return value on the C stack
    0 input 1 input store-insn ;

M: %parameter generate-node ( vop -- )
    ! Move a value from the C stack into the fastcall register
    drop 0 input 1 input 2 input load-insn ;

: reset-sse RAX RAX XOR ;

M: %alien-invoke generate-node
    reset-sse
    drop 0 input 1 input load-library compile-c-call ;

: load-return-value ( reg-class -- )
    dup fastcall-regs first swap return-reg
    2dup eq? [ 2drop ] [ MOV ] if ;

M: %box generate-node ( vop -- )
    drop 0 input load-return-value 1 input f compile-c-call ;
