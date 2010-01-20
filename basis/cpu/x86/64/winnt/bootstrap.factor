! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system layouts
vocabs sequences cpu.x86.assembler parser
cpu.x86.assembler.operands ;
IN: bootstrap.x86

: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: nv-regs ( -- seq ) { RBX RSI RDI R12 R13 R14 R15 } ;
: arg1 ( -- reg ) RCX ;
: arg2 ( -- reg ) RDX ;
: arg3 ( -- reg ) R8 ;
: arg4 ( -- reg ) R9 ;

<< "vocab:cpu/x86/64/bootstrap.factor" parse-file suffix! >>
call
