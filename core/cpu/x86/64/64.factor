! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types arrays cpu.x86.assembler
cpu.x86.architecture cpu.x86.intrinsics cpu.x86.sse2
cpu.x86.allot cpu.architecture kernel kernel.private math
namespaces sequences generator.registers generator.fixup system
alien ;
IN: cpu.x86.64

PREDICATE: x86-backend amd64-backend
    x86-backend-cell 8 = ;

M: amd64-backend ds-reg R14 ;
M: amd64-backend rs-reg R15 ;
M: amd64-backend stack-reg RSP ;
M: x86-backend xt-reg RCX ;
M: x86-backend stack-save-reg RSI ;

M: temp-reg v>operand drop RBX ;

M: int-regs return-reg drop RAX ;
M: int-regs vregs drop { RAX RCX RDX RBP RSI RDI R8 R9 R10 R11 R12 R13 } ;
M: int-regs param-regs drop { RDI RSI RDX RCX R8 R9 } ;

M: float-regs return-reg drop XMM0 ;

M: float-regs vregs
    drop {
        XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
        XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
    } ;

M: float-regs param-regs
    drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;

M: amd64-backend address-operand ( address -- operand )
    #! On AMD64, we have to load 64-bit addresses into a
    #! scratch register first. The usage of R11 here is a hack.
    #! This word can only be called right before a subroutine
    #! call, where all vregs have been flushed anyway.
    temp-reg v>operand [ swap MOV ] keep ;

: compile-c-call ( symbol dll -- )
    0 address-operand >r rc-absolute-cell rel-dlsym r> CALL ;

M: amd64-backend fixnum>slot@ drop ;

M: amd64-backend prepare-division CQO ;

M: amd64-backend load-indirect ( literal reg -- )
    0 [] MOV rc-relative rel-literal ;

M: stack-params %load-param-reg
    drop
    >r temp-reg v>operand swap stack@ MOV
    r> stack@ temp-reg v>operand MOV ;

M: stack-params %save-param-reg
    >r stack-frame* + cell + swap r> %load-param-reg ;

M: amd64-backend %prepare-unbox ( -- )
    ! First parameter is top of stack
    RDI R14 [] MOV
    R14 cell SUB ;

M: amd64-backend %unbox ( n reg-class func -- )
    ! Call the unboxer
    f compile-c-call
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: amd64-backend %unbox-long-long ( n func -- )
    T{ int-regs } swap %unbox ;

M: amd64-backend %unbox-struct-1 ( -- )
    #! Alien must be in RDI.
    "alien_offset" f compile-c-call
    ! Load first cell
    RAX RAX [] MOV ;

M: amd64-backend %unbox-struct-2 ( -- )
    #! Alien must be in RDI.
    "alien_offset" f compile-c-call
    ! Load second cell
    RDX RAX cell [+] MOV
    ! Load first cell
    RAX RAX [] MOV ;

M: amd64-backend %unbox-large-struct ( n size -- )
    ! Source is in RDI
    ! Load destination address
    RSI RSP roll [+] LEA
    ! Load structure size
    RDX swap MOV
    ! Copy the struct to the C stack
    "to_value_struct" f compile-c-call ;

: load-return-value ( reg-class -- )
    0 over param-reg swap return-reg
    2dup eq? [ 2drop ] [ MOV ] if ;

M: amd64-backend %box ( n reg-class func -- )
    rot [
        rot [ 0 swap param-reg ] keep %load-param-reg
    ] [
        swap load-return-value
    ] if*
    f compile-c-call ;

M: amd64-backend %box-long-long ( n func -- )
    T{ int-regs } swap %box ;

M: amd64-backend struct-small-enough? ( size -- ? ) 2 cells <= ;

M: amd64-backend %box-small-struct ( size -- )
    #! Box a <= 16-byte struct returned in RAX:RDX.
    RDI RAX MOV
    RSI RDX MOV
    RDX swap MOV
    "box_small_struct" f compile-c-call ;

M: amd64-backend %box-large-struct ( n size -- )
    ! Struct size is parameter 2
    RSI over MOV
    ! Compute destination address
    swap struct-return@ RDI RSP rot [+] LEA
    ! Copy the struct from the C stack
    "box_value_struct" f compile-c-call ;

M: amd64-backend %prepare-box-struct ( size -- )
    ! Compute target address for value struct return
    RAX RSP rot f struct-return@ [+] LEA
    RSP 0 [+] RAX MOV ;

: reset-sse RAX RAX XOR ;

M: amd64-backend %alien-invoke ( symbol dll -- )
    reset-sse compile-c-call ;

M: amd64-backend %prepare-alien-indirect ( -- )
    "unbox_alien" f compile-c-call
    cell temp@ RAX MOV ;

M: amd64-backend %alien-indirect ( -- )
    reset-sse
    cell temp@ CALL ;

M: amd64-backend %alien-callback ( quot -- )
    RDI load-indirect "c_to_factor" f compile-c-call ;

M: amd64-backend %callback-value ( ctype -- )
    ! Save top of data stack
    %prepare-unbox
    ! Put former top of data stack in RDI
    cell temp@ RDI MOV
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Put former top of data stack in RDI
    RDI cell temp@ MOV
    ! Unbox former top of data stack to return registers
    unbox-return ;

M: amd64-backend %cleanup ( alien-node -- ) drop ;

M: amd64-backend %unwind ( n -- ) drop %epilogue-later 0 RET ;

USE: cpu.x86.intrinsics

! On 64-bit systems, the result of reading 4 bytes from memory
! is a fixnum.
\ alien-unsigned-4 small-reg-32 define-unsigned-getter
\ set-alien-unsigned-4 small-reg-32 define-setter

\ alien-signed-4 small-reg-32 define-signed-getter
\ set-alien-signed-4 small-reg-32 define-setter

T{ x86-backend f 8 } compiler-backend set-global

! The ABI for passing structs by value is pretty messed up
"void*" c-type clone "__stack_value" define-primitive-type
T{ stack-regs } "__stack_value" c-type set-c-type-reg-class

: struct-types&offset ( ctype -- pairs )
    c-type struct-type-fields [
        dup slot-spec-type swap slot-spec-offset 2array
    ] map ;

: split-struct ( pairs -- seq )
    [
        [ first2 8 mod zero? [ t , ] when , ] each
    ] { } make { t } split [ empty? not ] subset ;

: flatten-large-struct ( type -- )
    heap-size cell align
    cell /i "__stack_value" <repetition> % ;

M: struct-type flatten-value-type ( type -- seq )
    dup c-size 16 > [
        flatten-large-struct
    ] [
        struct-types&offset split-struct [
            [ c-type c-type-reg-class ] map
            T{ int-regs } swap member? "void*" "double" ? ,
        ] each
    ] if ;
