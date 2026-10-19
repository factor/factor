! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.vax
<< "resource:basis/bootstrap/assembler/vax.32.factor" parse-file suffix! >> call
