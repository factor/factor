! Copyright (C) 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.x86

<< "vocab:cpu/x86/unix/bootstrap.factor" parse-file suffix! >> call
<< "vocab:cpu/x86/32/bootstrap.factor" parse-file suffix! >> call
<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >> call
