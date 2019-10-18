! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors system kernel layouts
alien.c-types cpu.architecture cpu.ppc ;
IN: cpu.ppc.linux

<<
t "longlong" c-type stack-align?<<
t "ulonglong" c-type stack-align?<<
>>

M: linux reserved-area-size 2 cells ;

M: linux lr-save 1 cells ;

M: ppc param-regs
    drop {
        { int-regs { 3 4 5 6 7 8 9 10 } }
        { float-regs { 1 2 3 4 5 6 7 8 } }
    } ;

M: ppc value-struct? drop f ;

M: ppc dummy-stack-params? f ;

M: ppc dummy-int-params? f ;

M: ppc dummy-fp-params? f ;
