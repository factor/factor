! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien arrays assembler-x86 compiler generic kernel
kernel-internals math memory namespaces sequences words ;
IN: generator

! We implement the FFI for Linux, OS X and Windows all at once.
! OS X requires that the stack be 16-byte aligned, and we do
! this on all platforms, sacrificing some stack space for
! code simplicity.

: code-format 1 ; inline

! x86 register assignments
! EAX, ECX, EDX, EBX, EBP integer vregs
! XMM0 - XMM7 float vregs
! ESI data stack
! EDI retain stack

! AMD64 redefines a lot of words in this file

: ds-reg ESI ; inline
: rs-reg EDI ; inline
: allot-tmp-reg EDI ; inline
: stack-reg ESP ; inline
: stack@ stack-reg swap [+] ;

: reg-stack ( n reg -- op ) swap cells neg [+] ;

M: ds-loc v>operand ds-loc-n ds-reg reg-stack ;
M: rs-loc v>operand rs-loc-n rs-reg reg-stack ;

: %alien-invoke ( symbol dll -- ) (CALL) rel-dlsym ;

GENERIC: push-return-reg ( reg-class -- )
GENERIC: load-return-reg ( stack@ reg-class -- )
GENERIC: store-return-reg ( stack@ reg-class -- )

! On x86, parameters are never passed in registers.
M: int-regs return-reg drop EAX ;
M: int-regs param-regs drop { } ;
M: int-regs vregs drop { EAX ECX EDX EBX EBP } ;
M: int-regs %save-param-reg drop >r stack@ r> MOV ;
M: int-regs %load-param-reg drop swap stack@ MOV ;
M: int-regs push-return-reg return-reg PUSH ;
: load/store-int-return return-reg stack-reg rot [+] ;
M: int-regs load-return-reg load/store-int-return MOV ;
M: int-regs store-return-reg load/store-int-return swap MOV ;

: MOVSS/D float-regs-size 4 = [ MOVSS ] [ MOVSD ] if ;

M: float-regs param-regs drop { } ;
M: float-regs vregs drop { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } ;
M: float-regs %save-param-reg >r >r stack@ r> r> MOVSS/D ;
M: float-regs %load-param-reg >r swap stack@ r> MOVSS/D ;

: FSTP 4 = [ FSTPS ] [ FSTPL ] if ;

M: float-regs push-return-reg
    stack-reg swap reg-size [ SUB  stack-reg [] ] keep FSTP ;

: FLD 4 = [ FLDS ] [ FLDL ] if ;

: load/store-float-return reg-size >r stack-reg swap [+] r> ;
M: float-regs load-return-reg load/store-float-return FLD ;
M: float-regs store-return-reg load/store-float-return FSTP ;

: address-operand ( address -- operand )
    #! On x86, we can always use an address as an operand
    #! directly.
    ; inline

: fixnum>slot@ 1 SHR ; inline

: prepare-division CDQ ; inline

M: immediate load-literal
    v>operand swap v>operand MOV ;

: load-indirect ( literal reg -- )
    0 [] MOV rc-absolute-cell rel-literal ;

M: object load-literal
    v>operand load-indirect ;

: stack-increment \ stack-frame-size get 16 align 16 + cell - ;

: %prologue ( -- )
    [ stack-reg stack-increment SUB ] if-stack-frame ;

: %epilogue ( -- )
    [ stack-reg stack-increment ADD ] if-stack-frame ;

: (%call) ( label -- label )
    dup (compile) dup primitive? [ address-operand ] when ;

: %call ( label -- ) (%call) CALL ;

: %jump ( label -- ) %epilogue (%call) JMP ;

: %jump-label ( label -- ) JMP ;

: %jump-t ( label -- ) "flag" operand f v>operand CMP JNE ;

