! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math namespaces make sequences
system layouts alien alien.c-types alien.accessors alien.libraries
slots splitting assocs combinators fry locals compiler.constants
classes.struct compiler.codegen compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.intrinsics compiler.cfg.stack-frame
cpu.x86.assembler cpu.x86.assembler.operands cpu.x86
cpu.architecture vm ;
FROM: layouts => cell cells ;
IN: cpu.x86.64

: param-reg ( n -- reg ) int-regs cdecl param-regs at nth ;

: param-reg-0 ( -- reg ) 0 param-reg ; inline
: param-reg-1 ( -- reg ) 1 param-reg ; inline
: param-reg-2 ( -- reg ) 2 param-reg ; inline
: param-reg-3 ( -- reg ) 3 param-reg ; inline

M: x86.64 pic-tail-reg RBX ;

M: x86.64 return-regs
    {
        { int-regs { RAX EDX } }
        { float-regs { XMM0 XMM1 } }
    } ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;
M: x86.64 frame-reg RBP ;

M: x86.64 machine-registers
    {
        { int-regs { RAX RCX RDX RBX RBP RSI RDI R8 R9 R10 R11 R12 } }
        { float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;

: vm-reg ( -- reg ) R13 ; inline
: nv-reg ( -- reg ) RBX ; inline

M: x86.64 %mov-vm-ptr ( reg -- )
    vm-reg MOV ;

M: x86.64 %vm-field ( dst offset -- )
    [ vm-reg ] dip [+] MOV ;

M:: x86.64 %load-vector ( dst val rep -- )
    dst 0 [RIP+] rep copy-memory* val rc-relative rel-binary-literal ;

M: x86.64 %set-vm-field ( src offset -- )
    [ vm-reg ] dip [+] swap MOV ;

M: x86.64 %vm-field-ptr ( dst offset -- )
    [ vm-reg ] dip [+] LEA ;

M: x86.64 %prologue ( n -- )
    R11 -7 [RIP+] LEA
    dup PUSH
    R11 PUSH
    stack-reg swap 3 cells - SUB ;

M: x86.64 %prepare-jump
    pic-tail-reg xt-tail-pic-offset [RIP+] LEA ;

: load-cards-offset ( dst -- )
    0 MOV rc-absolute-cell rel-cards-offset ;

M: x86.64 %mark-card
    dup load-cards-offset
    [+] card-mark <byte> MOV ;

: load-decks-offset ( dst -- )
    0 MOV rc-absolute-cell rel-decks-offset ;

M: x86.64 %mark-deck
    dup load-decks-offset
    [+] card-mark <byte> MOV ;

M:: x86.64 %load-reg-param ( dst reg rep -- )
    dst reg rep %copy ;

M:: x86.64 %store-reg-param ( src reg rep -- )
    reg src rep %copy ;

M:: x86.64 %unbox ( dst src func rep -- )
    param-reg-0 src tagged-rep %copy
    param-reg-1 %mov-vm-ptr
    func f %alien-invoke
    dst rep %load-return ;

M:: x86.64 %box ( dst src func rep -- )
    0 rep reg-class-of cdecl param-regs at nth src rep %copy
    rep int-rep? os windows? or param-reg-1 param-reg-0 ? %mov-vm-ptr
    func f %alien-invoke
    dst int-rep %load-return ;

M:: x86.64 %allot-byte-array ( dst size -- )
    param-reg-0 size MOV
    param-reg-1 %mov-vm-ptr
    "allot_byte_array" f %alien-invoke
    dst int-rep %load-return ;

M: x86.64 %alien-invoke
    R11 0 MOV
    rc-absolute-cell rel-dlsym
    R11 CALL ;

M: x86.64 %begin-callback ( -- )
    param-reg-0 %mov-vm-ptr
    param-reg-1 0 MOV
    "begin_callback" f %alien-invoke ;

M: x86.64 %alien-callback ( quot -- )
    [ param-reg-0 ] dip %load-reference
    param-reg-0 quot-entry-point-offset [+] CALL ;

M: x86.64 %end-callback ( -- )
    param-reg-0 %mov-vm-ptr
    "end_callback" f %alien-invoke ;

: float-function-param ( i src -- )
    [ float-regs cdecl param-regs at nth ] dip double-rep %copy ;

M:: x86.64 %unary-float-function ( dst src func -- )
    0 src float-function-param
    func "libm" load-library %alien-invoke
    dst double-rep %load-return ;

M:: x86.64 %binary-float-function ( dst src1 src2 func -- )
    ! src1 might equal dst; otherwise it will be a spill slot
    ! src2 is always a spill slot
    0 src1 float-function-param
    1 src2 float-function-param
    func "libm" load-library %alien-invoke
    dst double-rep %load-return ;

M: x86.64 long-long-on-stack? f ;

M: x86.64 float-on-stack? f ;

M: x86.64 struct-return-on-stack? f ;

! The result of reading 4 bytes from memory is a fixnum on
! x86-64.
enable-alien-4-intrinsics

USE: vocabs.loader

{
    { [ os unix? ] [ "cpu.x86.64.unix" require ] }
    { [ os winnt? ] [ "cpu.x86.64.winnt" require ] }
} cond

check-sse
