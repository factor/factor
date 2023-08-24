! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.x86.assembler.operands kernel layouts parser
sequences ;
IN: bootstrap.assembler.x86

: stack-frame-size ( -- n ) 4 bootstrap-cells ;
: nv-regs ( -- seq ) { RBX R12 R13 R14 R15 } ;
: volatile-regs ( -- seq ) { RAX RCX RDX RSI RDI R8 R9 R10 R11 } ;

! The first four parameter registers according to the Unix 64bit
! calling convention.
: arg1 ( -- reg ) RDI ;
: arg2 ( -- reg ) RSI ;
: arg3 ( -- reg ) RDX ;
: arg4 ( -- reg ) RCX ;
: red-zone-size ( -- n ) 128 ;

<< "resource:basis/bootstrap/assembler/x86.unix.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/x86.64.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/x86.factor" parse-file suffix! >> call
