! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler kernel kernel-internals math sequences ;

GENERIC: freg>stack ( stack reg reg-class -- )

GENERIC: stack>freg ( stack reg reg-class -- )

M: int-regs freg>stack drop 1 rot stack@ STW ;

M: int-regs stack>freg drop 1 rot stack@ LWZ ;

: STF float-regs-size 4 = [ STFS ] [ STFD ] if ;

M: float-regs freg>stack >r 1 rot stack@ r> STF ;

: LF float-regs-size 4 = [ LFS ] [ LFD ] if ;

M: float-regs stack>freg >r 1 rot stack@ r> LF ;

M: stack-params stack>freg
    drop 2dup = [
        2drop
    ] [
        >r 0 1 rot stack@ LWZ 0 1 r> stack@ STW
    ] if ;

M: stack-params freg>stack
   >r stack-increment + swap r> stack>freg ;

M: %unbox generate-node ( vop -- )
    drop
    ! Call the unboxer
    2 input f compile-c-call
    ! Store the return value on the C stack
    0 input 1 input [ return-reg ] keep freg>stack ;

: struct-ptr/size ( func -- )
    ! Load destination address
    3 1 0 input stack@ ADDI
    ! Load struct size
    2 input 4 LI
    f compile-c-call ;

M: %unbox-struct generate-node ( vop -- )
    drop "unbox_value_struct" struct-ptr/size ;

M: %box-struct generate-node ( vop -- )
    drop "box_value_struct" struct-ptr/size ;

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

M: %alien-callback generate-node ( vop -- )
    drop
    3 0 input load-indirect
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
