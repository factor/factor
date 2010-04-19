! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math namespaces make sequences
system layouts alien alien.c-types alien.accessors alien.libraries
slots splitting assocs combinators locals compiler.constants
compiler.codegen compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.intrinsics compiler.cfg.stack-frame
cpu.x86.assembler cpu.x86.assembler.operands cpu.x86
cpu.architecture vm ;
FROM: layouts => cell cells ;
IN: cpu.x86.64

: param-reg-0 ( -- reg ) 0 int-regs cdecl param-reg ; inline
: param-reg-1 ( -- reg ) 1 int-regs cdecl param-reg ; inline
: param-reg-2 ( -- reg ) 2 int-regs cdecl param-reg ; inline
: param-reg-3 ( -- reg ) 3 int-regs cdecl param-reg ; inline

M: x86.64 pic-tail-reg RBX ;

M: int-regs return-reg drop RAX ;
M: float-regs return-reg drop XMM0 ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;
M: x86.64 frame-reg RBP ;

M: x86.64 extra-stack-space drop 0 ;

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

M: x86.64 %set-vm-field ( src offset -- )
    [ vm-reg ] dip [+] swap MOV ;

M: x86.64 %vm-field-ptr ( dst offset -- )
    [ vm-reg ] dip [+] LEA ;

M: x86.64 %prologue ( n -- )
    temp-reg -7 [RIP+] LEA
    dup PUSH
    temp-reg PUSH
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

M:: x86.64 %dispatch ( src temp -- )
    ! Load jump table base.
    temp HEX: ffffffff MOV
    building get length :> start
    0 rc-absolute-cell rel-here
    ! Add jump table base
    temp src ADD
    temp HEX: 7f [+] JMP
    building get length :> end
    ! Fix up the displacement above
    cell code-alignment
    [ end start - + building get dup pop* push ]
    [ align-code ]
    bi ;

M: stack-params copy-register*
    drop
    {
        { [ dup  integer? ] [ R11 swap next-stack@ MOV  R11 MOV ] }
        { [ over integer? ] [ R11 swap MOV              param@ R11 MOV ] }
    } cond ;

M: x86.64 %save-param-reg [ param@ ] 2dip %copy ;

M: x86.64 %load-param-reg [ swap param@ ] dip %copy ;

: with-return-regs ( quot -- )
    [
        V{ RDX RAX } clone int-regs set
        V{ XMM1 XMM0 } clone float-regs set
        call
    ] with-scope ; inline

M: x86.64 %pop-stack ( n -- )
    param-reg-0 swap ds-reg reg-stack MOV ;

M: x86.64 %pop-context-stack ( -- )
    temp-reg %context
    param-reg-0 temp-reg "datastack" context-field-offset [+] MOV
    param-reg-0 param-reg-0 [] MOV
    temp-reg "datastack" context-field-offset [+] bootstrap-cell SUB ;

M:: x86.64 %unbox ( n rep func -- )
    param-reg-1 %mov-vm-ptr
    ! Call the unboxer
    func f %alien-invoke
    ! Store the return value on the C stack if this is an
    ! alien-invoke, otherwise leave it the return register if
    ! this is the end of alien-callback
    n [ n rep reg-class-of return-reg rep %save-param-reg ] when ;

: %unbox-struct-field ( c-type i -- )
    ! Alien must be in param-reg-0.
    R11 swap cells [+] swap rep>> reg-class-of {
        { int-regs [ int-regs get pop swap MOV ] }
        { float-regs [ float-regs get pop swap MOVSD ] }
    } case ;

M: x86.64 %unbox-small-struct ( c-type -- )
    ! Alien must be in param-reg-0.
    param-reg-1 %mov-vm-ptr
    "alien_offset" f %alien-invoke
    ! Move alien_offset() return value to R11 so that we don't
    ! clobber it.
    R11 RAX MOV
    [
        flatten-value-type [ %unbox-struct-field ] each-index
    ] with-return-regs ;

M:: x86.64 %unbox-large-struct ( n c-type -- )
    ! Source is in param-reg-0
    ! Load destination address into param-reg-1
    param-reg-1 n param@ LEA
    ! Load structure size into param-reg-2
    param-reg-2 c-type heap-size MOV
    param-reg-3 %mov-vm-ptr
    ! Copy the struct to the C stack
    "to_value_struct" f %alien-invoke ;

: load-return-value ( rep -- )
    [ [ 0 ] dip reg-class-of cdecl param-reg ]
    [ reg-class-of return-reg ]
    [ ]
    tri %copy ;

