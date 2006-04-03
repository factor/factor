! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler inference kernel
kernel-internals lists math memory namespaces words ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: pop-return-reg ( reg-class -- )
GENERIC: load-return-reg ( stack@ reg-class -- )

: drop-return-reg ESP swap reg-size ADD ;

M: int-regs push-return-reg drop EAX PUSH ;
M: int-regs pop-return-reg drop EAX POP ;
M: int-regs load-return-reg drop EAX ESP rot [+] MOV ;

: FSTP 4 = [ FSTPS ] [ FSTPL ] if ;

M: float-regs push-return-reg
    ESP swap reg-size [ SUB  ESP [] ] keep FSTP ;

: FLD 4 = [ FLDS ] [ FLDL ] if ;

M: float-regs pop-return-reg
    ESP [] over reg-size FLD drop-return-reg ;

M: float-regs load-return-reg
    reg-size >r ESP swap [+] r> FLD ;

M: %unbox generate-node
    drop 2 input f compile-c-call  1 input push-return-reg ;

: struct-ptr/size ( func -- )
    ! Load struct size
    2 input PUSH
    ! Load destination address
    EAX PUSH
    ! Copy the struct to the stack
    f compile-c-call
    ! Clean up
    EAX POP
    ECX POP ;

M: %unbox-struct generate-node ( vop -- )
    drop
    ! Increase stack size
    ESP 2 input SUB
    ! Save destination address in EAX
    EAX ESP MOV
    "unbox_value_struct" struct-ptr/size ;

M: %box-struct generate-node ( vop -- )
    ! Compute source address in EAX
    EAX ESP MOV
    EAX 4 ADD
    drop "box_value_struct" struct-ptr/size ;

M: %box generate-node
    drop
    0 input [ 4 + 1 input load-return-reg ] when*
    1 input push-return-reg
    2 input f compile-c-call
    1 input drop-return-reg ;

M: %alien-callback generate-node ( vop -- )
    drop
    EAX 0 input load-indirect
    EAX PUSH
    "run_callback" f compile-c-call
    EAX POP ;

M: %callback-value generate-node ( vop -- )
    drop
    ! Call the unboxer
    1 input f compile-c-call
    ! Save return register
    0 input push-return-reg
    ! Restore data/callstacks
    "unnest_stacks" f compile-c-call
    ! Restore return register
    0 input pop-return-reg ;

M: %cleanup generate-node
    drop 0 input dup zero? [ drop ] [ ESP swap ADD ] if ;
