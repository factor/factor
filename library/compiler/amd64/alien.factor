! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler kernel kernel-internals math
sequences ;

GENERIC: freg>stack ( stack reg reg-class -- )

GENERIC: stack>freg ( stack reg reg-class -- )

: stack@ RSP swap [+] ;

M: int-regs freg>stack drop >r stack@ r> MOV ;

M: int-regs stack>freg drop swap stack@ MOV ;

: MOVSS/D float-regs-size 4 = [ MOVSS ] [ MOVSD ] if ;

M: float-regs freg>stack >r >r stack@ r> r> MOVSS/D ;

M: float-regs stack>freg >r swap stack@ r> MOVSS/D ;

M: stack-params stack>freg
    drop >r R11 swap stack@ MOV r> stack@ R11 MOV ;

M: stack-params freg>stack
    >r stack-increment + cell + swap r> stack>freg ;

M: %unbox-struct generate-node ( vop -- )
    drop
    ! Load destination address
    RDI RSP MOV
    RDI 0 input ADD
    ! Load struct size
    RSI 2 input MOV
    ! Copy the struct to the stack
    "unbox_value_struct" f compile-c-call ;

M: %unbox generate-node ( vop -- )
    drop
    ! Call the unboxer
    2 input f compile-c-call
    ! Store the return value on the C stack
    0 input 1 input [ return-reg ] keep freg>stack ;

: (%move) 0 input 1 input 2 input [ fastcall-regs nth ] keep ;

M: %stack>freg generate-node ( vop -- )
    ! Move a value from the C stack into the fastcall register
    drop (%move) stack>freg ;

M: %freg>stack generate-node ( vop -- )
    ! Move a value from a fastcall register to the C stack
    drop (%move) freg>stack ;

: reset-sse RAX RAX XOR ;

M: %alien-invoke generate-node
    reset-sse
    drop 0 input 1 input load-library compile-c-call ;

: load-return-value ( reg-class -- )
    dup fastcall-regs first swap return-reg
    2dup eq? [ 2drop ] [ MOV ] if ;

M: %box generate-node ( vop -- )
    drop
    0 input [
        1 input [ fastcall-regs first ] keep stack>freg
    ] [
        1 input load-return-value
    ] if*
    2 input f compile-c-call ;

M: %alien-callback generate-node ( vop -- )
    drop
    RDI 0 input load-indirect
    "run_callback" f compile-c-call ;

: save-return 0 swap [ return-reg ] keep freg>stack ;
: load-return 0 swap [ return-reg ] keep stack>freg ;

M: %callback-value generate-node ( vop -- )
    drop
    ! Call the unboxer
    1 input f compile-c-call
    ! Save return register
    0 input save-return
    ! Restore data/callstacks
    "unnest_stacks" f compile-c-call
    ! Restore return register
    0 input load-return ;
