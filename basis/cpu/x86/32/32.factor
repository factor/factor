! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals alien.c-types alien.libraries alien.syntax arrays
kernel fry math namespaces sequences system layouts io
vocabs.loader accessors init combinators command-line make
compiler compiler.units compiler.constants compiler.alien
compiler.codegen compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.intrinsics compiler.cfg.stack-frame
cpu.x86.assembler cpu.x86.assembler.operands cpu.x86
cpu.architecture ;
IN: cpu.x86.32

! We implement the FFI for Linux, OS X and Windows all at once.
! OS X requires that the stack be 16-byte aligned.

M: x86.32 machine-registers
    {
        { int-regs { EAX ECX EDX EBP EBX } }
        { float-regs { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } }
    } ;

M: x86.32 ds-reg ESI ;
M: x86.32 rs-reg EDI ;
M: x86.32 stack-reg ESP ;
M: x86.32 temp-reg ECX ;

M: x86.32 %mark-card
    drop HEX: ffffffff [+] card-mark <byte> MOV
    building get pop
    rc-absolute-cell rel-cards-offset
    building get push ;

M: x86.32 %mark-deck
    drop HEX: ffffffff [+] card-mark <byte> MOV
    building get pop
    rc-absolute-cell rel-decks-offset
    building get push ;

M:: x86.32 %dispatch ( src temp -- )
    ! Load jump table base.
    temp src HEX: ffffffff [+] LEA
    building get length cell - :> start
    0 rc-absolute-cell rel-here
    ! Go
    temp HEX: 7f [+] JMP
    building get length :> end
    ! Fix up the displacement above
    cell code-alignment
    [ end start - + building get dup pop* push ]
    [ align-code ]
    bi ;

! Registers for fastcall
: param-reg-1 ( -- reg ) EAX ;
: param-reg-2 ( -- reg ) EDX ;

M: x86.32 pic-tail-reg EBX ;

M: x86.32 reserved-area-size 4 cells ;

M: x86.32 %alien-invoke 0 CALL rc-relative rel-dlsym ;

: save-vm-ptr ( n -- )
    stack@ 0 MOV 0 rc-absolute-cell rel-vm ;

M: x86.32 return-struct-in-registers? ( c-type -- ? )
    c-type
    [ return-in-registers?>> ]
    [ heap-size { 1 2 4 8 } member? ] bi
    os { linux netbsd solaris } member? not
    and or ;

: struct-return@ ( n -- operand )
    [ next-stack@ ] [ stack-frame get params>> param@ ] if* ;

! On x86, parameters are never passed in registers.
M: int-regs return-reg drop EAX ;
M: int-regs param-regs drop { } ;
M: float-regs param-regs drop { } ;

GENERIC: load-return-reg ( src rep -- )
GENERIC: store-return-reg ( dst rep -- )

M: int-rep load-return-reg drop EAX swap MOV ;
M: int-rep store-return-reg drop EAX MOV ;

M: float-rep load-return-reg drop FLDS ;
M: float-rep store-return-reg drop FSTPS ;

M: double-rep load-return-reg drop FLDL ;
M: double-rep store-return-reg drop FSTPL ;

M: x86.32 %prologue ( n -- )
    dup PUSH
    0 PUSH rc-absolute-cell rel-this
    3 cells - decr-stack-reg ;

M: x86.32 %load-param-reg
    stack-params assert=
    [ [ EAX ] dip param@ MOV ] dip
    stack@ EAX MOV ;

M: x86.32 %save-param-reg 3drop ;

: (%box) ( n rep -- )
    #! If n is f, push the return register onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n] on the stack; we are boxing a
    #! parameter being passed to a callback from C.
    over [ [ next-stack@ ] dip load-return-reg ] [ 2drop ] if ;

M:: x86.32 %box ( n rep func -- )
    n rep (%box)
    rep rep-size save-vm-ptr
    0 stack@ rep store-return-reg
    func f %alien-invoke ;

: (%box-long-long) ( n -- )
    [
        EDX over next-stack@ MOV
        EAX swap cell - next-stack@ MOV 
    ] when* ;

M: x86.32 %box-long-long ( n func -- )
    [ (%box-long-long) ] dip
    8 save-vm-ptr
    4 stack@ EDX MOV
    0 stack@ EAX MOV
    f %alien-invoke ;

M:: x86.32 %box-large-struct ( n c-type -- )
    EDX n struct-return@ LEA
    8 save-vm-ptr
    4 stack@ c-type heap-size MOV
    0 stack@ EDX MOV
    "box_value_struct" f %alien-invoke ;

M: x86.32 %prepare-box-struct ( -- )
    ! Compute target address for value struct return
    EAX f struct-return@ LEA
    ! Store it as the first parameter
    0 param@ EAX MOV ;

M: x86.32 %box-small-struct ( c-type -- )
    #! Box a <= 8-byte struct returned in EAX:EDX. OS X only.
    12 save-vm-ptr
    8 stack@ swap heap-size MOV
    4 stack@ EDX MOV
    0 stack@ EAX MOV
    "box_small_struct" f %alien-invoke ;

