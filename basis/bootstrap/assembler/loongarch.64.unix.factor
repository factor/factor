! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.loongarch
<< "resource:basis/bootstrap/assembler/loongarch.64.factor" parse-file suffix! >> call
