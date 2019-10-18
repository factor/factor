! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser ;
IN: bootstrap.x86

4 \ cell set

: arg0 EAX ;
: arg1 EDX ;
: stack-reg ESP ;
: ds-reg ESI ;
: scan-reg EBX ;
: xt-reg ECX ;
: fixnum>slot@ arg0 1 SAR ;

"resource:core/cpu/x86/bootstrap.factor" run-file
