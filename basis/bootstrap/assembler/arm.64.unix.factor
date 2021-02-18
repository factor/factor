! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler cpu.arm.assembler.opcodes kernel layouts
parser sequences ;
IN: bootstrap.arm


<< "vocab:bootstrap/assembler/arm.unix.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/arm.64.factor" parse-file suffix! >> call
<< "vocab:bootstrap/assembler/arm.factor" parse-file suffix! >> call
