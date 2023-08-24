! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel layouts system math alien.c-types sequences
compiler.cfg.registers cpu.architecture cpu.x86.assembler
cpu.x86 cpu.x86.64 cpu.x86.assembler.operands ;
IN: cpu.x86.64.windows

M: x86.64 param-regs
    drop {
        { int-regs { RCX RDX R8 R9 } }
        { float-regs { XMM0 XMM1 XMM2 XMM3 } }
    } ;

M: x86.64 reserved-stack-space 4 cells ;

M: x86.64 return-struct-in-registers?
    heap-size { 1 2 4 8 } member? ;

M: x86.64 value-struct? heap-size { 1 2 4 8 } member? ;

M: x86.64 dummy-stack-params? f ;

M: x86.64 dummy-int-params? t ;

M: x86.64 dummy-fp-params? t ;

M: x86.64 %prepare-var-args drop ;
