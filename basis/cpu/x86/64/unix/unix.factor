! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel layouts system compiler.cfg.registers
cpu.architecture cpu.x86.assembler cpu.x86 ;
IN: cpu.x86.64.unix

M: int-regs param-regs drop { RDI RSI RDX RCX R8 R9 } ;

M: float-regs param-regs
    drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;

M: x86.64 reserved-area-size 0 ;
