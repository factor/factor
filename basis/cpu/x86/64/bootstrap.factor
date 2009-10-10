! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
layouts vocabs parser compiler.constants math
cpu.x86.assembler cpu.x86.assembler.operands ;
IN: bootstrap.x86

8 \ cell set

: shift-arg ( -- reg ) RCX ;
: div-arg ( -- reg ) RAX ;
: mod-arg ( -- reg ) RDX ;
: temp0 ( -- reg ) RDI ;
: temp1 ( -- reg ) RSI ;
: temp2 ( -- reg ) RDX ;
: temp3 ( -- reg ) RBX ;
: stack-reg ( -- reg ) RSP ;
: ds-reg ( -- reg ) R14 ;
: rs-reg ( -- reg ) R15 ;
: fixnum>slot@ ( -- ) ;
: rex-length ( -- n ) 1 ;

[
    ! load stack_chain
    temp0 0 MOV rc-absolute-cell rt-stack-chain jit-rel
    temp0 temp0 [] MOV
    ! save stack pointer
    temp0 [] stack-reg MOV
    ! load XT
    temp1 0 MOV rc-absolute-cell rt-primitive jit-rel
    ! load vm ptr
    arg1 0 MOV rc-absolute-cell rt-vm jit-rel
    ! go
    temp1 JMP
] jit-primitive jit-define

<< "vocab:cpu/x86/bootstrap.factor" parse-file parsed >>
call
