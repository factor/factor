! Copyright (C) 2005, 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler generic kernel kernel-internals
math namespaces sequences ;

! AMD64 register assignments
! RAX RCX RDX RSI RDI R8 R9 R10 integer vregs
! XMM0 - XMM7 float vregs
! R13 cards_offset
! R14 datastack
! R15 callstack

: ds-reg R14 ; inline
: cs-reg R15 ; inline
: remainder-reg RDX ; inline

M: int-regs return-reg drop RAX ;
M: int-regs vregs drop { RAX RCX RDX RSI RDI R8 R9 R10 R11 } ;
M: int-regs fastcall-regs drop { RDI RSI RDX RCX R8 R9 } ;

M: float-regs return-reg drop XMM0 ;
M: float-regs vregs drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;
M: float-regs fastcall-regs vregs ;

: address-operand ( address -- operand )
    #! On AMD64, we have to load 64-bit addresses into a
    #! scratch register first. The usage of R11 here is a hack.
    #! This word can only be called right before a subroutine
    #! call, where all vregs have been flushed anyway.
    R11 [ swap MOV ] keep ; inline

: compile-c-call ( symbol dll -- )
    2dup dlsym address-operand rel-absolute-cell rel-dlsym CALL ;

: compile-c-call* ( symbol dll args -- )
    T{ int-regs } fastcall-regs
    swap [ MOV ] 2each compile-c-call ;

: fixnum>slot@ drop ; inline

: prepare-division CQO ; inline

M: object load-literal ( literal vreg -- )
    #! We use RIP-relative addressing. The '3' is a hardcoded
    #! instruction length.
    v>operand swap add-literal from 3 - [] MOV ;

: stack-increment \ stack-reserve get 16 align 8 + ;

: %prologue ( n -- )
    \ stack-reserve set RSP stack-increment SUB ;

: %epilogue ( -- )
    RSP stack-increment ADD ;
