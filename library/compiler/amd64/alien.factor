! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: alien arrays assembler kernel kernel-internals math
sequences ;

GENERIC: store-insn ( offset reg-class -- )

GENERIC: load-insn ( elt parameter reg-class -- )

: stack@ RCX RSP MOV  RCX swap 2array ;

M: int-regs store-insn
    drop stack@ RAX MOV ;

M: int-regs load-insn
    drop param-regs nth swap stack@ MOV ;

M: %unbox generate-node ( vop -- )
    drop
    ! Call the unboxer
    1 input f compile-c-call
    ! Store the return value on the C stack
    0 input 2 input store-insn ;

M: %parameter generate-node ( vop -- )
    ! Move a value from the C stack into the fastcall register
    drop 0 input 1 input 2 input load-insn ;

M: %box generate-node ( vop -- )
    drop
    ! Move return value of C function into input register
    param-regs first RAX MOV
    0 input f compile-c-call ;

M: %cleanup generate-node ( vop -- ) drop ;
