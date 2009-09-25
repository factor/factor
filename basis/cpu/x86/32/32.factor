! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals alien.c-types alien.syntax arrays kernel fry math
namespaces sequences system layouts io vocabs.loader accessors init
combinators command-line make compiler compiler.units
compiler.constants compiler.alien compiler.codegen
compiler.codegen.fixup compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.intrinsics compiler.cfg.stack-frame cpu.x86.assembler
cpu.x86.assembler.operands cpu.x86 cpu.architecture ;
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

M: x86.32 reserved-area-size 0 ;

M: x86.32 %alien-invoke 0 CALL rc-relative rel-dlsym ;

: push-vm-ptr ( -- )
    0 PUSH rc-absolute-cell rt-vm rel-fixup ; ! push the vm ptr as an argument

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
M: float-regs param-regs drop { } ;

GENERIC: push-return-reg ( rep -- )
GENERIC: load-return-reg ( n rep -- )
GENERIC: store-return-reg ( n rep -- )

M: int-rep push-return-reg drop EAX PUSH ;
M: int-rep load-return-reg drop EAX swap next-stack@ MOV ;
M: int-rep store-return-reg drop stack@ EAX MOV ;

M: float-rep push-return-reg drop ESP 4 SUB ESP [] FSTPS ;
M: float-rep load-return-reg drop next-stack@ FLDS ;
M: float-rep store-return-reg drop stack@ FSTPS ;

M: double-rep push-return-reg drop ESP 8 SUB ESP [] FSTPL ;
M: double-rep load-return-reg drop next-stack@ FLDL ;
M: double-rep store-return-reg drop stack@ FSTPL ;

: align-sub ( n -- )
    [ align-stack ] keep - decr-stack-reg ;

: align-add ( n -- )
    align-stack incr-stack-reg ;

: with-aligned-stack ( n quot -- )
    '[ align-sub @ ] [ align-add ] bi ; inline

M: x86.32 %prologue ( n -- )
    dup PUSH
    0 PUSH rc-absolute-cell rel-this
    3 cells - decr-stack-reg ;

M: x86.32 %load-param-reg 3drop ;

M: x86.32 %save-param-reg 3drop ;

: (%box) ( n rep -- )
    #! If n is f, push the return register onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n] on the stack; we are boxing a
    #! parameter being passed to a callback from C.
    over [ load-return-reg ] [ 2drop ] if ;

CONSTANT: vm-ptr-size 4

M:: x86.32 %box ( n rep func -- )
    n rep (%box)
    rep rep-size vm-ptr-size + [
        push-vm-ptr
        rep push-return-reg
        func f %alien-invoke
    ] with-aligned-stack ;
    
: (%box-long-long) ( n -- )
    [
        EDX over next-stack@ MOV
        EAX swap cell - next-stack@ MOV 
    ] when* ;

M: x86.32 %box-long-long ( n func -- )
    [ (%box-long-long) ] dip
    8 vm-ptr-size + [
        push-vm-ptr
        EDX PUSH
        EAX PUSH
        f %alien-invoke
    ] with-aligned-stack ;

M:: x86.32 %box-large-struct ( n c-type -- )
    ! Compute destination address
    EDX n struct-return@ LEA
    8 vm-ptr-size + [
        push-vm-ptr
        ! Push struct size
        c-type heap-size PUSH
        ! Push destination address
        EDX PUSH
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
    12 vm-ptr-size + [
        push-vm-ptr
        heap-size PUSH
        EDX PUSH
        EAX PUSH
        "box_small_struct" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %prepare-unbox ( -- )
    #! Move top of data stack to EAX.
    EAX ESI [] MOV
    ESI 4 SUB ;

: call-unbox-func ( func -- )
    8 [
        ! push the vm ptr as an argument
        push-vm-ptr
        ! Push parameter
        EAX PUSH
        ! Call the unboxer
        f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %unbox ( n rep func -- )
    #! The value being unboxed must already be in EAX.
    #! If n is f, we're unboxing a return value about to be
    #! returned by the callback. Otherwise, we're unboxing
    #! a parameter to a C function about to be called.
    call-unbox-func
    ! Store the return value on the C stack
    over [ store-return-reg ] [ 2drop ] if ;

M: x86.32 %unbox-long-long ( n func -- )
    call-unbox-func
    ! Store the return value on the C stack
    [
        dup stack@ EAX MOV
        cell + stack@ EDX MOV
    ] when* ;

: %unbox-struct-1 ( -- )
    #! Alien must be in EAX.
    4 vm-ptr-size + [
        push-vm-ptr
        EAX PUSH
        "alien_offset" f %alien-invoke
        ! Load first cell
        EAX EAX [] MOV
    ] with-aligned-stack ;

: %unbox-struct-2 ( -- )
    #! Alien must be in EAX.
    4 vm-ptr-size + [
        push-vm-ptr
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

M:: x86.32 %unbox-large-struct ( n c-type -- )
    ! Alien must be in EAX.
    ! Compute destination address
    EDX n stack@ LEA
    12 vm-ptr-size + [
        push-vm-ptr
        ! Push struct size
        c-type heap-size PUSH
        ! Push destination address
        EDX PUSH
        ! Push source address
        EAX PUSH
        ! Copy the struct to the stack
        "to_value_struct" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %nest-stacks ( -- )
    4 [
        push-vm-ptr
        "nest_stacks" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %unnest-stacks ( -- )
    4 [
        push-vm-ptr
        "unnest_stacks" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %prepare-alien-indirect ( -- )
    push-vm-ptr "unbox_alien" f %alien-invoke
    temp-reg POP
    EBP EAX MOV ;

M: x86.32 %alien-indirect ( -- )
    EBP CALL ;

M: x86.32 %alien-callback ( quot -- )
    4 [
        EAX swap %load-reference
        EAX PUSH
        param-reg-2 0 MOV rc-absolute-cell rt-vm rel-fixup 
        "c_to_factor" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 %callback-value ( ctype -- )
    ! Align C stack
    ESP 12 SUB
    ! Save top of data stack in non-volatile register
    %prepare-unbox
    EAX PUSH
    push-vm-ptr
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Place top of data stack in EAX
    temp-reg POP
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

M:: x86.32 %call-gc ( gc-root-count temp1 -- )
    ! USE: prettyprint "PHIL" pprint temp1 pprint temp2 pprint
    temp1 gc-root-base param@ LEA
    12 [
        0 PUSH rc-absolute-cell rt-vm rel-fixup ! push the vm ptr as an argument
        ! Pass number of roots as second parameter
        gc-root-count PUSH 
        ! Pass pointer to start of GC roots as first parameter
        temp1 PUSH 
        ! Call GC
        "inline_gc" f %alien-invoke
    ] with-aligned-stack ;

M: x86.32 dummy-stack-params? f ;

M: x86.32 dummy-int-params? f ;

M: x86.32 dummy-fp-params? f ;

os windows? [
    cell "longlong" c-type (>>align)
    cell "ulonglong" c-type (>>align)
    4 "double" c-type (>>align)
] unless

check-sse
