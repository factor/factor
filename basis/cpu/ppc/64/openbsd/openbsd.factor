! Copyright (C) 2026 Doug Coleman
! See https://factorcode.org/license.txt for BSD license.
USING: system kernel layouts cpu.architecture cpu.ppc cpu.ppc.elfv2 ;
IN: cpu.ppc.64.openbsd

M: ppc64 ppc64-stack-shadows? t ;
M: openbsd lr-save 2 cells ;
M: openbsd has-toc f ;
M: openbsd reserved-area-size 4 cells ;
M: openbsd allows-null-dereference f ;
M: ppc float-right-align-on-stack? cpu ppc.64? ;
