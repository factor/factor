! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler kernel math ;

GENERIC: store-insn ( offset reg-class -- )

GENERIC: load-insn ( elt parameter reg-class -- )

M: int-regs store-insn drop >r 3 1 r> stack@ STW ;

M: int-regs load-insn drop 3 + 1 rot stack@ LWZ ;

M: float-regs store-insn
    >r >r 1 1 r> stack@ r>
    float-regs-size 4 = [ STFS ] [ STFD ] if ;

M: float-regs load-insn
    >r 1+ 1 rot stack@ r> 
    float-regs-size 4 = [ LFS ] [ LFD ] if ;

M: stack-params load-insn
    drop >r 0 1 rot stack@ LWZ 0 1 r> stack@ STW ;

M: %unbox generate-node ( vop -- )
    drop
    ! Call the unboxer
    2 input f compile-c-call
    ! Store the return value on the C stack
    0 input 1 input store-insn ;

M: %unbox-struct generate-node ( vop -- )
    drop
    ! Load destination address
    3 1 0 input stack@ ADDI
    ! Load struct size
    2 input 4 LI
    ! Copy the struct to the stack
    "unbox_value_struct" f compile-c-call ;

M: %parameter generate-node ( vop -- )
    ! Move a value from the C stack into the fastcall register
    drop 0 input 1 input 2 input load-insn ;

M: %box generate-node ( vop -- ) drop 1 input f compile-c-call ;

M: %cleanup generate-node ( vop -- ) drop ;

M: %nullary-callback generate-node ( vop -- )
    drop
    3 0 input load-indirect
    "run_nullary_callback" f compile-c-call ;
