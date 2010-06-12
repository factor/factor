! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals alien alien.c-types alien.libraries alien.syntax
arrays kernel fry math namespaces sequences system layouts io
vocabs.loader accessors init classes.struct combinators make
words compiler.constants compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.intrinsics
compiler.cfg.stack-frame cpu.x86.assembler
cpu.x86.assembler.operands cpu.x86 cpu.architecture vm vocabs ;
FROM: layouts => cell ;
IN: cpu.x86.32

: x86-float-regs ( -- seq )
    "cpu.x86.sse" vocab
    { XMM0 XMM1 XMM2 XMM3 XMM4 XMM5 XMM6 XMM7 }
    { ST0 ST1 ST2 ST3 ST4 ST5 ST6 }
    ? ;

M: x86.32 machine-registers
    { int-regs { EAX ECX EDX EBP EBX } }
    float-regs x86-float-regs 2array
    2array ;

M: x86.32 ds-reg ESI ;
M: x86.32 rs-reg EDI ;
M: x86.32 stack-reg ESP ;
M: x86.32 frame-reg EBP ;

M: x86.32 immediate-comparand? ( obj -- ? ) drop t ;

M:: x86.32 %load-vector ( dst val rep -- )
    dst 0 [] rep copy-memory* val rc-absolute rel-binary-literal ;

M: x86.32 %mov-vm-ptr ( reg -- )
    0 MOV 0 rc-absolute-cell rel-vm ;

M: x86.32 %vm-field ( dst field -- )
    [ 0 [] MOV ] dip rc-absolute-cell rel-vm ;

M: x86.32 %set-vm-field ( dst field -- )
    [ 0 [] swap MOV ] dip rc-absolute-cell rel-vm ;

M: x86.32 %vm-field-ptr ( dst field -- )
    [ 0 MOV ] dip rc-absolute-cell rel-vm ;

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

M: x86.32 pic-tail-reg EDX ;

M: x86.32 reserved-stack-space 0 ;

M: x86.32 vm-stack-space 16 ;

: save-vm-ptr ( n -- )
    stack@ 0 MOV 0 rc-absolute-cell rel-vm ;

M: x86.32 return-struct-in-registers? ( c-type -- ? )
    c-type
    [ return-in-registers?>> ]
    [ heap-size { 1 2 4 8 } member? ] bi
    os { linux netbsd solaris } member? not
    and or ;

! On x86, parameters are usually never passed in registers,
! except with Microsoft's "thiscall" and "fastcall" abis
M: x86.32 param-regs
    {
        { thiscall [ { { int-regs { ECX } } { float-regs { } } } ] }
        { fastcall [ { { int-regs { ECX EDX } } { float-regs { } } } ] }
        [ drop { { int-regs { } } { float-regs { } } } ]
    } case ;

! Need a fake return-reg for floats
M: x86.32 return-regs
    {
        { int-regs { EAX EDX } }
        { float-regs { ST0 } }
    } ;

M: x86.32 %prologue ( n -- )
    dup PUSH
    0 PUSH rc-absolute-cell rel-this
    3 cells - decr-stack-reg ;

M: x86.32 %prepare-jump
    pic-tail-reg 0 MOV xt-tail-pic-offset rc-absolute-cell rel-here ;

:: load-float-return ( dst x87-insn rep -- )
    dst register? [
        ESP 4 SUB
        ESP [] x87-insn execute
        dst ESP [] rep %copy
        ESP 4 ADD
    ] [
        dst ?spill-slot x87-insn execute
    ] if ; inline

M: x86.32 %load-reg-param ( dst reg rep -- )
    {
        { int-rep [ int-rep %copy ] }
        { float-rep [ drop \ FSTPS float-rep load-float-return ] }
        { double-rep [ drop \ FSTPL double-rep load-float-return ] }
    } case ;

:: store-float-return ( src x87-insn rep -- )
    src register? [
        ESP 4 SUB
        ESP [] src rep %copy
        ESP [] x87-insn execute
        ESP 4 ADD
    ] [
        src ?spill-slot x87-insn execute
    ] if ; inline

