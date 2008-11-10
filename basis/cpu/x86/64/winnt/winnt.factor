! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel layouts system math alien.c-types
compiler.cfg.registers cpu.architecture cpu.x86.assembler cpu.x86 ;
IN: cpu.x86.64.winnt

M: int-regs param-regs drop { RCX RDX R8 R9 } ;

M: float-regs param-regs drop { XMM0 XMM1 XMM2 XMM3 } ;

M: x86.64 reserved-area-size 4 cells ;

M: x86.64 struct-small-enough? ( size -- ? )
    heap-size cell <= ;

M: x86.64 dummy-stack-params? f ;

M: x86.64 dummy-int-params? t ;

M: x86.64 dummy-fp-params? t ;

<<
"longlong" "ptrdiff_t" typedef
"int" "long" typedef
"uint" "ulong" typedef
>>
