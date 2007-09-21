! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types arrays cpu.x86.assembler
cpu.x86.architecture cpu.x86.intrinsics cpu.x86.allot
cpu.architecture kernel kernel.private math namespaces sequences
generator.registers generator.fixup generator system
math.functions alien.compiler combinators command-line
compiler io vocabs.loader ;
IN: cpu.x86.32

! We implement the FFI for Linux, OS X and Windows all at once.
! OS X requires that the stack be 16-byte aligned, and we do
! this on all platforms, sacrificing some stack space for
! code simplicity.

M: x86-backend ds-reg ESI ;
M: x86-backend rs-reg EDI ;
M: x86-backend stack-reg ESP ;
M: x86-backend xt-reg ECX ;
M: x86-backend stack-save-reg EDX ;

M: temp-reg v>operand drop EBX ;

M: x86-backend %alien-invoke ( symbol dll -- )
    (CALL) rel-dlsym ;

! On x86, parameters are never passed in registers.
M: int-regs return-reg drop EAX ;
M: int-regs param-regs drop { } ;
M: int-regs vregs drop { EAX ECX EDX EBP } ;
M: int-regs push-return-reg return-reg PUSH ;
: load/store-int-return return-reg stack-reg rot [+] ;
M: int-regs load-return-reg load/store-int-return MOV ;
M: int-regs store-return-reg load/store-int-return swap MOV ;

M: float-regs param-regs drop { } ;
M: float-regs vregs drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;

: FSTP 4 = [ FSTPS ] [ FSTPL ] if ;

M: float-regs push-return-reg
    stack-reg swap reg-size [ SUB  stack-reg [] ] keep FSTP ;

: FLD 4 = [ FLDS ] [ FLDL ] if ;

: load/store-float-return reg-size >r stack-reg swap [+] r> ;
M: float-regs load-return-reg load/store-float-return FLD ;
M: float-regs store-return-reg load/store-float-return FSTP ;

: align-sub ( n -- )
    dup 16 align swap - ESP swap SUB ;

: align-add ( n -- )
    16 align ESP swap ADD ;

: with-aligned-stack ( n quot -- )
    swap dup align-sub slip align-add ; inline

! On x86, we can always use an address as an operand
! directly.
M: x86-backend address-operand ;

M: x86-backend fixnum>slot@ 1 SHR ;

M: x86-backend prepare-division CDQ ;

M: x86-backend load-indirect
    0 [] MOV rc-absolute-cell rel-literal ;

M: object %load-param-reg 3drop ;

M: object %save-param-reg 3drop ;

M: x86-backend %prepare-unbox ( -- )
    #! Move top of data stack to EAX.
    EAX ESI [] MOV
    ESI 4 SUB ;

: (%unbox) ( func -- )
    4 [
        ! Push parameter
        EAX PUSH
        ! Call the unboxer
        f %alien-invoke
    ] with-aligned-stack ;

M: x86-backend %unbox ( n reg-class func -- )
    #! The value being unboxed must already be in EAX.
    #! If n is f, we're unboxing a return value about to be
    #! returned by the callback. Otherwise, we're unboxing
    #! a parameter to a C function about to be called.
    (%unbox)
    ! Store the return value on the C stack
    over [ store-return-reg ] [ 2drop ] if ;

M: x86-backend %unbox-long-long ( n func -- )
    (%unbox)
    ! Store the return value on the C stack
    [
        dup stack@ EAX MOV
        cell + stack@ EDX MOV
    ] when* ;

M: x86-backend %unbox-struct-2
    #! Alien must be in EAX.
    4 [
        EAX PUSH
        "alien_offset" f %alien-invoke
        ! Load second cell
        EDX EAX 4 [+] MOV
        ! Load first cell
        EAX EAX [] MOV
    ] with-aligned-stack ;

M: x86-backend %unbox-large-struct ( n size -- )
    #! Alien must be in EAX.
    ! Compute destination address
    ECX ESP roll [+] LEA
    12 [
        ! Push struct size
        PUSH
        ! Push destination address
        ECX PUSH
        ! Push source address
        EAX PUSH
        ! Copy the struct to the stack
        "to_value_struct" f %alien-invoke
    ] with-aligned-stack ;

