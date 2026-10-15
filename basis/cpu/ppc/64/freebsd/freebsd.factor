! Copyright (C) 2026 Doug Coleman
! See https://factorcode.org/license.txt for BSD license.
USING: system kernel layouts cpu.architecture cpu.ppc cpu.ppc.elfv2 ;
IN: cpu.ppc.64.freebsd

M: ppc64 ppc64-stack-shadows? t ;
M: freebsd lr-save 2 cells ;
M: freebsd has-toc f ;
M: freebsd reserved-area-size 4 cells ;
M: freebsd allows-null-dereference f ;
M: ppc float-right-align-on-stack? cpu ppc.64? ;
