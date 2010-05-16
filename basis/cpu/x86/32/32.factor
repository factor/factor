! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals alien alien.c-types alien.libraries alien.syntax
arrays kernel fry math namespaces sequences system layouts io
vocabs.loader accessors init classes.struct combinators make
words compiler.constants compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.intrinsics
compiler.cfg.stack-frame cpu.x86.assembler
cpu.x86.assembler.operands cpu.x86 cpu.architecture vm ;
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
    cell alignment
    [ end start - + building get dup pop* push ]
    [ (align-code) ]
    bi ;

M: x86.32 pic-tail-reg EDX ;

M: x86.32 reserved-stack-space 0 ;

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
        { float-regs { f } }
    } ;

M: x86.32 %prologue ( n -- )
    dup PUSH
    0 PUSH rc-absolute-cell rel-this
    3 cells - decr-stack-reg ;

M: x86.32 %prepare-jump
    pic-tail-reg 0 MOV xt-tail-pic-offset rc-absolute-cell rel-here ;

:: load-float-return ( dst x87-insn sse-insn -- )
    dst register? [
        ESP 4 SUB
        ESP [] x87-insn execute
        dst ESP [] sse-insn execute
        ESP 4 ADD
    ] [
        dst x87-insn execute
    ] if ; inline

M: x86.32 %load-reg-param ( dst reg rep -- )
    [ ?spill-slot ] dip {
        { int-rep [ MOV ] }
        { float-rep [ drop \ FSTPS \ MOVSS load-float-return ] }
        { double-rep [ drop \ FSTPL \ MOVSD load-float-return ] }
    } case ;

:: store-float-return ( src x87-insn sse-insn -- )
    src register? [
        ESP 4 SUB
        ESP [] src sse-insn execute
        ESP [] x87-insn execute
        ESP 4 ADD
    ] [
        src x87-insn execute
    ] if ; inline

M: x86.32 %store-reg-param ( src reg rep -- )
    [ ?spill-slot ] dip {
        { int-rep [ swap MOV ] }
        { float-rep [ \ FLDS \ MOVSS store-float-return ] }
        { double-rep [ \ FLDL \ MOVSD store-float-return ] }
    } case ;

:: call-unbox-func ( src func -- )
    EAX src tagged-rep %copy
    4 save-vm-ptr
    0 stack@ EAX MOV
    func f %alien-invoke ;

M:: x86.32 %unbox ( dst src func rep -- )
    src func call-unbox-func
    dst rep %load-return ;

M:: x86.32 %box ( dst src func rep -- )
    rep rep-size save-vm-ptr
    src rep %store-return
    0 stack@ rep %load-return
    func f %alien-invoke
    dst EAX tagged-rep %copy ;

M:: x86.32 %box-long-long ( dst src1 src2 func -- )
    8 save-vm-ptr
    4 stack@ src1 int-rep %copy
    0 stack@ src2 int-rep %copy
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

M:: x86.32 %call-gc ( gc-roots -- )
    4 save-vm-ptr
    0 stack@ gc-roots gc-root-offsets %load-reference
    "inline_gc" f %alien-invoke ;

M: x86.32 dummy-stack-params? f ;

M: x86.32 dummy-int-params? f ;

M: x86.32 dummy-fp-params? f ;

M: x86.32 long-long-on-stack? t ;

M: x86.32 float-on-stack? t ;

M: x86.32 flatten-struct-type
    call-next-method [ first t 2array ] map ;

M: x86.32 struct-return-on-stack? os linux? not ;

check-sse
