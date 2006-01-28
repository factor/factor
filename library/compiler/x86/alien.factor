! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces words ;

GENERIC: push-reg ( reg-class -- )

M: int-regs push-reg drop EAX PUSH ;

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
    drop 0 input dup zero? [ drop ] [ ESP swap ADD ] if ;
