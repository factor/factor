! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.x86.assembler cpu.x86.assembler.operands layouts
vocabs parser compiler.constants sequences math math.private
generic.single.private threads.private ;
IN: bootstrap.x86

4 \ cell set

: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: shift-arg ( -- reg ) ECX ;
: div-arg ( -- reg ) EAX ;
: mod-arg ( -- reg ) EDX ;
: temp0 ( -- reg ) EAX ;
: temp1 ( -- reg ) ECX ;
: temp2 ( -- reg ) EBX ;
: temp3 ( -- reg ) EDX ;
: pic-tail-reg ( -- reg ) EDX ;
: stack-reg ( -- reg ) ESP ;
: frame-reg ( -- reg ) EBP ;
: vm-reg ( -- reg ) EBX ;
: ctx-reg ( -- reg ) EBP ;
: nv-regs ( -- seq ) { ESI EDI EBX } ;
: nv-reg ( -- reg ) ESI ;
: ds-reg ( -- reg ) ESI ;
: rs-reg ( -- reg ) EDI ;
: link-reg ( -- reg ) EBX ;
: fixnum>slot@ ( -- ) temp0 2 SAR ;
: rex-length ( -- n ) 0 ;

: jit-call ( name -- )
    0 CALL rc-relative jit-dlsym ;

[
    ! save stack frame size
    stack-frame-size PUSH
    ! push entry point
    0 PUSH rc-absolute-cell rt-this jit-rel
    ! alignment
    ESP stack-frame-size 3 bootstrap-cells - SUB
] jit-prolog jit-define

[
    pic-tail-reg 0 MOV rc-absolute-cell rt-here jit-rel
    0 JMP rc-relative rt-entry-point-pic-tail jit-rel
] jit-word-jump jit-define

: jit-load-vm ( -- )
    vm-reg 0 MOV 0 rc-absolute-cell jit-vm ;

: jit-load-context ( -- )
    ! VM pointer must be in vm-reg already
    ctx-reg vm-reg vm-context-offset [+] MOV ;

: jit-save-context ( -- )
    jit-load-context
    ECX ESP -4 [+] LEA
    ctx-reg context-callstack-top-offset [+] ECX MOV
    ctx-reg context-datastack-offset [+] ds-reg MOV
    ctx-reg context-retainstack-offset [+] rs-reg MOV ;

: jit-restore-context ( -- )
    ds-reg ctx-reg context-datastack-offset [+] MOV
    rs-reg ctx-reg context-retainstack-offset [+] MOV ;

: jit-scrub-return ( n -- )
    ESP swap [+] 0 MOV ;

[
    ! ctx-reg is preserved across the call because it is non-volatile
    ! in the C ABI
    jit-load-vm
    jit-save-context
    ! call the primitive
    ESP [] vm-reg MOV
    0 CALL rc-relative rt-dlsym jit-rel
    jit-restore-context
] jit-primitive jit-define

: jit-jump-quot ( -- )
    EAX quot-entry-point-offset [+] JMP ;

: jit-call-quot ( -- )
    EAX quot-entry-point-offset [+] CALL ;

[
    jit-load-vm
    ESP [] vm-reg MOV
    EAX EBP 8 [+] MOV
    ESP 4 [+] EAX MOV
    "begin_callback" jit-call

    jit-call-quot

    jit-load-vm
    ESP [] vm-reg MOV
    "end_callback" jit-call
] \ c-to-factor define-sub-primitive

