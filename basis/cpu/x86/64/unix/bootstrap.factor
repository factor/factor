! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private cpu.x86.assembler
cpu.x86.assembler.operands kernel layouts namespaces parser
sequences system vocabs ;
IN: bootstrap.x86

: leaf-stack-frame-size ( -- n ) 2 bootstrap-cells ;
: signal-handler-stack-frame-size ( -- n ) 18 bootstrap-cells ;
: stack-frame-size ( -- n ) 4 bootstrap-cells ;
: nv-regs ( -- seq ) { RBX R12 R13 R14 R15 } ;
: volatile-regs ( -- seq ) { RAX RCX RDX RSI RDI R8 R9 R10 R11 } ;
: arg1 ( -- reg ) RDI ;
: arg2 ( -- reg ) RSI ;
: arg3 ( -- reg ) RDX ;
: arg4 ( -- reg ) RCX ;
: red-zone-size ( -- n ) 128 ;

<< "vocab:cpu/x86/unix/bootstrap.factor" parse-file suffix! >> call
<< "vocab:cpu/x86/64/bootstrap.factor" parse-file suffix! >> call
<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >> call
