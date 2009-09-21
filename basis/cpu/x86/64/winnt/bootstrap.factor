! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
layouts vocabs parser cpu.x86.assembler
cpu.x86.assembler.operands ;
IN: bootstrap.x86

: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: arg ( -- reg ) RCX ;
: arg2 ( -- reg ) RDX ;

<< "vocab:cpu/x86/64/bootstrap.factor" parse-file parsed >>
call
