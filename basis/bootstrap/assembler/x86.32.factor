! Copyright (C) 2007, 2011 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.x86.assembler cpu.x86.assembler.operands layouts
vocabs parser compiler.constants compiler.codegen.relocation
sequences math math.private generic.single.private
threads.private locals ;
IN: bootstrap.x86

4 \ cell set

: leaf-stack-frame-size ( -- n ) 4 bootstrap-cells ;
: signal-handler-stack-frame-size ( -- n ) 12 bootstrap-cells ;
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
: volatile-regs ( -- seq ) { EAX ECX EDX } ;
: nv-reg ( -- reg ) ESI ;
: ds-reg ( -- reg ) ESI ;
: rs-reg ( -- reg ) EDI ;
: link-reg ( -- reg ) EBX ;
: fixnum>slot@ ( -- ) temp0 2 SAR ;
: rex-length ( -- n ) 0 ;
: red-zone-size ( -- n ) 0 ;

: jit-call ( name -- )
    0 CALL f rc-relative rel-dlsym ;

[
    pic-tail-reg 0 MOV 0 rc-absolute-cell rel-here
    0 JMP f rc-relative rel-word-pic-tail
] jit-word-jump jit-define

: jit-load-vm ( -- )
    vm-reg 0 MOV 0 rc-absolute-cell rel-vm ;

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

[
    ! ctx-reg is preserved across the call because it is
    ! non-volatile in the C ABI
    jit-load-vm
    jit-save-context
    ! call the primitive
    ESP [] vm-reg MOV
    0 CALL f f rc-relative rel-dlsym
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

: signal-handler-save-regs ( -- regs )
    { EAX ECX EDX EBX EBP ESI EDI } ;

[
    EAX ds-reg [] MOV
    ds-reg bootstrap-cell SUB
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ (call) define-combinator-primitive

! unwind-native-frames is marked as "special" in vm/quotations.cpp
! so it does not have a standard prolog
[
    ! Load ds and rs registers
    jit-load-vm
    jit-load-context
    jit-restore-context

    ! clear the fault flag
    vm-reg vm-fault-flag-offset [+] 0 MOV

    ! Windows-specific setup
    ctx-reg jit-update-seh

    ! Load arguments
    EAX ESP bootstrap-cell [+] MOV
    EDX ESP 2 bootstrap-cells [+] MOV

    ! Unwind stack frames
    ESP EDX MOV

    jit-jump-quot
] \ unwind-native-frames define-sub-primitive

[
    ESP 2 SUB
    ESP [] FNSTCW
    FNINIT
    AX ESP [] MOV
    ESP 2 ADD
] \ fpu-state define-sub-primitive

[
    ESP stack-frame-size [+] FLDCW
] \ set-fpu-state define-sub-primitive

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
    temp1 0xffffffff CMP f rc-absolute-cell rel-literal
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
    0 CALL rc-relative rel-inline-cache-miss
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
    ! Push a bogus return address so the GC can track this frame back
    ! to the owner
    0 CALL

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

    ! Save ds, rs registers
    jit-load-vm
    jit-save-context

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

: jit-save-quot-and-param ( -- )
    EDX ds-reg MOV
    ds-reg 8 SUB ;

: jit-push-param ( -- )
    EAX EDX -4 [+] MOV
    ds-reg 4 ADD
    ds-reg [] EAX MOV ;

: jit-start-context ( -- )
    ! Create the new context in return-reg
    jit-load-vm
    jit-save-context
    ESP [] vm-reg MOV
    "new_context" jit-call

    jit-save-quot-and-param

    ! Make the new context active
    jit-load-vm
    jit-save-context
    EAX jit-switch-context

    jit-push-param

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

    jit-save-quot-and-param
    ctx-reg jit-switch-context
    jit-push-param

    EAX EDX [] MOV
    jit-jump-quot ;

[
    0 EAX MOVABS rc-absolute rel-safepoint
] \ jit-safepoint jit-define

[
    jit-start-context-and-delete
] \ (start-context-and-delete) define-sub-primitive
