! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.riscv
<< "resource:basis/bootstrap/assembler/riscv.32.factor" parse-file suffix! >> call
