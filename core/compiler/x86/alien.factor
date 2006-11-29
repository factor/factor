! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler inference kernel
kernel-internals math memory namespaces words ;

: %unbox ( n reg-class func -- )
    f %alien-invoke push-return-reg drop ;

: struct-ptr/size ( size func -- )
    ! Load struct size
    swap PUSH
    ! Load destination address
    EAX PUSH
    ! Copy the struct to the stack
    f %alien-invoke
    ! Clean up
    EAX POP
    ECX POP ;

: %unbox-struct ( n size -- )
    nip
    ! Increase stack size
    ESP over SUB
    ! Save destination address in EAX
    EAX ESP MOV
    "unbox_value_struct" struct-ptr/size ;

: %box-struct ( n size -- )
    nip
    ! Compute source address in EAX
    EAX ESP MOV
    EAX 8 ADD
    "box_value_struct" struct-ptr/size ;

: %box ( n reg-class func -- )
    rot [ 8 + pick load-return-reg ] when*
    over push-return-reg
    f %alien-invoke
    drop-return-reg ;

: %alien-callback ( quot -- )
    0 <int-vreg> load-literal
    EAX PUSH
    "run_callback" f %alien-invoke
    EAX POP ;

: %callback-value ( reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Save return register
    dup push-return-reg
    ! Restore data/callstacks
    "unnest_stacks" f %alien-invoke
    ! Restore return register
    pop-return-reg ;

: %cleanup ( n -- ) dup zero? [ drop ] [ ESP swap ADD ] if ;
