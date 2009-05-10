! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals alien.c-types alien.syntax arrays kernel
math namespaces sequences system layouts io vocabs.loader
accessors init combinators command-line cpu.x86.assembler
cpu.x86 cpu.architecture compiler compiler.units
compiler.constants compiler.alien compiler.codegen
compiler.codegen.fixup compiler.cfg.instructions
compiler.cfg.builder compiler.cfg.intrinsics make ;
IN: cpu.x86.32

! We implement the FFI for Linux, OS X and Windows all at once.
! OS X requires that the stack be 16-byte aligned, and we do
! this on all platforms, sacrificing some stack space for
! code simplicity.

M: x86.32 machine-registers
    {
        { int-regs { EAX ECX EDX EBP EBX } }
        { double-float-regs { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } }
    } ;

M: x86.32 ds-reg ESI ;
M: x86.32 rs-reg EDI ;
M: x86.32 stack-reg ESP ;
M: x86.32 temp-reg-1 ECX ;
M: x86.32 temp-reg-2 EDX ;

M:: x86.32 %dispatch ( src temp offset -- )
    ! Load jump table base.
    src HEX: ffffffff ADD
    offset cells rc-absolute-cell rel-here
    ! Go
    src HEX: 7f [+] JMP
    ! Fix up the displacement above
    cell code-alignment
    [ 7 + building get dup pop* push ]
    [ align-code ]
    bi ;

! Registers for fastcall
M: x86.32 param-reg-1 EAX ;
M: x86.32 param-reg-2 EDX ;

M: x86.32 pic-tail-reg EBX ;

M: x86.32 reserved-area-size 0 ;

M: x86.32 %alien-invoke 0 CALL rc-relative rel-dlsym ;

M: x86.32 %alien-invoke-tail 0 JMP rc-relative rel-dlsym ;

M: x86.32 return-struct-in-registers? ( c-type -- ? )
    c-type
    [ return-in-registers?>> ]
    [ heap-size { 1 2 4 8 } member? ] bi
    os { linux netbsd solaris } member? not
    and or ;

: struct-return@ ( n -- operand )
    [ next-stack@ ] [ stack-frame get params>> stack@ ] if* ;

! On x86, parameters are never passed in registers.
M: int-regs return-reg drop EAX ;
M: int-regs param-regs drop { } ;
M: int-regs push-return-reg return-reg PUSH ;

M: int-regs load-return-reg
    return-reg swap next-stack@ MOV ;

M: int-regs store-return-reg
    [ stack@ ] [ return-reg ] bi* MOV ;

M: float-regs param-regs drop { } ;

: FSTP ( operand size -- ) 4 = [ FSTPS ] [ FSTPL ] if ;

M: float-regs push-return-reg
    stack-reg swap reg-size
    [ SUB ] [ [ [] ] dip FSTP ] 2bi ;

: FLD ( operand size -- ) 4 = [ FLDS ] [ FLDL ] if ;

M: float-regs load-return-reg
    [ next-stack@ ] [ reg-size ] bi* FLD ;

M: float-regs store-return-reg
    [ stack@ ] [ reg-size ] bi* FSTP ;

: align-sub ( n -- )
    [ align-stack ] keep - decr-stack-reg ;

: align-add ( n -- )
    align-stack incr-stack-reg ;

: with-aligned-stack ( n quot -- )
    [ [ align-sub ] [ call ] bi* ]
    [ [ align-add ] [ drop ] bi* ] 2bi ; inline

M: x86.32 %prologue ( n -- )
    dup PUSH
    0 PUSH rc-absolute-cell rel-this
    stack-reg swap 3 cells - SUB ;

M: object %load-param-reg 3drop ;

M: object %save-param-reg 3drop ;

: (%box) ( n reg-class -- )
    #! If n is f, push the return register onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n] on the stack; we are boxing a
    #! parameter being passed to a callback from C.
    over [ load-return-reg ] [ 2drop ] if ;

M:: x86.32 %box ( n reg-class func -- )
    n reg-class (%box)
    reg-class reg-size [
        reg-class push-return-reg
        func f %alien-invoke
    ] with-aligned-stack ;
    
: (%box-long-long) ( n -- )
    [
        EDX over next-stack@ MOV
        EAX swap cell - next-stack@ MOV 
    ] when* ;

M: x86.32 %box-long-long ( n func -- )
    [ (%box-long-long) ] dip
    8 [
        EDX PUSH
        EAX PUSH
        f %alien-invoke
    ] with-aligned-stack ;

