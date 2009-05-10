! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math namespaces make sequences
system layouts alien alien.c-types alien.accessors alien.structs
slots splitting assocs combinators make locals cpu.x86.assembler
cpu.x86 cpu.architecture compiler.constants
compiler.codegen compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.intrinsics ;
IN: cpu.x86.64

M: x86.64 machine-registers
    {
        { int-regs { RAX RCX RDX RBX RBP RSI RDI R8 R9 R10 R11 R12 R13 } }
        { double-float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;

M:: x86.64 %dispatch ( src temp offset -- )
    ! Load jump table base.
    temp HEX: ffffffff MOV
    offset cells rc-absolute-cell rel-here
    ! Add jump table base
    src temp ADD
    src HEX: 7f [+] JMP
    ! Fix up the displacement above
    cell code-alignment
    [ 15 + building get dup pop* push ]
    [ align-code ]
    bi ;

M: x86.64 param-reg-1 int-regs param-regs first ;
M: x86.64 param-reg-2 int-regs param-regs second ;
: param-reg-3 ( -- reg ) int-regs param-regs third ; inline

M: x86.64 pic-tail-reg RBX ;

M: int-regs return-reg drop RAX ;
M: float-regs return-reg drop XMM0 ;

M: x86.64 %prologue ( n -- )
    temp-reg-1 0 MOV rc-absolute-cell rel-this
    dup PUSH
    temp-reg-1 PUSH
    stack-reg swap 3 cells - SUB ;

M: stack-params %load-param-reg
    drop
    [ R11 swap param@ MOV ] dip
    param@ R11 MOV ;

M: stack-params %save-param-reg
    drop
    R11 swap next-stack@ MOV
    param@ R11 MOV ;

: with-return-regs ( quot -- )
    [
        V{ RDX RAX } clone int-regs set
        V{ XMM1 XMM0 } clone float-regs set
        call
    ] with-scope ; inline

M: x86.64 %prepare-unbox ( -- )
    ! First parameter is top of stack
    param-reg-1 R14 [] MOV
    R14 cell SUB ;

M: x86.64 %unbox ( n reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: x86.64 %unbox-long-long ( n func -- )
    int-regs swap %unbox ;

: %unbox-struct-field ( c-type i -- )
    ! Alien must be in param-reg-1.
    R11 swap cells [+] swap reg-class>> {
        { int-regs [ int-regs get pop swap MOV ] }
        { double-float-regs [ float-regs get pop swap MOVSD ] }
    } case ;

M: x86.64 %unbox-small-struct ( c-type -- )
    ! Alien must be in param-reg-1.
    "alien_offset" f %alien-invoke
    ! Move alien_offset() return value to R11 so that we don't
    ! clobber it.
    R11 RAX MOV
    [
        flatten-value-type [ %unbox-struct-field ] each-index
    ] with-return-regs ;

M: x86.64 %unbox-large-struct ( n c-type -- )
    ! Source is in param-reg-1
    heap-size
    ! Load destination address
    param-reg-2 rot param@ LEA
    ! Load structure size
    param-reg-3 swap MOV
    ! Copy the struct to the C stack
    "to_value_struct" f %alien-invoke ;

: load-return-value ( reg-class -- )
    0 over param-reg swap return-reg
    2dup eq? [ 2drop ] [ MOV ] if ;

M: x86.64 %box ( n reg-class func -- )
    rot [
        rot [ 0 swap param-reg ] keep %load-param-reg
    ] [
        swap load-return-value
    ] if*
    f %alien-invoke ;

M: x86.64 %box-long-long ( n func -- )
    int-regs swap %box ;

: box-struct-field@ ( i -- operand ) 1+ cells param@ ;

: %box-struct-field ( c-type i -- )
    box-struct-field@ swap reg-class>> {
        { int-regs [ int-regs get pop MOV ] }
        { double-float-regs [ float-regs get pop MOVSD ] }
    } case ;

M: x86.64 %box-small-struct ( c-type -- )
    #! Box a <= 16-byte struct.
    [
        [ flatten-value-type [ %box-struct-field ] each-index ]
        [ param-reg-3 swap heap-size MOV ] bi
        param-reg-1 0 box-struct-field@ MOV
        param-reg-2 1 box-struct-field@ MOV
        "box_small_struct" f %alien-invoke
    ] with-return-regs ;

: struct-return@ ( n -- operand )
    [ stack-frame get params>> ] unless* param@ ;

M: x86.64 %box-large-struct ( n c-type -- )
    ! Struct size is parameter 2
    param-reg-2 swap heap-size MOV
    ! Compute destination address
    param-reg-1 swap struct-return@ LEA
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

M: x86.64 %alien-invoke-tail
    R11 0 MOV
    rc-absolute-cell rel-dlsym
    R11 JMP ;

M: x86.64 %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    RBP RAX MOV ;

M: x86.64 %alien-indirect ( -- )
    RBP CALL ;

M: x86.64 %alien-callback ( quot -- )
    param-reg-1 swap %load-reference
    "c_to_factor" f %alien-invoke ;

M: x86.64 %callback-value ( ctype -- )
    ! Save top of data stack
    %prepare-unbox
    ! Save top of data stack
    RSP 8 SUB
    param-reg-1 PUSH
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Put former top of data stack in param-reg-1
    param-reg-1 POP
    RSP 8 ADD
    ! Unbox former top of data stack to return registers
    unbox-return ;

! The result of reading 4 bytes from memory is a fixnum on
! x86-64.
enable-alien-4-intrinsics

! SSE2 is always available on x86-64.
enable-float-intrinsics

USE: vocabs.loader

{
    { [ os unix? ] [ "cpu.x86.64.unix" require ] }
    { [ os winnt? ] [ "cpu.x86.64.winnt" require ] }
} cond
