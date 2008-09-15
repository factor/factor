! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system cpu.x86.assembler compiler.cfg.registers
compiler.backend ;
IN: compiler.backend.x86.64

M: x86.64 machine-registers
    {
        { int-regs { RAX RCX RDX RBP RSI RDI R8 R9 R10 R11 R12 R13 } }
        { double-float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;
