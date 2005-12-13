! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node
    #! call a C function.
    drop 0 input 1 input load-library compile-c-call ;

M: %parameter generate-node
    #! x86 does not pass parameters in registers
    drop ;

GENERIC: reg-size ( reg-class -- n )
GENERIC: push-reg ( reg-class -- )

M: int-regs reg-size drop cell get ;
M: int-regs push-reg drop EAX PUSH ;

M: float-regs reg-size float-regs-size ;
M: float-regs push-reg
    ESP swap reg-size [ SUB  { ESP } ] keep
    4 = [ FSTPS ] [ FSTPL ] if ;

M: %unbox generate-node
    drop 1 input f compile-c-call  2 input push-reg ;

M: %box generate-node
    drop
    1 input push-reg
    0 input f compile-c-call
    ESP 1 input reg-size ADD ;

M: %cleanup generate-node
    drop 0 input dup 0 = [ drop ] [ ESP swap ADD ] if ;
