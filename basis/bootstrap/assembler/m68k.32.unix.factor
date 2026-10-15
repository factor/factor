! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel parser sequences ;
IN: bootstrap.assembler.m68k
<< "resource:basis/bootstrap/assembler/m68k.32.factor" parse-file suffix! >> call
