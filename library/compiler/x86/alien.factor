! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node
    #! call a C function.
    dup 0 vop-in swap 1 vop-in load-library compile-c-call ;

M: %parameter generate-node
    #! x86 does not pass parameters in registers
    drop ;

GENERIC: reg-size ( reg-class -- n )
GENERIC: push-reg ( reg-class -- )

M: int-regs reg-size drop cell ;
M: int-regs push-reg drop EAX PUSH ;

M: float-regs reg-size float-regs-size ;
M: float-regs push-reg
    ESP swap reg-size [ SUB  [ ESP ] ] keep
    4 = [ FSTPS ] [ FSTPL ] if ;

M: %unbox generate-node
    dup 1 vop-in f compile-c-call  2 vop-in push-reg ;

M: %box generate-node
    dup 1 vop-in push-reg
    dup 0 vop-in f compile-c-call
    1 vop-in ESP swap reg-size ADD ;

M: %cleanup generate-node
    0 vop-in dup 0 = [ drop ] [ ESP swap ADD ] if ;
