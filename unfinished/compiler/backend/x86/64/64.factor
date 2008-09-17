! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays kernel kernel.private math
namespaces make sequences system layouts alien alien.accessors
alien.structs slots splitting assocs combinators
cpu.x86 compiler.codegen compiler.constants
compiler.codegen.fixup compiler.cfg.registers compiler.backend
compiler.backend.x86 compiler.backend.x86.sse2 ;
IN: compiler.backend.x86.64

M: x86.64 machine-registers
    {
        { int-regs { RAX RCX RDX RBP RSI RDI R8 R9 R10 R11 R12 R13 } }
        { double-float-regs {
            XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7
            XMM8 XMM9 XMM10 XMM11 XMM12 XMM13 XMM14 XMM15
        } }
    } ;

M: x86.64 ds-reg R14 ;
M: x86.64 rs-reg R15 ;
M: x86.64 stack-reg RSP ;
M: x86.64 stack-save-reg RSI ;
M: x86.64 temp-reg-1 RAX ;
M: x86.64 temp-reg-2 RCX ;

M: int-regs return-reg drop RAX ;
M: int-regs param-regs drop { RDI RSI RDX RCX R8 R9 } ;

M: float-regs return-reg drop XMM0 ;

M: float-regs param-regs
    drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;

M: x86.64 fixnum>slot@ drop ;

M: x86.64 prepare-division CQO ;

M: x86.64 load-indirect ( literal reg -- )
    0 [] MOV rc-relative rel-literal ;

M: stack-params %load-param-reg
    drop
    >r R11 swap stack@ MOV
    r> stack@ R11 MOV ;

M: stack-params %save-param-reg
    >r stack-frame* + cell + swap r> %load-param-reg ;

: with-return-regs ( quot -- )
    [
        V{ RDX RAX } clone int-regs set
        V{ XMM1 XMM0 } clone float-regs set
        call
    ] with-scope ; inline

! The ABI for passing structs by value is pretty messed up
<< "void*" c-type clone "__stack_value" define-primitive-type
stack-params "__stack_value" c-type (>>reg-class) >>

: struct-types&offset ( struct-type -- pairs )
    fields>> [
        [ type>> ] [ offset>> ] bi 2array
    ] map ;

: split-struct ( pairs -- seq )
    [
        [ 8 mod zero? [ t , ] when , ] assoc-each
    ] { } make { t } split harvest ;

: flatten-small-struct ( c-type -- seq )
    struct-types&offset split-struct [
        [ c-type c-type-reg-class ] map
        int-regs swap member? "void*" "double" ? c-type
    ] map ;

: flatten-large-struct ( c-type -- seq )
    heap-size cell align
    cell /i "__stack_value" c-type <repetition> ;

M: struct-type flatten-value-type ( type -- seq )
    dup heap-size 16 > [
        flatten-large-struct
    ] [
        flatten-small-struct
    ] if ;

M: x86.64 %prepare-unbox ( -- )
    ! First parameter is top of stack
    RDI R14 [] MOV
    R14 cell SUB ;

M: x86.64 %unbox ( n reg-class func -- )
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: x86.64 %unbox-long-long ( n func -- )
    int-regs swap %unbox ;

: %unbox-struct-field ( c-type i -- )
    ! Alien must be in RDI.
    RDI swap cells [+] swap reg-class>> {
        { int-regs [ int-regs get pop swap MOV ] }
        { double-float-regs [ float-regs get pop swap MOVSD ] }
    } case ;

M: x86.64 %unbox-small-struct ( c-type -- )
    ! Alien must be in RDI.
    "alien_offset" f %alien-invoke
    ! Move alien_offset() return value to RDI so that we don't
    ! clobber it.
    RDI RAX MOV
    [
        flatten-small-struct [ %unbox-struct-field ] each-index
    ] with-return-regs ;

M: x86.64 %unbox-large-struct ( n c-type -- )
    ! Source is in RDI
    heap-size
    ! Load destination address
    RSI RSP roll [+] LEA
    ! Load structure size
    RDX swap MOV
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

M: x86.64 struct-small-enough? ( size -- ? )
    heap-size 2 cells <= ;

: box-struct-field@ ( i -- operand ) RSP swap 1+ cells [+] ;

: %box-struct-field ( c-type i -- )
    box-struct-field@ swap reg-class>> {
        { int-regs [ int-regs get pop MOV ] }
        { double-float-regs [ float-regs get pop MOVSD ] }
    } case ;

M: x86.64 %box-small-struct ( c-type -- )
    #! Box a <= 16-byte struct.
    [
        [ flatten-small-struct [ %box-struct-field ] each-index ]
        [ RDX swap heap-size MOV ] bi
        RDI 0 box-struct-field@ MOV
        RSI 1 box-struct-field@ MOV
        "box_small_struct" f %alien-invoke
    ] with-return-regs ;

: struct-return@ ( size n -- n )
    [ ] [ \ stack-frame get swap - ] ?if ;

M: x86.64 %box-large-struct ( n c-type -- )
    ! Struct size is parameter 2
    heap-size
    RSI over MOV
    ! Compute destination address
    swap struct-return@ RDI RSP rot [+] LEA
    ! Copy the struct from the C stack
    "box_value_struct" f %alien-invoke ;

M: x86.64 %prepare-box-struct ( size -- )
    ! Compute target address for value struct return
    RAX RSP rot f struct-return@ [+] LEA
    RSP 0 [+] RAX MOV ;

M: x86.64 %prepare-var-args RAX RAX XOR ;

M: x86.64 %alien-global
    [ 0 MOV rc-absolute-cell rel-dlsym ] [ dup [] MOV ] bi ;

M: x86.64 %alien-invoke
    R11 0 MOV
    rc-absolute-cell rel-dlsym
    R11 CALL ;

M: x86.64 %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    cell temp@ RAX MOV ;

M: x86.64 %alien-indirect ( -- )
    cell temp@ CALL ;

M: x86.64 %alien-callback ( quot -- )
    RDI load-indirect "c_to_factor" f %alien-invoke ;

M: x86.64 %callback-value ( ctype -- )
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

M: x86.64 %cleanup ( alien-node -- ) drop ;

M: x86.64 %unwind ( n -- ) drop 0 RET ;

USE: cpu.x86.intrinsics

! On 64-bit systems, the result of reading 4 bytes from memory
! is a fixnum.
\ alien-unsigned-4 small-reg-32 define-unsigned-getter
\ set-alien-unsigned-4 small-reg-32 define-setter

\ alien-signed-4 small-reg-32 define-signed-getter
\ set-alien-signed-4 small-reg-32 define-setter
