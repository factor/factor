! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: kernel kernel-internals math ;

! OS X uses a different ABI. The stack must be 16-byte aligned.

: align-sub ( n -- )
    cells dup 16 align swap - ESP swap SUB ;

: align-add ( n -- )
    cells 16 align ESP swap ADD ;

: with-aligned-stack ( n quot -- )
    swap dup align-sub slip align-add ; inline

: struct-ptr/size ( n size func -- )
    EAX ESP MOV
    >r >r EAX swap ADD r> r>
    2 [
        ! Push destination address
        EAX PUSH
        ! Push struct size
        >r PUSH r>
        ! Copy the struct to the stack
        f compile-c-call
    ] with-aligned-stack ;

: %unbox-struct ( n size -- )
    "unbox_value_struct" struct-ptr/size ;

: %unbox ( n reg-class func -- )
    ! Call the unboxer
    f compile-c-call
    ! Store the return value on the C stack
    [ return-reg ] keep %freg>stack ;

: %box-struct ( n size -- )
    "box_value_struct" struct-ptr/size ;

: %box ( n reg-class func -- )
    1 [
        >r over [
            drop 12 + ESP swap [+] PUSH
        ] [
            push-return-reg drop
        ] if r> f compile-c-call
    ] with-aligned-stack ;

: %alien-callback ( quot -- )
    1 [
        EAX load-indirect
        EAX PUSH
        "run_callback" f compile-c-call
    ] with-aligned-stack ;

: %callback-value ( reg-class func -- )
    f compile-c-call ! Call the unboxer
    ESP 12 ADD
    ! Save return register
    dup push-return-reg
    ! Restore data/call/retain stacks
    "unnest_stacks" f compile-c-call
    ! Restore return register
    pop-return-reg
    ESP 12 SUB ;

: %cleanup ( n -- ) drop ;
