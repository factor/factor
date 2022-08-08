! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes kernel layouts
parser sequences ;
IN: bootstrap.assembler.arm


<< "resource:basis/bootstrap/assembler/arm.unix.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/arm.64.factor" parse-file suffix! >> call
<< "resource:basis/bootstrap/assembler/arm.factor" parse-file suffix! >> call