M: x86.32 %store-reg-param ( src reg rep -- )
    {
        { int-rep [ swap int-rep %copy ] }
        { float-rep [ drop \ FLDS float-rep store-float-return ] }
        { double-rep [ drop \ FLDL double-rep store-float-return ] }
    } case ;

:: call-unbox-func ( src func -- )
    EAX src tagged-rep %copy
    4 save-vm-ptr
    0 stack@ EAX MOV
    func f %alien-invoke ;

M:: x86.32 %unbox ( dst src func rep -- )
    src func call-unbox-func
    dst rep %load-return ;

M:: x86.32 %unbox-long-long ( src out func -- )
    EAX src int-rep %copy
    0 stack@ EAX MOV
    EAX out int-rep %copy
    4 stack@ EAX MOV
    8 save-vm-ptr
    func f %alien-invoke ;

M:: x86.32 %box ( dst src func rep -- )
    rep rep-size save-vm-ptr
    src rep %store-return
    0 stack@ rep %load-return
    func f %alien-invoke
    dst EAX tagged-rep %copy ;

M:: x86.32 %box-long-long ( dst src1 src2 func -- )
    8 save-vm-ptr
    EAX src1 int-rep %copy
    0 stack@ EAX int-rep %copy
    EAX src2 int-rep %copy
    4 stack@ EAX int-rep %copy
    func f %alien-invoke
    dst EAX tagged-rep %copy ;

M:: x86.32 %allot-byte-array ( dst size -- )
    4 save-vm-ptr
    0 stack@ size MOV
    "allot_byte_array" f %alien-invoke
    dst EAX tagged-rep %copy ;

M: x86.32 %alien-invoke 0 CALL rc-relative rel-dlsym ;

M: x86.32 %begin-callback ( -- )
    0 save-vm-ptr
    4 stack@ 0 MOV
    "begin_callback" f %alien-invoke ;

M: x86.32 %alien-callback ( quot -- )
    [ EAX ] dip %load-reference
    EAX quot-entry-point-offset [+] CALL ;

M: x86.32 %end-callback ( -- )
    0 save-vm-ptr
    "end_callback" f %alien-invoke ;

GENERIC: float-function-param ( n dst src -- )

M:: spill-slot float-function-param ( n dst src -- )
    ! We can clobber dst here since its going to contain the
    ! final result
    dst src double-rep %copy
    dst n double-rep %store-stack-param ;

M:: register float-function-param ( n dst src -- )
    src n double-rep %store-stack-param ;

M:: x86.32 %unary-float-function ( dst src func -- )
    0 dst src float-function-param
    func "libm" load-library %alien-invoke
    dst double-rep %load-return ;

M:: x86.32 %binary-float-function ( dst src1 src2 func -- )
    0 dst src1 float-function-param
    8 dst src2 float-function-param
    func "libm" load-library %alien-invoke
    dst double-rep %load-return ;

: funny-large-struct-return? ( return abi -- ? )
    #! MINGW ABI incompatibility disaster
    [ large-struct? ] [ mingw eq? os windows? not or ] bi* and ;

M:: x86.32 stack-cleanup ( stack-size return abi -- n )
    #! a) Functions which are stdcall/fastcall/thiscall have to
    #! clean up the caller's stack frame.
    #! b) Functions returning large structs on MINGW have to
    #! fix ESP.
    {
        { [ abi callee-cleanup? ] [ stack-size ] }
        { [ return abi funny-large-struct-return? ] [ 4 ] }
        [ 0 ]
    } cond ;

M: x86.32 %cleanup ( n -- )
    [ ESP swap SUB ] unless-zero ;

M: x86.32 dummy-stack-params? f ;

M: x86.32 dummy-int-params? f ;

M: x86.32 dummy-fp-params? f ;

M: x86.32 long-long-on-stack? t ;

M: x86.32 float-on-stack? t ;

M: x86.32 flatten-struct-type
    call-next-method [ first t 2array ] map ;

M: x86.32 struct-return-on-stack? os linux? not ;

check-sse
