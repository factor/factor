! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser ;
IN: bootstrap.x86

8 \ cell set

: arg0 ( -- reg ) RDI ;
: arg1 ( -- reg ) RSI ;
: temp-reg ( -- reg ) RBX ;
: stack-reg ( -- reg ) RSP ;
: ds-reg ( -- reg ) R14 ;
: fixnum>slot@ ( -- ) ;
: rex-length ( -- n ) 1 ;

<< "resource:core/cpu/x86/bootstrap.factor" parse-file parsed >>
call
