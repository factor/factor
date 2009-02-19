! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler layouts vocabs parser ;
IN: bootstrap.x86

: stack-frame-size ( -- n ) 4 bootstrap-cells ;
: arg ( -- reg ) RDI ;

<< "vocab:cpu/x86/64/bootstrap.factor" parse-file parsed >>
call
