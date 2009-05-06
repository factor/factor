! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser compiler.constants ;
IN: bootstrap.x86

4 \ cell set

: stack-frame-size ( -- n ) 4 bootstrap-cells ;
: shift-arg ( -- reg ) ECX ;
: div-arg ( -- reg ) EAX ;
: mod-arg ( -- reg ) EDX ;
: arg ( -- reg ) EAX ;
: temp0 ( -- reg ) EAX ;
: temp1 ( -- reg ) EDX ;
: temp2 ( -- reg ) ECX ;
: temp3 ( -- reg ) EBX ;
: stack-reg ( -- reg ) ESP ;
: ds-reg ( -- reg ) ESI ;
: rs-reg ( -- reg ) EDI ;
: fixnum>slot@ ( -- ) temp0 1 SAR ;
: rex-length ( -- n ) 0 ;

[
    ! load stack_chain
    temp0 0 [] MOV rc-absolute-cell rt-stack-chain jit-rel
    ! save stack pointer
    temp0 [] stack-reg MOV
] jit-save-stack jit-define

[
    0 JMP rc-relative rt-primitive jit-rel
] jit-primitive jit-define

<< "vocab:cpu/x86/bootstrap.factor" parse-file parsed >>
call
