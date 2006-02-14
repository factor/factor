! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler kernel math sequences ;

GENERIC: freg>stack ( stack reg reg-class -- )

GENERIC: stack>freg ( stack reg reg-class -- )

M: int-regs freg>stack drop 1 rot stack@ STW ;

M: int-regs stack>freg drop 1 rot stack@ LWZ ;

: STF float-regs-size 4 = [ STFS ] [ STFD ] if ;

M: float-regs freg>stack >r 1 rot stack@ r> STF ;

: LF float-regs-size 4 = [ LFS ] [ LFD ] if ;

M: float-regs stack>freg >r 1 rot stack@ r> LF ;

M: stack-params stack>freg
    drop >r 0 1 rot stack@ LWZ 0 1 r> stack@ STW ;

M: %unbox generate-node ( vop -- )
    drop
    ! Call the unboxer
    2 input f compile-c-call
    ! Store the return value on the C stack
    0 input 1 input [ return-reg ] keep freg>stack ;

M: %unbox-struct generate-node ( vop -- )
    drop
    ! Load destination address
    3 1 0 input stack@ ADDI
    ! Load struct size
    2 input 4 LI
    ! Copy the struct to the stack
    "unbox_value_struct" f compile-c-call ;

: (%move) 0 input 1 input 2 input [ fastcall-regs nth ] keep ;

M: %stack>freg generate-node ( vop -- )
    ! Move a value from the C stack into the fastcall register
    drop (%move) stack>freg ;

M: %freg>stack generate-node ( vop -- )
    ! Move a value from a fastcall register to the C stack
    drop (%move) freg>stack ;

M: %box generate-node ( vop -- )
    drop
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    0 input [
        1 input [ fastcall-regs first ] keep stack>freg
    ] when*
    2 input f compile-c-call ;

M: %cleanup generate-node ( vop -- ) drop ;

M: %nullary-callback generate-node ( vop -- )
    drop
    3 0 input load-indirect
    "run_nullary_callback" f compile-c-call ;
