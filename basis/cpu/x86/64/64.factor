! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel math namespaces make sequences system
layouts alien alien.c-types alien.accessors slots
splitting assocs combinators locals compiler.constants
compiler.codegen compiler.codegen.fixup compiler.cfg.instructions
compiler.cfg.builder compiler.cfg.intrinsics compiler.cfg.stack-frame
cpu.x86.assembler cpu.x86.assembler.operands cpu.x86 cpu.architecture ;
IN: cpu.x86.64

M: x86.64 machine-registers
    {
        { int-regs { RAX RCX RDX RBX RBP RSI RDI R8 R9 R10 R11 R12 R13 } }
        { float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;

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

M: x86.64 param-reg-1 int-regs param-regs first ;
M: x86.64 param-reg-2 int-regs param-regs second ;
: param-reg-3 ( -- reg ) int-regs param-regs third ; inline

M: x86.64 pic-tail-reg RBX ;

M: int-regs return-reg drop RAX ;
M: float-regs return-reg drop XMM0 ;

M: x86.64 %prologue ( n -- )
    temp-reg 0 MOV rc-absolute-cell rel-this
    dup PUSH
    temp-reg PUSH
    stack-reg swap 3 cells - SUB ;

M: stack-params copy-register*
    drop
    {
        { [ dup  integer? ] [ R11 swap next-stack@ MOV  R11 MOV ] }
        { [ over integer? ] [ R11 swap MOV              param@ R11 MOV ] }
    } cond ;

M: x86 %save-param-reg [ param@ ] 2dip copy-register ;

M: x86 %load-param-reg [ swap param@ ] dip copy-register ;

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

M: x86.64 %vm-invoke-1st-arg ( function -- )
    param-reg-1 0 MOV rc-absolute-cell rt-vm rel-fixup
    f %alien-invoke ;

: %vm-invoke-2nd-arg ( function -- )
    param-reg-2 0 MOV rc-absolute-cell rt-vm rel-fixup
    f %alien-invoke ;

M: x86.64 %vm-invoke-3rd-arg ( function -- )
    param-reg-3 0 MOV rc-absolute-cell rt-vm rel-fixup
    f %alien-invoke ;

: %vm-invoke-4th-arg ( function -- )
    int-regs param-regs fourth 0 MOV rc-absolute-cell rt-vm rel-fixup
    f %alien-invoke ;


M:: x86.64 %unbox ( n rep func -- )
    ! Call the unboxer
    func %vm-invoke-2nd-arg
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
    "alien_offset" %vm-invoke-2nd-arg
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
    ! Copy the struct to the C stack
    "to_value_struct" %vm-invoke-4th-arg ;

: load-return-value ( rep -- )
    [ [ 0 ] dip reg-class-of param-reg ]
    [ reg-class-of return-reg ]
    [ ]
    tri copy-register ;



M:: x86.64 %box ( n rep func -- )
    n [
        n
        0 rep reg-class-of param-reg
        rep %load-param-reg
    ] [
        rep load-return-value
    ] if
    rep int-rep? [ func %vm-invoke-2nd-arg ] [ func %vm-invoke-1st-arg ] if ;

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
        "box_small_struct" %vm-invoke-4th-arg
    ] with-return-regs ;

: struct-return@ ( n -- operand )
    [ stack-frame get params>> ] unless* param@ ;

M: x86.64 %box-large-struct ( n c-type -- )
    ! Struct size is parameter 2
    param-reg-2 swap heap-size MOV
    ! Compute destination address
    param-reg-1 swap struct-return@ LEA
    ! Copy the struct from the C stack
    "box_value_struct" %vm-invoke-3rd-arg ;

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
    "unbox_alien" %vm-invoke-1st-arg
    RBP RAX MOV ;

M: x86.64 %alien-indirect ( -- )
    RBP CALL ;

M: x86.64 %alien-callback ( quot -- )
    param-reg-1 swap %load-reference
    "c_to_factor" %vm-invoke-2nd-arg ;

M: x86.64 %callback-value ( ctype -- )
    ! Save top of data stack
    %prepare-unbox
    ! Save top of data stack
    RSP 8 SUB
    param-reg-1 PUSH
    ! Restore data/call/retain stacks
    "unnest_stacks" %vm-invoke-1st-arg
    ! Put former top of data stack in param-reg-1
    param-reg-1 POP
    RSP 8 ADD
    ! Unbox former top of data stack to return registers
    unbox-return ;

: float-function-param ( i spill-slot -- )
    [ float-regs param-regs nth ] [ n>> spill@ ] bi* MOVSD ;

: float-function-return ( reg -- )
    float-regs return-reg double-rep copy-register ;

M:: x86.64 %unary-float-function ( dst src func -- )
    0 src float-function-param
    func f %alien-invoke
    dst float-function-return ;

M:: x86.64 %binary-float-function ( dst src1 src2 func -- )
    0 src1 float-function-param
    1 src2 float-function-param
    func f %alien-invoke
    dst float-function-return ;

! The result of reading 4 bytes from memory is a fixnum on
! x86-64.
enable-alien-4-intrinsics

! Enable fast calling of libc math functions
enable-float-functions

USE: vocabs.loader

{
    { [ os unix? ] [ "cpu.x86.64.unix" require ] }
    { [ os winnt? ] [ "cpu.x86.64.winnt" require ] }
} cond

check-sse
