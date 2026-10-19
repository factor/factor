! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.alpha
<< "resource:basis/bootstrap/assembler/alpha.64.factor" parse-file suffix! >> call
