! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.s390x
<< "resource:basis/bootstrap/assembler/s390x.factor" parse-file suffix! >> call
