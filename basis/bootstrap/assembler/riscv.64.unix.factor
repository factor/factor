! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.riscv
<< "resource:basis/bootstrap/assembler/riscv.64.factor" parse-file suffix! >> call
