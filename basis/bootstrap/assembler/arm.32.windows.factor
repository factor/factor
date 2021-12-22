! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.arm

<< "vocab:bootstrap/assembler/arm.windows.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/arm.32.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/arm.factor" parse-file suffix! >> call
