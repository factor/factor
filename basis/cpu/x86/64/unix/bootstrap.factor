! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private cpu.x86.assembler
cpu.x86.assembler.operands kernel layouts namespaces parser
sequences system vocabs ;
IN: bootstrap.x86

: stack-frame-size ( -- n ) 4 bootstrap-cells ;
: arg1 ( -- reg ) RDI ;
: arg2 ( -- reg ) RSI ;
: arg3 ( -- reg ) RDX ;

<< "vocab:cpu/x86/64/bootstrap.factor" parse-file suffix! >>
call