: (%dispatch) ( word-table# -- )
    ! Untag and multiply to get a jump table offset
    "n" operand fixnum>slot@
    ! Add to jump table base. We use a temporary register
    ! since on AMD64 we have to load a 64-bit immediate. On
    ! x86, this is redundant.
    "scratch" operand HEX: ffffffff MOV rc-absolute-cell rel-dispatch
    "n" operand "scratch" operand ADD ;

: dispatch-template ( word-table# quot -- )
    [
        >r (%dispatch) "n" operand [] r> call
    ] H{
        { +input+ { { f "n" } } }
        { +scratch+ { { f "scratch" } } }
    } with-template ; inline

: %call-dispatch ( word-table# -- )
    [ CALL ] dispatch-template ;

: %jump-dispatch ( word-table# -- )
    [ %epilogue JMP ] dispatch-template ;

: %return ( -- ) %epilogue 0 RET ;

: %move-int>int ( dst src -- )
    [ v>operand ] 2apply MOV ;

: %move-int>float ( dst src -- )
    [ v>operand ] 2apply float-offset [+] MOVSD ;

M: int-regs (%peek) drop %move-int>int ;

M: int-regs (%replace) drop swap %move-int>int ;

: (%inc) swap cells dup 0 > [ ADD ] [ neg SUB ] if ;

: %inc-d ( n -- ) ds-reg (%inc) ;

: %inc-r ( n -- ) rs-reg (%inc) ;

M: object %load-param-reg 3drop ;

M: object %save-param-reg 3drop ;

: value-structs? t ;

: small-enough? ( n -- ? )
    HEX: -80000000 HEX: 7fffffff between? ;

: align-sub ( n -- )
    dup 16 align swap - ESP swap SUB ;

: align-add ( n -- )
    16 align ESP swap ADD ;

: with-aligned-stack ( n quot -- )
    swap dup align-sub slip align-add ; inline

: %prepare-unbox ( -- )
    #! Move top of data stack to EAX.
    EAX ESI [] MOV
    ESI 4 SUB ;

: %unbox-struct-1 ( -- )
    #! Alien must be in EAX.
    4 [
        EAX PUSH
        "alien_offset" f %alien-invoke
        ! Load first cell
        EAX EAX [] MOV
    ] with-aligned-stack ;

: %unbox-struct-2 ( -- )
    #! Alien must be in EAX.
    4 [
        EAX PUSH
        "alien_offset" f %alien-invoke
        ! Load second cell
        EDX EAX 4 [+] MOV
        ! Load first cell
        EAX EAX [] MOV
    ] with-aligned-stack ;

: %unbox-small-struct ( size -- )
    #! Alien must be in EAX.
    cell align cell / {
        { 1 [ %unbox-struct-1 ] }
        { 2 [ %unbox-struct-2 ] }
    } case ;

: %unbox-large-struct ( n size -- )
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

: struct-small-enough? ( size -- ? )
    8 <= os "linux" = not and ;

: %unbox ( n reg-class func -- )
    #! The value being unboxed must already be in EAX.
    #! If n is f, we're unboxing a return value about to be
    #! returned by the callback. Otherwise, we're unboxing
    #! a parameter to a C function about to be called.
    4 [
        ! Push parameter
        EAX PUSH
        ! Call the unboxer
        f %alien-invoke
    ] with-aligned-stack
    ! Store the return value on the C stack
    over [ store-return-reg ] [ 2drop ] if ;

: %box-struct-1 ( -- )
    #! Box a 4-byte struct returned in EAX. OS X only.
    4 [
        EAX PUSH
        "box_struct_1" f %alien-invoke
    ] with-aligned-stack ;

: %box-struct-2 ( -- )
    #! Box an 8-byte struct returned in EAX:EDX. OS X only.
    8 [
        EDX PUSH
        EAX PUSH
        "box_struct_2" f %alien-invoke
    ] with-aligned-stack ;

: %box-small-struct ( size -- )
    cell align cell / {
        { 1 [ %box-struct-1 ] }
        { 2 [ %box-struct-2 ] }
    } case ;

: struct-return@ ( size n -- n )
    [
        stack-increment cell + +
    ] [
        stack-increment swap -
    ] ?if ;

: %box-large-struct ( n size -- )
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

: %prepare-box-struct ( size -- )
    ! Compute target address for value struct return
    EAX ESP rot f struct-return@ [+] LEA
    ! Store it as the first parameter
    ESP [] EAX MOV ;

: box@ ( n reg-class -- stack@ )
    #! Used for callbacks; we want to box the values given to
    #! us by the C function caller. Computes stack location of
    #! nth parameter; note that we must go back one more stack
    #! frame, since %box sets one up to call the one-arg boxer
    #! function. The size of this stack frame so far depends on
    #! the reg-class of the boxer's arg.
    reg-size neg + stack-increment + 20 + ;

: (%box) ( n reg-class -- )
    #! If n is f, push the return register onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n] on the stack; we are boxing a
    #! parameter being passed to a callback from C.
    over [ [ box@ ] keep [ load-return-reg ] keep ] [ nip ] if
    push-return-reg ;

: %box ( n reg-class func -- )
    over reg-size [
        >r (%box) r> f %alien-invoke
    ] with-aligned-stack ;

: %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    ESP stack-increment cell - [+] EAX MOV ;

: %alien-indirect ( -- )
    ESP stack-increment cell - [+] CALL ;

: %alien-callback ( quot -- )
    4 [
        EAX load-indirect
        EAX PUSH
        "run_callback" f %alien-invoke
    ] with-aligned-stack ;

: %callback-value ( ctype -- )
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

: %unwind ( n -- ) %epilogue RET ;

: %cleanup ( alien-node -- )
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
