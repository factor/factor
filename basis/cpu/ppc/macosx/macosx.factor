! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors system kernel layouts
alien.c-types cpu.architecture cpu.ppc ;
IN: cpu.ppc.macosx

M: macosx reserved-area-size 6 cells ;

M: macosx lr-save 2 cells ;

M: float-regs param-regs drop { 1 2 3 4 5 6 7 8 9 10 11 12 13 } ;

M: ppc value-struct? drop t ;

M: ppc dummy-stack-params? t ;

M: ppc dummy-int-params? t ;

M: ppc dummy-fp-params? f ;
