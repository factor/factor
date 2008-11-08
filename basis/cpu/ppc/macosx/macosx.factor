! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors system kernel alien.c-types cpu.architecture cpu.ppc ;
IN: cpu.ppc.macosx

<<
4 "longlong" c-type (>>align)
4 "ulonglong" c-type (>>align)
4 "double" c-type (>>align)
>>

M: macosx reserved-area-size 6 ;

M: macosx lr-save 2 ;

M: float-regs param-regs { 1 2 3 4 5 6 7 8 9 10 11 12 13 } ;

M: ppc value-structs? drop t ;

M: ppc fp-shadows-int? drop t ;
