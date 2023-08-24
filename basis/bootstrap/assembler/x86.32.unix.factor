! Copyright (C) 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.x86

<< "resource:basis/bootstrap/assembler/x86.unix.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/x86.32.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/x86.factor" parse-file suffix! >> call
