! Copyright (C) 2020 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private cpu.arm.64.assembler kernel
kernel.private layouts locals.backend math.private namespaces
slots.private strings.private ;
IN: bootstrap.assembler.arm

big-endian off

! [ "bootstrap.assembler.arm" forget-vocab ] with-compilation-unit
