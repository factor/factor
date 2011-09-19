! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system layouts
vocabs sequences cpu.x86.assembler parser
cpu.x86.assembler.operands ;
IN: bootstrap.x86

DEFER: stack-reg

: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: nv-regs ( -- seq ) { RBX RSI RDI R12 R13 R14 R15 } ;
: arg1 ( -- reg ) RCX ;
: arg2 ( -- reg ) RDX ;
: arg3 ( -- reg ) R8 ;
: arg4 ( -- reg ) R9 ;

: tib-segment ( -- ) GS ;
: tib-temp ( -- reg ) R11 ;

: jit-install-seh ( -- ) stack-reg bootstrap-cell ADD ;
: jit-update-seh ( ctx-reg -- ) drop ;

<< "vocab:cpu/x86/windows/bootstrap.factor" parse-file suffix! >> call
<< "vocab:cpu/x86/64/bootstrap.factor" parse-file suffix! >> call
<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >> call
