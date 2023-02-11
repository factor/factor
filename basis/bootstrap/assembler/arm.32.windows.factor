! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.arm

<< "resource:basis/bootstrap/assembler/arm.windows.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/arm.32.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/arm.factor" parse-file suffix! >> call
