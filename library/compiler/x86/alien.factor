! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler inference kernel
kernel-internals math memory namespaces words ;

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

: %unbox-struct ( n reg-class size -- )
    2nip
    ! Increase stack size
    ESP over SUB
    ! Save destination address in EAX
    EAX ESP MOV
    "unbox_value_struct" struct-ptr/size ;

: %box-struct ( n reg-class size -- )
    2nip
    ! Compute source address in EAX
    EAX ESP MOV
    EAX 4 ADD
    "box_value_struct" struct-ptr/size ;

: %box ( n reg-class func -- )
    rot [ 4 + pick load-return-reg ] when*
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
