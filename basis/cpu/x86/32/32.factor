! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: locals alien alien.c-types alien.libraries alien.syntax
arrays kernel fry math namespaces sequences system layouts io
vocabs.loader accessors init classes.struct combinators
make words compiler.constants compiler.codegen.fixup
compiler.cfg.instructions compiler.cfg.builder compiler.cfg.intrinsics
compiler.cfg.stack-frame cpu.x86.assembler cpu.x86.assembler.operands
cpu.x86 cpu.architecture vm ;
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

M: x86.32 immediate-comparand? ( obj -- ? ) drop t ;

M:: x86.32 %load-vector ( dst val rep -- )
    dst 0 [] rep copy-memory* val rc-absolute rel-binary-literal ;

M: x86.32 %load-float ( dst val -- )
    <float> float-rep %load-vector ;

M: x86.32 %load-double ( dst val -- )
    <double> double-rep %load-vector ;

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
    cell alignment
    [ end start - + building get dup pop* push ]
    [ (align-code) ]
    bi ;

M: x86.32 pic-tail-reg EDX ;

M: x86.32 reserved-stack-space 0 ;

M: x86.32 %alien-invoke 0 CALL rc-relative rel-dlsym ;

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
M: int-regs return-reg drop EAX ;
M: float-regs param-regs 2drop { } ;

M: int-regs param-regs
    nip {
        { thiscall [ { ECX } ] }
        { fastcall [ { ECX EDX } ] }
        [ drop { } ]
    } case ;

GENERIC: load-return-reg ( src rep -- )
GENERIC: store-return-reg ( dst rep -- )

M: stack-params load-return-reg drop EAX swap MOV ;
M: stack-params store-return-reg drop EAX MOV ;

M: int-rep load-return-reg drop EAX swap MOV ;
M: int-rep store-return-reg drop EAX MOV ;

:: load-float-return ( src x87-insn sse-insn -- )
    src register? [
        ESP 4 SUB
        ESP [] src sse-insn execute
        ESP [] x87-insn execute
        ESP 4 ADD
    ] [
        src x87-insn execute
    ] if ; inline

:: store-float-return ( dst x87-insn sse-insn -- )
    dst register? [
        ESP 4 SUB
        ESP [] x87-insn execute
        dst ESP [] sse-insn execute
        ESP 4 ADD
    ] [
        dst x87-insn execute
    ] if ; inline

M: float-rep load-return-reg
    drop \ FLDS \ MOVSS load-float-return ;

M: float-rep store-return-reg
    drop \ FSTPS \ MOVSS store-float-return ;

M: double-rep load-return-reg
    drop \ FLDL \ MOVSD load-float-return ;

M: double-rep store-return-reg
    drop \ FSTPL \ MOVSD store-float-return ;

M: x86.32 %prologue ( n -- )
    dup PUSH
    0 PUSH rc-absolute-cell rel-this
    3 cells - decr-stack-reg ;

M: x86.32 %prepare-jump
    pic-tail-reg 0 MOV xt-tail-pic-offset rc-absolute-cell rel-here ;

:: call-unbox-func ( src func -- )
    EAX src tagged-rep %copy
    4 save-vm-ptr
    0 stack@ EAX MOV
    func f %alien-invoke ;

M:: x86.32 %unbox ( dst src func rep -- )
    src func call-unbox-func
    dst ?spill-slot rep store-return-reg ;

M:: x86.32 %store-return ( src rep -- )
    src ?spill-slot rep load-return-reg ;

M:: x86.32 %store-long-long-return ( src1 src2 -- )
    src2 EAX = [ src1 src2 XCHG src2 src1 ] [ src1 src2 ] if :> ( src1 src2 )
    EAX src1 int-rep %copy
    EDX src2 int-rep %copy ;

M:: x86.32 %store-struct-return ( src c-type -- )
    EAX src int-rep %copy
    EDX EAX 4 [+] MOV
    EAX EAX [] MOV ;

M: stack-params copy-register*
    drop
    {
        { [ dup  integer? ] [ EAX swap next-stack@ MOV  EAX MOV ] }
        { [ over integer? ] [ EAX swap MOV              param@ EAX MOV ] }
    } cond ;

M: x86.32 %save-param-reg [ local@ ] 2dip %copy ;

: (%box) ( n rep -- )
    #! If n is f, push the return register onto the stack; we
    #! are boxing a return value of a C function. If n is an
    #! integer, push [ESP+n] on the stack; we are boxing a
    #! parameter being passed to a callback from C.
    over [ [ local@ ] dip load-return-reg ] [ 2drop ] if ;

M:: x86.32 %box ( dst n rep func -- )
    n rep (%box)
    rep rep-size save-vm-ptr
    0 stack@ rep store-return-reg
    func f %alien-invoke
    dst EAX tagged-rep %copy ;

: (%box-long-long) ( n -- )
    [
        [ EDX swap next-stack@ MOV ]
        [ EAX swap cell - next-stack@ MOV ] bi
    ] when* ;

M:: x86.32 %box-long-long ( dst n func -- )
    n (%box-long-long)
    8 save-vm-ptr
    4 stack@ EDX MOV
    0 stack@ EAX MOV
    func f %alien-invoke
    dst EAX tagged-rep %copy ;

M: x86.32 struct-return@ ( n -- operand )
    [ next-stack@ ] [ stack-frame get params>> local@ ] if* ;

M:: x86.32 %box-large-struct ( dst n c-type -- )
    EDX n struct-return@ LEA
    8 save-vm-ptr
    4 stack@ c-type heap-size MOV
    0 stack@ EDX MOV
    "from_value_struct" f %alien-invoke
    dst EAX tagged-rep %copy ;

M:: x86.32 %box-small-struct ( dst c-type -- )
    #! Box a <= 8-byte struct returned in EAX:EDX. OS X only.
    12 save-vm-ptr
    8 stack@ c-type heap-size MOV
    4 stack@ EDX MOV
    0 stack@ EAX MOV
    "from_small_struct" f %alien-invoke
    dst EAX tagged-rep %copy ;

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
    stack-size cell /i { int-rep t } <repetition> ;

M: x86.32 struct-return-on-stack? os linux? not ;

check-sse
