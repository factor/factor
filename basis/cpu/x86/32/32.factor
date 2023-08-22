! Copyright (C) 2005, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays classes.struct
combinators compiler.cfg.builder.alien.boxing
compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.x86 cpu.x86.assembler cpu.x86.assembler.operands
cpu.x86.features kernel layouts locals make math namespaces
sequences specialized-arrays system vocabs ;
SPECIALIZED-ARRAY: uint
IN: cpu.x86.32

: x86-float-regs ( -- seq )
    "cpu.x86.sse" lookup-vocab
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

M: x86.32 immediate-comparand? drop t ;

M:: x86.32 %load-vector ( dst val rep -- )
    dst 0 [] rep copy-memory* val rc-absolute rel-binary-literal ;

M: x86.32 %vm-field
    [ 0 [] MOV ] dip rc-absolute-cell rel-vm ;

M: x86.32 %set-vm-field
    [ 0 [] swap MOV ] dip rc-absolute-cell rel-vm ;

M: x86.32 %vm-field-ptr
    [ 0 MOV ] dip rc-absolute-cell rel-vm ;

M: x86.32 %mark-card
    drop 0xffffffff [+] card-mark <byte> MOV
    building get pop
    rc-absolute-cell rel-cards-offset
    building get push ;

M: x86.32 %mark-deck
    drop 0xffffffff [+] card-mark <byte> MOV
    building get pop
    rc-absolute-cell rel-decks-offset
    building get push ;

M: x86.32 pic-tail-reg EDX ;

M: x86.32 reserved-stack-space 0 ;

M: x86.32 vm-stack-space 16 ;

: save-vm-ptr ( n -- )
    stack@ 0 MOV 0 rc-absolute-cell rel-vm ;

M: x86.32 return-struct-in-registers?
    lookup-c-type
    [ return-in-registers?>> ]
    [ heap-size { 1 2 4 8 } member? ] bi
    os linux? not
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

M: x86.32 %prepare-jump
    pic-tail-reg 0 MOV xt-tail-pic-offset rc-absolute-cell rel-here ;

M: x86.32 %load-stack-param
    next-stack@ swap pick register? [ %copy ] [
        {
            { int-rep [ [ EAX ] dip MOV ?spill-slot EAX MOV ] }
            { float-rep [ FLDS ?spill-slot FSTPS ] }
            { double-rep [ FLDL ?spill-slot FSTPL ] }
        } case
    ] if ;

M: x86.32 %store-stack-param
    stack@ swap pick register? [ swapd %copy ] [
        {
            { int-rep [ [ [ EAX ] dip ?spill-slot MOV ] [ EAX MOV ] bi* ] }
            { float-rep [ [ ?spill-slot FLDS ] [ FSTPS ] bi* ] }
            { double-rep [ [ ?spill-slot FLDL ] [ FSTPL ] bi* ] }
        } case
    ] if ;

:: load-float-return ( dst x87-insn rep -- )
    dst register? [
        ESP 4 SUB
        ESP [] x87-insn execute
        dst ESP [] rep %copy
        ESP 4 ADD
    ] [
        dst ?spill-slot x87-insn execute
    ] if ; inline

M: x86.32 %load-reg-param
    swap {
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

M: x86.32 %store-reg-param
    swap {
        { int-rep [ swap int-rep %copy ] }
        { float-rep [ drop \ FLDS float-rep store-float-return ] }
        { double-rep [ drop \ FLDL double-rep store-float-return ] }
    } case ;

M: x86.32 %discard-reg-param
    drop {
        { int-rep [ ] }
        { float-rep [ ST0 FSTP ] }
        { double-rep [ ST0 FSTP ] }
    } case ;

:: call-unbox-func ( src func -- )
    EAX src tagged-rep %copy
    4 save-vm-ptr
    0 stack@ EAX MOV
    func f f %c-invoke ;

M:: x86.32 %unbox ( dst src func rep -- )
    src func call-unbox-func
    dst rep %load-return ;

M:: x86.32 %unbox-long-long ( dst1 dst2 src func -- )
    src int-rep 0 %store-stack-param
    4 save-vm-ptr
    func f f %c-invoke
    dst1 EAX int-rep %copy
    dst2 EDX int-rep %copy ;

M:: x86.32 %box ( dst src func rep gc-map -- )
    src rep 0 %store-stack-param
    rep rep-size save-vm-ptr
    func f gc-map %c-invoke
    dst EAX tagged-rep %copy ;

M:: x86.32 %box-long-long ( dst src1 src2 func gc-map -- )
    src1 int-rep 0 %store-stack-param
    src2 int-rep 4 %store-stack-param
    8 save-vm-ptr
    func f gc-map %c-invoke
    dst EAX tagged-rep %copy ;

M: x86.32 %c-invoke
    [ 0 CALL rc-relative rel-dlsym ] dip gc-map-here ;

M: x86.32 %begin-callback
    0 save-vm-ptr
    4 stack@ 0 MOV
    "begin_callback" f f %c-invoke ;

M: x86.32 %end-callback
    0 save-vm-ptr
    "end_callback" f f %c-invoke ;

: funny-large-struct-return? ( return abi -- ? )
    ! MINGW ABI incompatibility disaster
    [ large-struct? ] [ mingw eq? os windows? not or ] bi* and ;

M: x86.32 %prepare-var-args drop ;

M:: x86.32 stack-cleanup ( stack-size return abi -- n )
    ! a) Functions which are stdcall/fastcall/thiscall have to
    ! clean up the caller's stack frame.
    ! b) Functions returning large structs on MINGW have to
    ! fix ESP.
    {
        { [ abi callee-cleanup? ] [ stack-size ] }
        { [ return abi funny-large-struct-return? ] [ 4 ] }
        [ 0 ]
    } cond ;

M: x86.32 %cleanup
    [ ESP swap SUB ] unless-zero ;

M: x86.32 %safepoint
    0 EAX MOVABS rc-absolute rel-safepoint ;

M: x86.32 dummy-stack-params? f ;

M: x86.32 dummy-int-params? f ;

M: x86.32 dummy-fp-params? f ;

M: x86.32 long-long-on-stack? t ;

M: x86.32 flatten-struct-type
    call-next-method [ first t f 3array ] map ;

M: x86.32 struct-return-on-stack? os linux? not ;

M: x86.32 (cpuid)
    void { uint uint void* } cdecl [
        ! Save ds-reg, rs-reg
        EDI PUSH
        EAX ESP 4 [+] MOV
        ECX ESP 8 [+] MOV
        CPUID
        EDI ESP 12 [+] MOV
        EDI [] EAX MOV
        EDI 4 [+] EBX MOV
        EDI 8 [+] ECX MOV
        EDI 12 [+] EDX MOV
        EDI POP
    ] alien-assembly ;