M:: x86.64 %box ( n rep func -- )
    n [
        n
        0 rep reg-class-of cdecl param-reg
        rep %load-param-reg
    ] [
        rep load-return-value
    ] if
    rep int-rep? os windows? or param-reg-1 param-reg-0 ? %mov-vm-ptr
    func f %alien-invoke ;

: box-struct-field@ ( i -- operand ) 1 + cells param@ ;

: %box-struct-field ( c-type i -- )
    box-struct-field@ swap c-type-rep reg-class-of {
        { int-regs [ int-regs get pop MOV ] }
        { float-regs [ float-regs get pop MOVSD ] }
    } case ;

M: x86.64 %box-small-struct ( c-type -- )
    #! Box a <= 16-byte struct.
    [
        [ flatten-value-type [ %box-struct-field ] each-index ]
        [ param-reg-2 swap heap-size MOV ] bi
        param-reg-0 0 box-struct-field@ MOV
        param-reg-1 1 box-struct-field@ MOV
        param-reg-3 %mov-vm-ptr
        "from_small_struct" f %alien-invoke
    ] with-return-regs ;

: struct-return@ ( n -- operand )
    [ stack-frame get params>> ] unless* param@ ;

M: x86.64 %box-large-struct ( n c-type -- )
    ! Struct size is parameter 2
    param-reg-1 swap heap-size MOV
    ! Compute destination address
    param-reg-0 swap struct-return@ LEA
    param-reg-2 %mov-vm-ptr
    ! Copy the struct from the C stack
    "from_value_struct" f %alien-invoke ;

M: x86.64 %prepare-box-struct ( -- )
    ! Compute target address for value struct return
    RAX f struct-return@ LEA
    ! Store it as the first parameter
    0 param@ RAX MOV ;

M: x86.64 %prepare-var-args RAX RAX XOR ;

M: x86.64 %alien-invoke
    R11 0 MOV
    rc-absolute-cell rel-dlsym
    R11 CALL ;

M: x86.64 %prepare-alien-indirect ( -- )
    param-reg-0 ds-reg [] MOV
    ds-reg 8 SUB
    param-reg-1 %mov-vm-ptr
    "pinned_alien_offset" f %alien-invoke
    nv-reg RAX MOV ;

M: x86.64 %alien-indirect ( -- )
    nv-reg CALL ;

M: x86.64 %begin-callback ( -- )
    param-reg-0 %mov-vm-ptr
    param-reg-1 0 MOV
    "begin_callback" f %alien-invoke ;

M: x86.64 %alien-callback ( quot -- )
    param-reg-0 param-reg-1 %restore-context
    param-reg-0 swap %load-reference
    param-reg-0 quot-entry-point-offset [+] CALL
    param-reg-0 param-reg-1 %save-context ;

M: x86.64 %end-callback ( -- )
    param-reg-0 %mov-vm-ptr
    "end_callback" f %alien-invoke ;

M: x86.64 %end-callback-value ( ctype -- )
    %pop-context-stack
    nv-reg param-reg-0 MOV
    %end-callback
    param-reg-0 nv-reg MOV
    ! Unbox former top of data stack to return registers
    unbox-return ;

: float-function-param ( i src -- )
    [ float-regs cdecl param-regs nth ] dip double-rep %copy ;

: float-function-return ( reg -- )
    float-regs return-reg double-rep %copy ;

M:: x86.64 %unary-float-function ( dst src func -- )
    0 src float-function-param
    func "libm" load-library %alien-invoke
    dst float-function-return ;

M:: x86.64 %binary-float-function ( dst src1 src2 func -- )
    ! src1 might equal dst; otherwise it will be a spill slot
    ! src2 is always a spill slot
    0 src1 float-function-param
    1 src2 float-function-param
    func "libm" load-library %alien-invoke
    dst float-function-return ;

M:: x86.64 %call-gc ( gc-root-count temp -- )
    ! Pass pointer to start of GC roots as first parameter
    param-reg-0 gc-root-base param@ LEA
    ! Pass number of roots as second parameter
    param-reg-1 gc-root-count MOV
    ! Pass VM ptr as third parameter
    param-reg-2 %mov-vm-ptr
    ! Call GC
    "inline_gc" f %alien-invoke ;

M: x86.64 struct-return-pointer-type void* ;

! The result of reading 4 bytes from memory is a fixnum on
! x86-64.
enable-alien-4-intrinsics

USE: vocabs.loader

{
    { [ os unix? ] [ "cpu.x86.64.unix" require ] }
    { [ os winnt? ] [ "cpu.x86.64.winnt" require ] }
} cond

check-sse