M:: x86.32 %box-large-struct ( n c-type -- )
    ! Compute destination address
    ECX n struct-return@ LEA
    8 [
        ! Push struct size
        c-type heap-size PUSH
        ! Push destination address
        ECX PUSH
        ! Copy the struct from the C stack
        "box_value_struct" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %prepare-box-struct ( -- )
    ! Compute target address for value struct return
    EAX f struct-return@ LEA
    ! Store it as the first parameter
    0 stack@ EAX MOV ;

M: x86.32 %box-small-struct ( c-type -- )
    #! Box a <= 8-byte struct returned in EAX:EDX. OS X only.
    12 [
        heap-size PUSH
        EDX PUSH
        EAX PUSH
        "box_small_struct" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %prepare-unbox ( -- )
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

M: x86.32 %unbox ( n reg-class func -- )
    #! The value being unboxed must already be in EAX.
    #! If n is f, we're unboxing a return value about to be
    #! returned by the callback. Otherwise, we're unboxing
    #! a parameter to a C function about to be called.
    (%unbox)
    ! Store the return value on the C stack
    over [ store-return-reg ] [ 2drop ] if ;

M: x86.32 %unbox-long-long ( n func -- )
    (%unbox)
    ! Store the return value on the C stack
    [
        dup stack@ EAX MOV
        cell + stack@ EDX MOV
    ] when* ;

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

M: x86 %unbox-small-struct ( size -- )
    #! Alien must be in EAX.
    heap-size cell align cell /i {
        { 1 [ %unbox-struct-1 ] }
        { 2 [ %unbox-struct-2 ] }
    } case ;

M: x86.32 %unbox-large-struct ( n c-type -- )
    ! Alien must be in EAX.
    ! Compute destination address
    ECX rot stack@ LEA
    12 [
        ! Push struct size
        heap-size PUSH
        ! Push destination address
        ECX PUSH
        ! Push source address
        EAX PUSH
        ! Copy the struct to the stack
        "to_value_struct" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    EBP EAX MOV ;

M: x86.32 %alien-indirect ( -- )
    EBP CALL ;

M: x86.32 %alien-callback ( quot -- )
    4 [
        EAX swap %load-reference
        EAX PUSH
        "c_to_factor" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %callback-value ( ctype -- )
    ! Align C stack
    ESP 12 SUB
    ! Save top of data stack in non-volatile register
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

M: x86.32 %cleanup ( params -- )
    #! a) If we just called an stdcall function in Windows, it
    #! cleaned up the stack frame for us. But we don't want that
    #! so we 'undo' the cleanup since we do that in %epilogue.
    #! b) If we just called a function returning a struct, we
    #! have to fix ESP.
    {
        {
            [ dup abi>> "stdcall" = ]
            [ drop ESP stack-frame get params>> SUB ]
        } {
            [ dup return>> large-struct? ]
            [ drop EAX PUSH ]
        }
        [ drop ]
    } cond ;

M: x86.32 %callback-return ( n -- )
    #! a) If the callback is stdcall, we have to clean up the
    #! caller's stack frame.
    #! b) If the callback is returning a large struct, we have
    #! to fix ESP.
    {
        { [ dup abi>> "stdcall" = ] [
            <alien-stack-frame>
            [ params>> ] [ return>> ] bi +
        ] }
        { [ dup return>> large-struct? ] [ drop 4 ] }
        [ drop 0 ]
    } cond RET ;

M: x86.32 dummy-stack-params? f ;

M: x86.32 dummy-int-params? f ;

M: x86.32 dummy-fp-params? f ;

os windows? [
    cell "longlong" c-type (>>align)
    cell "ulonglong" c-type (>>align)
    4 "double" c-type (>>align)
] unless

FUNCTION: bool check_sse2 ( ) ;

: sse2? ( -- ? )
    check_sse2 ;

"-no-sse2" (command-line) member? [
    [ { check_sse2 } compile ] with-optimizer

    "Checking if your CPU supports SSE2..." print flush
    sse2? [
        " - yes" print
        enable-float-intrinsics
        [
            sse2? [
                "This image was built to use SSE2, which your CPU does not support." print
                "You will need to bootstrap Factor again." print
                flush
                1 exit
            ] unless
        ] "cpu.x86" add-init-hook
    ] [ " - no" print ] if
] unless
