! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.x86.assembler cpu.x86.assembler.operands layouts
vocabs parser compiler.constants sequences math math.private
generic.single.private ;
IN: bootstrap.x86

4 \ cell set

: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: shift-arg ( -- reg ) ECX ;
: div-arg ( -- reg ) EAX ;
: mod-arg ( -- reg ) EDX ;
: temp0 ( -- reg ) EAX ;
: temp1 ( -- reg ) EDX ;
: temp2 ( -- reg ) ECX ;
: temp3 ( -- reg ) EBX ;
: safe-reg ( -- reg ) EAX ;
: stack-reg ( -- reg ) ESP ;
: frame-reg ( -- reg ) EBP ;
: vm-reg ( -- reg ) ECX ;
: ctx-reg ( -- reg ) EBP ;
: nv-regs ( -- seq ) { ESI EDI EBX } ;
: ds-reg ( -- reg ) ESI ;
: rs-reg ( -- reg ) EDI ;
: fixnum>slot@ ( -- ) temp0 2 SAR ;
: rex-length ( -- n ) 0 ;

[
    ! save stack frame size
    stack-frame-size PUSH
    ! push entry point
    0 PUSH rc-absolute-cell rt-this jit-rel
    ! alignment
    ESP stack-frame-size 3 bootstrap-cells - SUB
] jit-prolog jit-define

[
    temp3 0 MOV rc-absolute-cell rt-here jit-rel
    0 JMP rc-relative rt-entry-point-pic-tail jit-rel
] jit-word-jump jit-define

: jit-load-vm ( -- )
    vm-reg 0 MOV 0 rc-absolute-cell jit-vm ;

: jit-load-context ( -- )
    ! VM pointer must be in vm-reg already
    ctx-reg vm-reg vm-context-offset [+] MOV ;

: jit-save-context ( -- )
    EDX RSP -4 [+] LEA
    ctx-reg context-callstack-top-offset [+] EDX MOV
    ctx-reg context-datastack-offset [+] ds-reg MOV
    ctx-reg context-retainstack-offset [+] rs-reg MOV ;

: jit-restore-context ( -- )
    ds-reg ctx-reg context-datastack-offset [+] MOV
    rs-reg ctx-reg context-retainstack-offset [+] MOV ;

[
    jit-load-vm
    jit-load-context
    jit-save-context
    ! call the primitive
    ESP [] vm-reg MOV
    0 CALL rc-relative rt-dlsym jit-rel
    ! restore ds, rs registers
    jit-restore-context
] jit-primitive jit-define

[
    ! Load quotation
    EAX EBP 8 [+] MOV
    ! save ctx->callstack_bottom, load ds, rs registers
    jit-load-vm
    jit-load-context
    jit-restore-context
    EDX stack-reg stack-frame-size 4 - [+] LEA
    ctx-reg context-callstack-bottom-offset [+] EDX MOV
    ! call the quotation
    EAX quot-entry-point-offset [+] CALL
    ! save ds, rs registers
    jit-save-context
] \ c-to-factor define-sub-primitive

[
    EAX ds-reg [] MOV
    ds-reg bootstrap-cell SUB
]
[ EAX quot-entry-point-offset [+] CALL ]
[ EAX quot-entry-point-offset [+] JMP ]
\ (call) define-combinator-primitive

[
    ! Clear x87 stack, but preserve rounding mode and exception flags
    ESP 2 SUB
    ESP [] FNSTCW
    FNINIT
    ESP [] FLDCW
    ESP 2 ADD

    ! Load arguments
    EAX ESP stack-frame-size [+] MOV
    EDX ESP stack-frame-size 4 + [+] MOV

    ! Unwind stack frames
    ESP EDX MOV

    ! Load ds and rs registers
    jit-load-vm
    jit-load-context
    jit-restore-context

    ! Call quotation
    EAX quot-entry-point-offset [+] JMP
] \ unwind-native-frames define-sub-primitive

[
    ! Load callstack object
    EBX ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    ! Get ctx->callstack_bottom
    jit-load-vm
    jit-load-context
    EAX ctx-reg context-callstack-bottom-offset [+] MOV
    ! Get top of callstack object -- 'src' for memcpy
    EBP EBX callstack-top-offset [+] LEA
    ! Get callstack length, in bytes --- 'len' for memcpy
    EDX EBX callstack-length-offset [+] MOV
    EDX tag-bits get SHR
    ! Compute new stack pointer -- 'dst' for memcpy
    EAX EDX SUB
    ! Install new stack pointer
    ESP EAX MOV
    ! Call memcpy
    EDX PUSH
    EBP PUSH
    EAX PUSH
    0 CALL "factor_memcpy" f rc-relative jit-dlsym
    ESP 12 ADD
    ! Return with new callstack
    0 RET
] \ set-callstack define-sub-primitive

[
    jit-load-vm
    jit-load-context
    jit-save-context

    ! Store arguments
    ESP [] EAX MOV
    ESP 4 [+] vm-reg MOV

    ! Call VM
    0 CALL "lazy_jit_compile" f rc-relative jit-dlsym
]
[ EAX quot-entry-point-offset [+] CALL ]
[ EAX quot-entry-point-offset [+] JMP ]
\ lazy-jit-compile define-combinator-primitive

! Inline cache miss entry points
: jit-load-return-address ( -- )
    EBX ESP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-load-vm
    jit-load-context
    jit-save-context
    ESP 4 [+] vm-reg MOV
    ESP [] EBX MOV
    0 CALL "inline_cache_miss" f rc-relative jit-dlsym
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ EAX CALL ]
[ EAX JMP ]
\ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ]
[ EAX CALL ]
[ EAX JMP ]
\ inline-cache-miss-tail define-combinator-primitive

! Overflowing fixnum arithmetic
: jit-overflow ( insn func -- )
    ds-reg 4 SUB
    jit-load-vm
    jit-load-context
    jit-save-context
    EAX ds-reg [] MOV
    EDX ds-reg 4 [+] MOV
    EBX EAX MOV
    [ [ EBX EDX ] dip call( dst src -- ) ] dip
    ds-reg [] EBX MOV
    [ JNO ]
    [
        ESP [] EAX MOV
        ESP 4 [+] EDX MOV
        ESP 8 [+] vm-reg MOV
        [ 0 CALL ] dip f rc-relative jit-dlsym
    ]
    jit-conditional ;

[ [ ADD ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    ds-reg 4 SUB
    jit-load-vm
    jit-load-context
    jit-save-context
    EBX ds-reg [] MOV
    EAX EBX MOV
    EBP ds-reg 4 [+] MOV
    EBP tag-bits get SAR
    EBP IMUL
    ds-reg [] EAX MOV
    [ JNO ]
    [
        EBX tag-bits get SAR
        ESP [] EBX MOV
        ESP 4 [+] EBP MOV
        ESP 8 [+] vm-reg MOV
        0 CALL "overflow_fixnum_multiply" f rc-relative jit-dlsym
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >>
call
