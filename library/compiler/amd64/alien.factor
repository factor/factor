! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler kernel kernel-internals math
sequences ;

M: stack-params %stack>freg
    drop >r R11 swap stack@ MOV r> stack@ R11 MOV ;

M: stack-params %freg>stack
    >r stack-increment + cell + swap r> %stack>freg ;

: struct-ptr/size ( n size func -- )
    ! Load destination address
    >r RDI RSP MOV
    RDI rot ADD
    ! Load struct size
    RSI swap MOV
    ! Copy the struct to the stack
    r> f compile-c-call ;

: %unbox-struct ( n size -- )
    "unbox_value_struct" struct-ptr/size ;

: %unbox ( n reg-class func -- )
    ! Call the unboxer
    f compile-c-call
    ! Store the return value on the C stack
    [ return-reg ] keep %freg>stack ;

: %box-struct ( n size -- )
    "box_value_struct" struct-ptr/size ;

: load-return-value ( reg-class -- )
    dup fastcall-regs first swap return-reg
    2dup eq? [ 2drop ] [ MOV ] if ;

: %box ( n reg-class func -- )
    rot [
        rot [ fastcall-regs first ] keep %stack>freg
    ] [
        swap load-return-value
    ] if*
    f compile-c-call ;

: reset-sse RAX RAX XOR ;

: %alien-invoke ( symbol dll -- )
    reset-sse compile-c-call ;

: %alien-indirect ( -- )
    "unbox_alien" f %alien-invoke  RAX CALL ;

: %alien-callback ( quot -- )
    RDI load-indirect "run_callback" f compile-c-call ;

: save-return 0 swap [ return-reg ] keep %freg>stack ;
: load-return 0 swap [ return-reg ] keep %stack>freg ;

: %callback-value ( reg-class func -- )
    ! Call the unboxer
    f compile-c-call
    ! Save return register
    dup save-return
    ! Restore data/callstacks
    "unnest_stacks" f compile-c-call
    ! Restore return register
    load-return ;

: %cleanup ( n -- ) drop ;
