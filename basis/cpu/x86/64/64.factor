! Copyright (C) 2005, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien alien.c-types assocs combinators compiler.cfg.intrinsics
compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.x86 cpu.x86.assembler cpu.x86.assembler.operands cpu.x86.features
kernel locals math sequences specialized-arrays system vocabs ;
SPECIALIZED-ARRAY: uint
IN: cpu.x86.64

: param-reg ( n -- reg ) int-regs cdecl param-regs at nth ;

: param-reg-0 ( -- reg ) 0 param-reg ; inline
: param-reg-1 ( -- reg ) 1 param-reg ; inline
: param-reg-2 ( -- reg ) 2 param-reg ; inline
: param-reg-3 ( -- reg ) 3 param-reg ; inline

M: x86.64 pic-tail-reg RBX ;

M: x86.64 return-regs
    {
        { int-regs { RAX RDX } }
        { float-regs { XMM0 XMM1 } }
    } ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;
M: x86.64 frame-reg RBP ;

M: x86.64 machine-registers
    {
        { int-regs { RAX RBX RCX RDX RBP RSI RDI R8 R9 R10 R11 R12 } }
        { float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;

: vm-reg ( -- reg ) R13 ; inline
: nv-reg ( -- reg ) RBX ; inline

M: x86.64 %vm-field
    [ vm-reg ] dip [+] MOV ;

M:: x86.64 %load-vector ( dst val rep -- )
    dst 0 [RIP+] rep copy-memory* val rc-relative rel-binary-literal ;

M: x86.64 %set-vm-field
    [ vm-reg ] dip [+] swap MOV ;

M: x86.64 %vm-field-ptr
    [ vm-reg ] dip [+] LEA ;

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

M:: x86.64 %load-stack-param ( vreg rep n -- )
    rep return-reg n next-stack@ rep %copy
    vreg rep return-reg rep %copy ;

M:: x86.64 %store-stack-param ( vreg rep n -- )
    rep return-reg vreg rep %copy
    n reserved-stack-space + stack@ rep return-reg rep %copy ;

M:: x86.64 %load-reg-param ( vreg rep reg -- )
    vreg reg rep %copy ;

M:: x86.64 %store-reg-param ( vreg rep reg -- )
    reg vreg rep %copy ;

M: x86.64 %discard-reg-param
    2drop ;

M:: x86.64 %unbox ( dst src func rep -- )
    param-reg-0 src tagged-rep %copy
    param-reg-1 vm-reg MOV
    func f f %c-invoke
    dst rep %load-return ;

M:: x86.64 %box ( dst src func rep gc-map -- )
    0 rep reg-class-of cdecl param-regs at nth src rep %copy
    rep int-rep? os windows? or param-reg-1 param-reg-0 ? vm-reg MOV
    func f gc-map %c-invoke
    dst int-rep %load-return ;

M: x86.64 %c-invoke
    [ R11 0 MOV rc-absolute-cell rel-dlsym R11 CALL ] dip
    gc-map-here ;

M: x86.64 %begin-callback
    param-reg-0 vm-reg MOV
    param-reg-1 0 MOV
    "begin_callback" f f %c-invoke ;

M: x86.64 %end-callback
    param-reg-0 vm-reg MOV
    "end_callback" f f %c-invoke ;

M: x86.64 stack-cleanup 3drop 0 ;

M: x86.64 %cleanup 0 assert= ;

M: x86.64 %safepoint
    0 [RIP+] EAX MOV rc-relative rel-safepoint ;

M: x86.64 long-long-on-stack? f ;

M: x86.64 struct-return-on-stack? f ;

M: x86.64 (cpuid)
    void { uint uint void* } cdecl [
        RAX param-reg-0 MOV
        RCX param-reg-1 MOV
        RSI param-reg-2 MOV
        CPUID
        RSI [] EAX MOV
        RSI 4 [+] EBX MOV
        RSI 8 [+] ECX MOV
        RSI 12 [+] EDX MOV
    ] alien-assembly ;

{
    { [ os unix? ] [ "cpu.x86.64.unix" require ] }
    { [ os windows? ] [ "cpu.x86.64.windows" require ] }
} cond
