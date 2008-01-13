! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser ;
IN: bootstrap.x86

8 \ cell set

: arg0 RDI ;
: arg1 RSI ;
: temp-reg RBX ;
: stack-reg RSP ;
: ds-reg R14 ;
: fixnum>slot@ ;

"resource:core/cpu/x86/bootstrap.factor" run-file
