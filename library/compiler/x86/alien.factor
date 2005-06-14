! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node
    #! call a C function.
    dup vop-in-1 swap vop-in-2 load-library compile-c-call ;

M: %parameters generate-node
    #! x86 does not pass parameters in registers
    drop ;

M: %parameter generate-node
    #! x86 does not pass parameters in registers
    drop ;

GENERIC: reg-size ( reg-class -- n )
GENERIC: push-reg ( reg-class -- )

M: int-regs reg-size drop cell ;
M: int-regs push-reg drop EAX PUSH ;

M: float-regs reg-size drop 4 ;
M: float-regs push-reg
    ESP swap reg-size SUB  [ ESP ] FSTPS ;

M: double-regs reg-size drop 8 ;
M: double-regs push-reg
    ESP swap reg-size SUB  [ ESP ] FSTPL ;

M: %unbox generate-node
    dup vop-in-2 f compile-c-call  vop-in-3 push-reg ;

M: %box generate-node
    dup vop-in-2 push-reg
    dup vop-in-1 f compile-c-call
    vop-in-2 ESP swap reg-size ADD ;

M: %cleanup generate-node
    vop-in-1 dup 0 = [ drop ] [ ESP swap ADD ] ifte ;