: box@ ( n reg-class -- stack@ )
    #! Used for callbacks; we want to box the values given to
    #! us by the C function caller. Computes stack location of
    #! nth parameter; note that we must go back one more stack
    #! frame, since %box sets one up to call the one-arg boxer
    #! function. The size of this stack frame so far depends on
    #! the reg-class of the boxer's arg.
    reg-size neg + stack-frame* + 20 + ;

: (%box) ( n reg-class -- )
    #! If n is f, push the return register onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n] on the stack; we are boxing a
    #! parameter being passed to a callback from C.
    over [ [ box@ ] keep [ load-return-reg ] keep ] [ nip ] if
    push-return-reg ;

M: x86-backend %box ( n reg-class func -- )
    over reg-size [
        >r (%box) r> f %alien-invoke
    ] with-aligned-stack ;
    
: (%box-long-long)
    #! If n is f, push the return registers onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n]:[ESP+n+4] on the stack; we are
    #! boxing a parameter being passed to a callback from C.
    [
        T{ int-regs } box@
        EDX over stack@ MOV
        EAX swap cell - stack@ MOV 
    ] when*
    EDX PUSH
    EAX PUSH ;

M: x86-backend %box-long-long ( n func -- )
    8 [
        >r (%box-long-long) r> f %alien-invoke
    ] with-aligned-stack ;

M: x86-backend %box-large-struct ( n size -- )
    ! Compute destination address
    [ swap struct-return@ ] keep
    ECX ESP roll [+] LEA
    8 [
        ! Push struct size
        PUSH
        ! Push destination address
        ECX PUSH
        ! Copy the struct from the C stack
        "box_value_struct" f %alien-invoke
    ] with-aligned-stack ;

M: x86-backend %prepare-box-struct ( size -- )
    ! Compute target address for value struct return
    EAX ESP rot f struct-return@ [+] LEA
    ! Store it as the first parameter
    ESP [] EAX MOV ;

M: x86-backend %unbox-struct-1
    #! Alien must be in EAX.
    4 [
        EAX PUSH
        "alien_offset" f %alien-invoke
        ! Load first cell
        EAX EAX [] MOV
    ] with-aligned-stack ;

M: x86-backend %box-small-struct ( size -- )
    #! Box a <= 8-byte struct returned in EAX:DX. OS X only.
    12 [
        PUSH
        EDX PUSH
        EAX PUSH
        "box_small_struct" f %alien-invoke
    ] with-aligned-stack ;

M: x86-backend %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    ESP cell temp@ [+] EAX MOV ;

M: x86-backend %alien-indirect ( -- )
    ESP cell temp@ [+] CALL ;

M: x86-backend %alien-callback ( quot -- )
    4 [
        EAX load-indirect
        EAX PUSH
        "c_to_factor" f %alien-invoke
    ] with-aligned-stack ;

M: x86-backend %callback-value ( ctype -- )
    ! Align C stack
    ESP 12 SUB
    ! Save top of data stack
    %prepare-unbox
    EAX PUSH
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Place top of data stack in EAX
    EAX POP
    ! Restore C stack
    ESP 12 ADD
    ! Unbox EAX
    unbox-return ;

M: x86-backend %cleanup ( alien-node -- )
    #! a) If we just called an stdcall function in Windows, it
    #! cleaned up the stack frame for us. But we don't want that
    #! so we 'undo' the cleanup since we do that in %epilogue.
    #! b) If we just called a function returning a struct, we
    #! have to fix ESP.
    {
        {
            [ dup alien-node-abi "stdcall" = ]
            [ alien-stack-frame ESP swap SUB ]
        } {
            [ dup alien-node-return large-struct? ]
            [ drop EAX PUSH ]
        } {
            [ t ] [ drop ]
        }
    } cond ;

M: x86-backend %unwind ( n -- ) %epilogue-later RET ;

windows? [
    cell "longlong" c-type set-c-type-align
    cell "ulonglong" c-type set-c-type-align
] unless

T{ x86-backend f 4 } compiler-backend set-global

: sse2? "Intrinsic" throw ;

\ sse2? [
    { EAX EBX ECX EDX } [ PUSH ] each
    EAX 1 MOV
    CPUID
    EDX 26 SHR
    EDX 1 AND
    { EAX EBX ECX EDX } [ POP ] each
    JNE
] { } define-if-intrinsic

"-no-sse2" cli-args member? [
    "Checking if your CPU supports SSE2..." print flush
    [ sse2? ] compile-1 [
        " - yes" print
        "cpu.x86.sse2" require
    ] [
        " - no" print
    ] if
] unless