[
    EAX ds-reg [] MOV
    ds-reg bootstrap-cell SUB
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ (call) define-combinator-primitive

[
    ! Load ds and rs registers
    jit-load-vm
    jit-load-context
    jit-restore-context

    ! Windows-specific setup
    ctx-reg jit-update-seh

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
    0 jit-scrub-return

    jit-jump-quot
] \ unwind-native-frames define-sub-primitive

[
    ! Load callstack object
    temp3 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    ! Get ctx->callstack_bottom
    jit-load-vm
    jit-load-context
    temp0 ctx-reg context-callstack-bottom-offset [+] MOV
    ! Get top of callstack object -- 'src' for memcpy
    temp1 temp3 callstack-top-offset [+] LEA
    ! Get callstack length, in bytes --- 'len' for memcpy
    temp2 temp3 callstack-length-offset [+] MOV
    temp2 tag-bits get SHR
    ! Compute new stack pointer -- 'dst' for memcpy
    temp0 temp2 SUB
    ! Install new stack pointer
    ESP temp0 MOV
    ! Call memcpy
    temp2 PUSH
    temp1 PUSH
    temp0 PUSH
    "factor_memcpy" jit-call
    ESP 12 ADD
    ! Return with new callstack
    0 RET
] \ set-callstack define-sub-primitive

[
    jit-load-vm
    jit-save-context

    ! Store arguments
    ESP [] EAX MOV
    ESP 4 [+] vm-reg MOV

    ! Call VM
    "lazy_jit_compile" jit-call
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ lazy-jit-compile define-combinator-primitive

[
    temp1 HEX: ffffffff CMP rc-absolute-cell rt-literal jit-rel
] pic-check-tuple jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- )
    pic-tail-reg ESP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-load-vm
    jit-save-context
    ESP 4 [+] vm-reg MOV
    ESP [] pic-tail-reg MOV
    "inline_cache_miss" jit-call
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
        jit-load-vm
        ESP 8 [+] vm-reg MOV
        jit-call
    ]
    jit-conditional ;

[ [ ADD ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    ds-reg 4 SUB
    jit-load-vm
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
        jit-load-vm
        ESP 8 [+] vm-reg MOV
        "overflow_fixnum_multiply" jit-call
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

! Contexts
: jit-switch-context ( reg -- )
    -4 jit-scrub-return

    ! Save ds, rs registers
    jit-load-vm
    jit-save-context

    ! Make the new context the current one
    ctx-reg swap MOV
    vm-reg vm-context-offset [+] ctx-reg MOV

    ! Load new stack pointer
    ESP ctx-reg context-callstack-top-offset [+] MOV

    ! Windows-specific setup
    ctx-reg jit-update-tib

    ! Load new ds, rs registers
    jit-restore-context ;

: jit-set-context ( -- )
    ! Load context and parameter from datastack
    EAX ds-reg [] MOV
    EAX EAX alien-offset [+] MOV
    EDX ds-reg -4 [+] MOV
    ds-reg 8 SUB

    ! Make the new context active
    EAX jit-switch-context

    ! Windows-specific setup
    ctx-reg jit-update-seh

    ! Twiddle stack for return
    ESP 4 ADD

    ! Store parameter to datastack
    ds-reg 4 ADD
    ds-reg [] EDX MOV ;

[ jit-set-context ] \ (set-context) define-sub-primitive

: jit-start-context ( -- )
    ! Create the new context in return-reg
    jit-load-vm
    jit-save-context
    ESP [] vm-reg MOV
    "new_context" jit-call

    ! Save pointer to quotation and parameter
    EDX ds-reg MOV
    ds-reg 8 SUB

    ! Make the new context active
    EAX jit-switch-context

    ! Push parameter
    EAX EDX -4 [+] MOV
    ds-reg 4 ADD
    ds-reg [] EAX MOV

    ! Windows-specific setup
    jit-install-seh

    ! Push a fake return address
    0 PUSH

    ! Jump to initial quotation
    EAX EDX [] MOV
    jit-jump-quot ;

[ jit-start-context ] \ (start-context) define-sub-primitive

: jit-delete-current-context ( -- )
    jit-load-vm
    jit-load-context
    ESP [] vm-reg MOV
    ESP 4 [+] ctx-reg MOV
    "delete_context" jit-call ;

[
    jit-delete-current-context
    jit-set-context
] \ (set-context-and-delete) define-sub-primitive

: jit-start-context-and-delete ( -- )
    jit-load-vm
    jit-load-context
    ESP [] vm-reg MOV
    ESP 4 [+] ctx-reg MOV
    "reset_context" jit-call

    jit-pop-quot-and-param
    ctx-reg jit-switch-context
    jit-push-param
    jit-jump-quot ;

[
    jit-start-context-and-delete
] \ (start-context-and-delete) define-sub-primitive
