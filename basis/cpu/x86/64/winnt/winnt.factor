! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel layouts system math alien.c-types sequences
compiler.cfg.registers cpu.architecture cpu.x86.assembler cpu.x86
cpu.x86.assembler.operands ;
IN: cpu.x86.64.winnt

M: int-regs param-regs drop { RCX RDX R8 R9 } ;

M: float-regs param-regs drop { XMM0 XMM1 XMM2 XMM3 } ;

M: x86.64 reserved-stack-space 4 cells ;

M: x86.64 return-struct-in-registers? ( c-type -- ? )
    heap-size { 1 2 4 8 } member? ;

M: x86.64 value-struct? heap-size { 1 2 4 8 } member? ;

M: x86.64 dummy-stack-params? f ;

M: x86.64 dummy-int-params? t ;

M: x86.64 dummy-fp-params? t ;

M: x86.64 temp-reg RAX ;

<<
longlong ptrdiff_t typedef
longlong intptr_t  typedef
int  c-type long  define-primitive-type
uint c-type ulong define-primitive-type
>>
