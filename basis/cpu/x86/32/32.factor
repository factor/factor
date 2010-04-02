! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals alien.c-types alien.libraries alien.syntax arrays
kernel fry math namespaces sequences system layouts io
vocabs.loader accessors init combinators command-line make
compiler compiler.units compiler.constants compiler.alien
compiler.codegen compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.intrinsics compiler.cfg.stack-frame
cpu.x86.assembler cpu.x86.assembler.operands cpu.x86
cpu.architecture vm ;
FROM: layouts => cell ;
IN: cpu.x86.32

M: x86.32 machine-registers
    {
        { int-regs { EAX ECX EDX EBP EBX } }
        { float-regs { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 } }
    } ;

M: x86.32 ds-reg ESI ;
M: x86.32 rs-reg EDI ;
M: x86.32 stack-reg ESP ;
M: x86.32 frame-reg EBP ;
M: x86.32 temp-reg ECX ;

M: x86.32 %mov-vm-ptr ( reg -- )
    0 MOV 0 rc-absolute-cell rel-vm ;

M: x86.32 %vm-field ( dst field -- )
    [ 0 [] MOV ] dip rc-absolute-cell rel-vm ;

M: x86.32 %set-vm-field ( dst field -- )
    [ 0 [] swap MOV ] dip rc-absolute-cell rel-vm ;

M: x86.32 %vm-field-ptr ( dst field -- )
    [ 0 MOV ] dip rc-absolute-cell rel-vm ;

: local@ ( n -- op )
    stack-frame get extra-stack-space dup 16 assert= + stack@ ;

M: x86.32 extra-stack-space calls-vm?>> 16 0 ? ;

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
    building get length :> start
    0 rc-absolute-cell rel-here
    ! Go
    temp HEX: 7f [+] JMP
    building get length :> end
    ! Fix up the displacement above
    cell code-alignment
    [ end start - + building get dup pop* push ]
    [ align-code ]
    bi ;

M: x86.32 pic-tail-reg EBX ;

M: x86.32 reserved-stack-space 4 cells ;

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
    [ next-stack@ ] [ stack-frame get params>> local@ ] if* ;

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

M: x86.32 %prepare-jump
    pic-tail-reg 0 MOV xt-tail-pic-offset rc-absolute-cell rel-here ;

M: x86.32 %load-param-reg
    stack-params assert=
    [ [ EAX ] dip local@ MOV ] dip
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
    "from_value_struct" f %alien-invoke ;

M: x86.32 %prepare-box-struct ( -- )
    ! Compute target address for value struct return
    EAX f struct-return@ LEA
    ! Store it as the first parameter
    0 local@ EAX MOV ;

M: x86.32 %box-small-struct ( c-type -- )
    #! Box a <= 8-byte struct returned in EAX:EDX. OS X only.
    12 save-vm-ptr
    8 stack@ swap heap-size MOV
    4 stack@ EDX MOV
    0 stack@ EAX MOV
    "from_small_struct" f %alien-invoke ;

M: x86.32 %pop-stack ( n -- )
    EAX swap ds-reg reg-stack MOV ;

M: x86.32 %pop-context-stack ( -- )
    temp-reg %context
    EAX temp-reg "datastack" context-field-offset [+] MOV
    EAX EAX [] MOV
    temp-reg "datastack" context-field-offset [+] bootstrap-cell SUB ;

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
    over [ [ local@ ] dip store-return-reg ] [ 2drop ] if ;

M: x86.32 %unbox-long-long ( n func -- )
    call-unbox-func
    ! Store the return value on the C stack
    [
        [ local@ EAX MOV ]
        [ 4 + local@ EDX MOV ] bi
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
    EDX n local@ LEA
    12 save-vm-ptr
    8 stack@ c-type heap-size MOV
    4 stack@ EDX MOV
    0 stack@ EAX MOV
    "to_value_struct" f %alien-invoke ;

M: x86.32 %prepare-alien-indirect ( -- )
    EAX ds-reg [] MOV
    ds-reg 4 SUB
    4 save-vm-ptr
    0 stack@ EAX MOV
    "pinned_alien_offset" f %alien-invoke
    EBP EAX MOV ;

M: x86.32 %alien-indirect ( -- )
    EBP CALL ;

M: x86.32 %begin-callback ( -- )
    0 save-vm-ptr
    ESP 4 [+] 0 MOV
    "begin_callback" f %alien-invoke ;

M: x86.32 %alien-callback ( quot -- )
    EAX EDX %restore-context
    EAX swap %load-reference
    EAX quot-entry-point-offset [+] CALL
    EAX EDX %save-context ;

M: x86.32 %end-callback ( -- )
    0 save-vm-ptr
    "end_callback" f %alien-invoke ;

M: x86.32 %end-callback-value ( ctype -- )
    %pop-context-stack
    4 stack@ EAX MOV
    %end-callback
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

: stdcall? ( params -- ? )
    abi>> "stdcall" = ;

: funny-large-struct-return? ( params -- ? )
    #! MINGW ABI incompatibility disaster
    [ return>> large-struct? ]
    [ abi>> "mingw" = os windows? not or ]
    bi and ;

M: x86.32 %cleanup ( params -- )
    #! a) If we just called an stdcall function in Windows, it
    #! cleaned up the stack frame for us. But we don't want that
    #! so we 'undo' the cleanup since we do that in %epilogue.
    #! b) If we just called a function returning a struct, we
    #! have to fix ESP.
    {
        { [ dup stdcall? ] [ drop ESP stack-frame get params>> SUB ] }
        { [ dup funny-large-struct-return? ] [ drop EAX PUSH ] }
        [ drop ]
    } cond ;

M:: x86.32 %call-gc ( gc-root-count temp -- )
    temp gc-root-base special@ LEA
    8 save-vm-ptr
    4 stack@ gc-root-count MOV
    0 stack@ temp MOV
    "inline_gc" f %alien-invoke ;

M: x86.32 dummy-stack-params? f ;

M: x86.32 dummy-int-params? f ;

M: x86.32 dummy-fp-params? f ;

M: x86.32 callback-return-rewind ( params -- n )
    #! a) If the callback is stdcall, we have to clean up the
    #! caller's stack frame.
    #! b) If the callback is returning a large struct, we have
    #! to fix ESP.
    {
        { [ dup stdcall? ] [ <alien-stack-frame> [ params>> ] [ return>> ] bi + ] }
        { [ dup funny-large-struct-return? ] [ drop 4 ] }
        [ drop 0 ]
    } cond ;

! Dreadful
M: object flatten-value-type (flatten-int-type) ;

check-sse
