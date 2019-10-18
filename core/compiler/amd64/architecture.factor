! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: generator
USING: alien arrays assembler-x86 generic kernel
kernel-internals math namespaces sequences ;

! AMD64 register assignments
! RAX RCX RDX RSI RDI R8 R9 R10 integer vregs
! XMM0 - XMM7 float vregs
! R14 data stack
! R15 retain stack

: ds-reg R14 ; inline
: rs-reg R15 ; inline
: allot-tmp-reg RBX ; inline
: stack-reg RSP ; inline

M: int-regs return-reg drop RAX ;
M: int-regs vregs drop { RAX RCX RDX RSI RDI R8 R9 R10 R11 } ;
M: int-regs param-regs drop { RDI RSI RDX RCX R8 R9 } ;

M: float-regs return-reg drop XMM0 ;
M: float-regs vregs drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;
M: float-regs param-regs vregs ;

: address-operand ( address -- operand )
    #! On AMD64, we have to load 64-bit addresses into a
    #! scratch register first. The usage of R11 here is a hack.
    #! This word can only be called right before a subroutine
    #! call, where all vregs have been flushed anyway.
    R11 [ swap MOV ] keep ; inline

: compile-c-call ( symbol dll -- )
    0 address-operand >r rc-absolute-cell rel-dlsym r> CALL ;

: fixnum>slot@ drop ; inline

: prepare-division CQO ; inline

: load-indirect ( literal vreg -- )
    0 [] MOV rc-relative rel-literal ;

M: stack-params %load-param-reg
    drop >r R11 swap stack@ MOV r> stack@ R11 MOV ;

M: stack-params %save-param-reg
    >r stack-increment + cell + swap r> %load-param-reg ;

: %unbox-struct-1 ( -- )
    #! Alien must be in RDI.
    "alien_offset" f compile-c-call
    ! Load first cell
    RAX RAX [] MOV ;

: %unbox-struct-2 ( -- )
    #! Alien must be in RDI.
    "alien_offset" f compile-c-call
    ! Load second cell
    RDX RAX cell [+] MOV
    ! Load first cell
    RAX RAX [] MOV ;

: %unbox-large-struct ( n size -- )
    ! Source is in RDI
    ! Load destination address
    RSI RSP roll [+] LEA
    ! Load structure size
    RDX swap MOV
    ! Copy the struct to the C stack
    "to_value_struct" f compile-c-call ;

: %prepare-unbox ( -- )
    ! First parameter is top of stack
    RDI R14 [] MOV
    R14 cell SUB ;

: %unbox ( n reg-class func -- )
    ! Call the unboxer
    f compile-c-call
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

: struct-small-enough? ( size -- ? ) 2 cells <= ;

: %box-struct-1 ( -- )
    #! Box a 8-byte struct returned in RAX.
    RDI RAX MOV
    "box_struct_1" f compile-c-call ;

: %box-struct-2 ( -- )
    #! Box a 16-byte struct returned in RAX:RDX.
    RDI RAX MOV
    RSI RDX MOV
    "box_struct_2" f compile-c-call ;

: %box-large-struct ( n size -- )
    ! Struct size is parameter 2
    RSI over MOV
    ! Compute destination address
    swap struct-return@ RDI RSP rot [+] LEA
    ! Copy the struct from the C stack
    "box_value_struct" f compile-c-call ;

: %prepare-box-struct ( size -- )
    ! Compute target address for value struct return
    RAX RSP rot f struct-return@ [+] LEA
    RSP 0 [+] RAX MOV ;

: load-return-value ( reg-class -- )
    0 over param-reg swap return-reg
    2dup eq? [ 2drop ] [ MOV ] if ;

: %box ( n reg-class func -- )
    rot [
        rot [ 0 swap param-reg ] keep %load-param-reg
    ] [
        swap load-return-value
    ] if*
    f compile-c-call ;

: reset-sse RAX RAX XOR ;

: %alien-invoke ( symbol dll -- )
    reset-sse compile-c-call ;

: %prepare-alien-indirect ( -- )
    "unbox_alien" f compile-c-call
    RSP stack-increment cell - [+] RAX MOV ;

: %alien-indirect ( -- )
    reset-sse RSP stack-increment cell - [+] CALL ;

: %alien-callback ( quot -- )
    RDI load-indirect "run_callback" f compile-c-call ;

: %callback-value ( ctype -- )
    ! Save top of data stack
    %prepare-unbox
    ! Put former top of data stack in RDI
    RSP stack-increment cell - [+] RDI MOV
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Put former top of data stack in RDI
    RDI RSP stack-increment cell - [+] MOV
    ! Unbox former top of data stack to return registers
    unbox-return ;

: %cleanup ( alien-node -- ) drop ;

: %unwind ( n -- ) drop %return ;
