! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.x86

<< "vocab:bootstrap/assembler/x86.unix.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/x86.32.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/x86.factor" parse-file suffix! >> call
