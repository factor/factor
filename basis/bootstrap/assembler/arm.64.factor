! Copyright (C) 2020 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: cpu.arm.assembler.opcodes layouts namespaces ;
IN: bootstrap.arm

8 \ cell set

: ds-reg ( -- reg ) X5 ;
: rs-reg ( -- reg ) X6 ;

! caller-saved registers X9-X15
! callee-saved registers X19-X29
: temp0 ( -- reg ) X9 ;
: temp1 ( -- reg ) X10 ;
: temp2 ( -- reg ) X11 ;
: temp3 ( -- reg ) X12 ;
