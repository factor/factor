! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: alien arrays assembler compiler compiler-backend kernel
kernel-internals math sequences ;

! AMD64 register assignments
! RAX RCX RDX RSI RDI R8 R9 R10 R11 vregs
! R14 datastack
! R15 callstack

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    f ; inline

: ds-reg R14 ; inline
: cs-reg R15 ; inline
: remainder-reg RDX ; inline

: vregs { RAX RCX RDX RSI RDI R8 R9 R10 R11 } ; inline

M: int-regs return-reg drop RAX ;

M: int-regs fastcall-regs drop { RDI RSI RDX RCX R8 R9 } ;

: compile-c-call ( symbol dll -- )
    2dup dlsym 0 scratch swap MOV
    rel-absolute-cell rel-dlsym 0 scratch CALL ;

: compile-c-call* ( symbol dll args -- )
    T{ int-regs } fastcall-regs
    swap [ MOV ] 2each compile-c-call ;

M: float-regs return-reg drop XMM0 ;

M: float-regs fastcall-regs
    drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;

: dual-fp/int-regs? f ;

: address-operand ( address -- operand )
    #! On AMD64, we have to load 64-bit addresses into a
    #! scratch register first. The usage of R11 here is a hack.
    #! We cannot write '0 scratch' since scratch registers are
    #! not permitted inside basic-block VOPs.
    R11 [ swap MOV ] keep ; inline

: fixnum>slot@ drop ; inline

: prepare-division CQO ; inline

: load-indirect ( dest literal -- )
    #! We use RIP-relative addressing. The '3' is a hardcoded
    #! instruction length.
    add-literal from 3 - 1array MOV ; inline
