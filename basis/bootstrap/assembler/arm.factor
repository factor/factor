! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private cpu.arm.assembler kernel
kernel.private layouts locals.backend math.private namespaces
slots.private strings.private ;
IN: bootstrap.arm

big-endian off

! [ "bootstrap.arm" forget-vocab ] with-compilation-unit