! Copyright (C) 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser ;
IN: bootstrap.x86

4 \ cell set

: arg0 ( -- reg ) EAX ;
: arg1 ( -- reg ) EDX ;
: temp-reg ( -- reg ) EBX ;
: stack-reg ( -- reg ) ESP ;
: ds-reg ( -- reg ) ESI ;
: rs-reg ( -- reg ) EDI ;
: fixnum>slot@ ( -- ) arg0 1 SAR ;
: rex-length ( -- n ) 0 ;

<< "resource:core/cpu/x86/bootstrap.factor" parse-file parsed >>
call
