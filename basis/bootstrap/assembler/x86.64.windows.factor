! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.x86.assembler cpu.x86.assembler.operands kernel
layouts parser sequences ;
IN: bootstrap.x86

DEFER: stack-reg

: signal-handler-stack-frame-size ( -- n ) 24 bootstrap-cells ;
: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: nv-regs ( -- seq ) { RBX RSI RDI R12 R13 R14 R15 } ;
: volatile-regs ( -- seq ) { RAX RCX RDX R8 R9 R10 R11 } ;
: arg1 ( -- reg ) RCX ;
: arg2 ( -- reg ) RDX ;
: arg3 ( -- reg ) R8 ;
: arg4 ( -- reg ) R9 ;

: tib-segment ( -- ) GS ;
: tib-temp ( -- reg ) R11 ;

: jit-install-seh ( -- ) stack-reg bootstrap-cell ADD ;
: jit-update-seh ( ctx-reg -- ) drop ;

: red-zone-size ( -- n ) 0 ;

<< "vocab:bootstrap/assembler/x86.windows.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/x86.64.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/x86.factor" parse-file suffix! >> call
