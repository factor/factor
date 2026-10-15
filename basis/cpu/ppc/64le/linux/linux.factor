! Copyright (C) 2011 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: system kernel layouts cpu.architecture cpu.ppc cpu.ppc.elfv2 ;
IN: cpu.ppc.64le.linux

M: ppc.64le ppc64-stack-shadows? t ;
M: linux lr-save 2 cells ;
M: linux has-toc f ;
M: linux reserved-area-size 4 cells ;
M: linux allows-null-dereference f ;
M: ppc float-right-align-on-stack? f ;
