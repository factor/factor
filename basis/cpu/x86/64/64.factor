! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math namespaces make sequences system
layouts alien alien.c-types alien.accessors slots
splitting assocs combinators locals compiler.constants
compiler.codegen compiler.codegen.fixup compiler.cfg.instructions
compiler.cfg.builder compiler.cfg.intrinsics compiler.cfg.stack-frame
cpu.x86.assembler cpu.x86.assembler.operands cpu.x86 cpu.architecture ;
IN: cpu.x86.64

: param-reg-1 ( -- reg ) int-regs param-regs first ; inline
: param-reg-2 ( -- reg ) int-regs param-regs second ; inline
: param-reg-3 ( -- reg ) int-regs param-regs third ; inline
: param-reg-4 ( -- reg ) int-regs param-regs fourth ; inline

M: x86.64 pic-tail-reg RBX ;

M: int-regs return-reg drop RAX ;
M: float-regs return-reg drop XMM0 ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;

M: x86.64 extra-stack-space drop 0 ;

M: x86.64 machine-registers
    {
        { int-regs { RAX RCX RDX RBX RBP RSI RDI R8 R9 R10 R11 R12 R13 } }
        { float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;

: param@ ( n -- op ) reserved-stack-space + stack@ ;

M: x86.64 %prologue ( n -- )
    temp-reg 0 MOV rc-absolute-cell rel-this
    dup PUSH
    temp-reg PUSH
    stack-reg swap 3 cells - SUB ;

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
    building get length :> start
    ! Load jump table base.
    temp HEX: ffffffff MOV
    0 rc-absolute-cell rel-here
    ! Add jump table base
    temp src ADD
    temp HEX: 7f [+] JMP
    building get length :> end
    ! Fix up the displacement above
    cell code-alignment
    [ end start - 2 - + building get dup pop* push ]
    [ align-code ]
    bi ;

M: stack-params copy-register*
    drop
    {
        { [ dup  integer? ] [ R11 swap next-stack@ MOV  R11 MOV ] }
        { [ over integer? ] [ R11 swap MOV              param@ R11 MOV ] }
    } cond ;

M: x86 %save-param-reg [ param@ ] 2dip %copy ;

M: x86 %load-param-reg [ swap param@ ] dip %copy ;

: with-return-regs ( quot -- )
    [
        V{ RDX RAX } clone int-regs set
        V{ XMM1 XMM0 } clone float-regs set
        call
    ] with-scope ; inline

M: x86.64 %prepare-unbox ( n -- )
    param-reg-1 swap ds-reg reg-stack MOV ;

M:: x86.64 %unbox ( n rep func -- )
    param-reg-2 %mov-vm-ptr
    ! Call the unboxer
    func f %alien-invoke
    ! Store the return value on the C stack if this is an
    ! alien-invoke, otherwise leave it the return register if
    ! this is the end of alien-callback
    n [ n rep reg-class-of return-reg rep %save-param-reg ] when ;

M: x86.64 %unbox-long-long ( n func -- )
    [ int-rep ] dip %unbox ;

: %unbox-struct-field ( c-type i -- )
    ! Alien must be in param-reg-1.
    R11 swap cells [+] swap rep>> reg-class-of {
        { int-regs [ int-regs get pop swap MOV ] }
        { float-regs [ float-regs get pop swap MOVSD ] }
    } case ;

M: x86.64 %unbox-small-struct ( c-type -- )
    ! Alien must be in param-reg-1.
    param-reg-2 %mov-vm-ptr
    "alien_offset" f %alien-invoke
    ! Move alien_offset() return value to R11 so that we don't
    ! clobber it.
    R11 RAX MOV
    [
        flatten-value-type [ %unbox-struct-field ] each-index
    ] with-return-regs ;

M:: x86.64 %unbox-large-struct ( n c-type -- )
    ! Source is in param-reg-1
    ! Load destination address into param-reg-2
    param-reg-2 n param@ LEA
    ! Load structure size into param-reg-3
    param-reg-3 c-type heap-size MOV
    param-reg-4 %mov-vm-ptr
    ! Copy the struct to the C stack
    "to_value_struct" f %alien-invoke ;

: load-return-value ( rep -- )
    [ [ 0 ] dip reg-class-of param-reg ]
    [ reg-class-of return-reg ]
    [ ]
    tri %copy ;

M:: x86.64 %box ( n rep func -- )
    n [
        n
        0 rep reg-class-of param-reg
        rep %load-param-reg
    ] [
        rep load-return-value
    ] if
    rep int-rep? [ param-reg-2 ] [ param-reg-1 ] if %mov-vm-ptr
    func f %alien-invoke ;

M: x86.64 %box-long-long ( n func -- )
    [ int-rep ] dip %box ;

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
        [ param-reg-3 swap heap-size MOV ] bi
        param-reg-1 0 box-struct-field@ MOV
        param-reg-2 1 box-struct-field@ MOV
        param-reg-4 %mov-vm-ptr
        "box_small_struct" f %alien-invoke
    ] with-return-regs ;

: struct-return@ ( n -- operand )
    [ stack-frame get params>> ] unless* param@ ;

M: x86.64 %box-large-struct ( n c-type -- )
    ! Struct size is parameter 2
    param-reg-2 swap heap-size MOV
    ! Compute destination address
    param-reg-1 swap struct-return@ LEA
    param-reg-3 %mov-vm-ptr
    ! Copy the struct from the C stack
    "box_value_struct" f %alien-invoke ;

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

M: x86.64 %nest-stacks ( -- )
    ! Save current frame. See comment in vm/contexts.hpp
    param-reg-1 stack-reg stack-frame get total-size>> 3 cells - [+] LEA
    param-reg-2 %mov-vm-ptr
    "nest_stacks" f %alien-invoke ;

M: x86.64 %unnest-stacks ( -- )
    param-reg-1 %mov-vm-ptr
    "unnest_stacks" f %alien-invoke ;

M: x86.64 %prepare-alien-indirect ( -- )
    param-reg-1 %mov-vm-ptr
    "unbox_alien" f %alien-invoke
    RBP RAX MOV ;

M: x86.64 %alien-indirect ( -- )
    RBP CALL ;

M: x86.64 %alien-callback ( quot -- )
    param-reg-1 swap %load-reference
    param-reg-2 %mov-vm-ptr
    "c_to_factor" f %alien-invoke ;

M: x86.64 %callback-value ( ctype -- )
    0 %prepare-unbox
    RSP 8 SUB
    param-reg-1 PUSH
    param-reg-1 %mov-vm-ptr
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Put former top of data stack in param-reg-1
    param-reg-1 POP
    RSP 8 ADD
    ! Unbox former top of data stack to return registers
    unbox-return ;

: float-function-param ( i src -- )
    [ float-regs param-regs nth ] dip double-rep %copy ;

: float-function-return ( reg -- )
    float-regs return-reg double-rep %copy ;

M:: x86.64 %unary-float-function ( dst src func -- )
    0 src float-function-param
    func f %alien-invoke
    dst float-function-return ;

M:: x86.64 %binary-float-function ( dst src1 src2 func -- )
    ! src1 might equal dst; otherwise it will be a spill slot
    ! src2 is always a spill slot
    0 src1 float-function-param
    1 src2 float-function-param
    func f %alien-invoke
    dst float-function-return ;

M:: x86.64 %call-gc ( gc-root-count temp -- )
    ! Pass pointer to start of GC roots as first parameter
    param-reg-1 gc-root-base param@ LEA
    ! Pass number of roots as second parameter
    param-reg-2 gc-root-count MOV
    ! Pass VM ptr as third parameter
    param-reg-3 %mov-vm-ptr
    ! Call GC
    "inline_gc" f %alien-invoke ;

! The result of reading 4 bytes from memory is a fixnum on
! x86-64.
enable-alien-4-intrinsics

USE: vocabs.loader

{
    { [ os unix? ] [ "cpu.x86.64.unix" require ] }
    { [ os winnt? ] [ "cpu.x86.64.winnt" require ] }
} cond

check-sse