M: x86.32 %prepare-unbox ( -- )
    #! Move top of data stack to EAX.
    EAX ESI [] MOV
    ESI 4 SUB ;

: call-unbox-func ( func -- )
    4 save-vm-ptr
    0 stack@ EAX MOV
    f %alien-invoke ;

M: x86.32 %unbox ( n rep func -- )
    #! The value being unboxed must already be in EAX.
    #! If n is f, we're unboxing a return value about to be
    #! returned by the callback. Otherwise, we're unboxing
    #! a parameter to a C function about to be called.
    call-unbox-func
    ! Store the return value on the C stack
    over [ [ param@ ] dip store-return-reg ] [ 2drop ] if ;

M: x86.32 %unbox-long-long ( n func -- )
    call-unbox-func
    ! Store the return value on the C stack
    [
        dup param@ EAX MOV
        4 + param@ EDX MOV
    ] when* ;

: %unbox-struct-1 ( -- )
    #! Alien must be in EAX.
    4 save-vm-ptr
    0 stack@ EAX MOV
    "alien_offset" f %alien-invoke
    ! Load first cell
    EAX EAX [] MOV ;

: %unbox-struct-2 ( -- )
    #! Alien must be in EAX.
    4 save-vm-ptr
    0 stack@ EAX MOV
    "alien_offset" f %alien-invoke
    ! Load second cell
    EDX EAX 4 [+] MOV
    ! Load first cell
    EAX EAX [] MOV ;

M: x86 %unbox-small-struct ( size -- )
    #! Alien must be in EAX.
    heap-size cell align cell /i {
        { 1 [ %unbox-struct-1 ] }
        { 2 [ %unbox-struct-2 ] }
    } case ;

M:: x86.32 %unbox-large-struct ( n c-type -- )
    ! Alien must be in EAX.
    ! Compute destination address
    EDX n param@ LEA
    12 save-vm-ptr
    8 stack@ c-type heap-size MOV
    4 stack@ EDX MOV
    0 stack@ EAX MOV
    "to_value_struct" f %alien-invoke ;

M: x86.32 %nest-stacks ( -- )
    ! Save current frame. See comment in vm/contexts.hpp
    EAX stack-reg stack-frame get total-size>> 3 cells - [+] LEA
    4 save-vm-ptr
    0 stack@ EAX MOV
    "nest_stacks" f %alien-invoke ;

M: x86.32 %unnest-stacks ( -- )
    0 save-vm-ptr
    "unnest_stacks" f %alien-invoke ;

M: x86.32 %prepare-alien-indirect ( -- )
    0 save-vm-ptr
    "unbox_alien" f %alien-invoke
    EBP EAX MOV ;

M: x86.32 %alien-indirect ( -- )
    EBP CALL ;

M: x86.32 %alien-callback ( quot -- )
    ! Fastcall
    param-reg-1 swap %load-reference
    param-reg-2 %mov-vm-ptr
    "c_to_factor" f %alien-invoke ;

M: x86.32 %callback-value ( ctype -- )
    ! Save top of data stack in non-volatile register
    %prepare-unbox
    4 stack@ EAX MOV
    0 save-vm-ptr
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Place former top of data stack back in EAX
    EAX 4 stack@ MOV
    ! Unbox EAX
    unbox-return ;

GENERIC: float-function-param ( stack-slot dst src -- )

M:: spill-slot float-function-param ( stack-slot dst src -- )
    ! We can clobber dst here since its going to contain the
    ! final result
    dst src double-rep %copy
    stack-slot dst double-rep %copy ;

M: register float-function-param
    nip double-rep %copy ;

: float-function-return ( reg -- )
    ESP [] FSTPL
    ESP [] MOVSD
    ESP 16 ADD ;

M:: x86.32 %unary-float-function ( dst src func -- )
    ESP -16 [+] dst src float-function-param
    ESP 16 SUB
    func "libm" load-library %alien-invoke
    dst float-function-return ;

M:: x86.32 %binary-float-function ( dst src1 src2 func -- )
    ESP -16 [+] dst src1 float-function-param
    ESP  -8 [+] dst src2 float-function-param
    ESP 16 SUB
    func "libm" load-library %alien-invoke
    dst float-function-return ;

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

M:: x86.32 %call-gc ( gc-root-count temp -- )
    temp gc-root-base param@ LEA
    8 save-vm-ptr
    4 stack@ gc-root-count MOV
    0 stack@ temp MOV
    "inline_gc" f %alien-invoke ;

M: x86.32 dummy-stack-params? f ;

M: x86.32 dummy-int-params? f ;

M: x86.32 dummy-fp-params? f ;

! Dreadful
M: object flatten-value-type (flatten-int-type) ;

os windows? [
    cell longlong c-type (>>align)
    cell ulonglong c-type (>>align)
    4 double c-type (>>align)
] unless

check-sse
