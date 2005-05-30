! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node
    #! call a C function.
    vop-in-1 uncons load-library compile-c-call ;

M: %alien-global generate-node
    vop-in-1 uncons load-library
    2dup dlsym EAX swap unit MOV 0 0 rel-dlsym ;

M: %parameters generate-node
    #! x86 does not pass parameters in registers
    drop ;

M: %parameter generate-node
    #! x86 does not pass parameters in registers
    drop ;

: UNBOX ( vop -- )
    #! An unboxer function takes a value from the data stack and
    #! converts it into a C value.
    vop-in-1 cdr f compile-c-call ;

M: %unbox generate-node
    #! C functions return integers in EAX.
    UNBOX
    #! Push integer on C stack.
    EAX PUSH ;

M: %unbox-float generate-node
    #! C functions return floats on the FP stack.
    UNBOX
    #! Push float on C stack.
    ESP 4 SUB
    [ ESP ] FSTPS ;

M: %unbox-double generate-node
    #! C functions return doubles on the FP stack.
    UNBOX
    #! Push double on C stack.
    ESP 8 SUB
    [ ESP ] FSTPL ;

: BOX ( vop -- )
    #! A boxer function takes a C value as a parameter and
    #! converts into a Factor value, and pushes it on the data
    #! stack.
    vop-in-1 f compile-c-call ;

M: %box generate-node
    #! C functions return integers in EAX.
    EAX PUSH
    #! Push integer on data stack.
    BOX
    ESP 4 ADD ;

M: %box-float generate-node
    #! C functions return floats on the FP stack.
    ESP 4 SUB
    [ ESP ] FSTPS
    #! Push float on data stack.
    BOX
    ESP 4 ADD ;

M: %box-double generate-node
    #! C functions return doubles on the FP stack.
    ESP 8 SUB
    [ ESP ] FSTPL
    #! Push double on data stack.
    BOX
    ESP 8 ADD ;

M: %cleanup generate-node
    vop-in-1 dup 0 = [ drop ] [ ESP swap ADD ] ifte ;
