! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: system cpu.x86.assembler compiler.cfg.registers
compiler.backend ;
IN: compiler.backend.x86.32

M: x86.32 machine-registers
    {
        { int-regs { EAX ECX EDX EBP EBX } }
        { float-regs { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } }
    } ;
