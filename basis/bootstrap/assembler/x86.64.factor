! Copyright (C) 2007, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private compiler.codegen.relocation
compiler.constants cpu.x86.assembler cpu.x86.assembler.operands
generic.single.private kernel kernel.private layouts math
math.private namespaces threads.private ;
IN: bootstrap.assembler.x86

8 \ cell set

: shift-arg ( -- reg ) RCX ;
: div-arg ( -- reg ) RAX ;
: mod-arg ( -- reg ) RDX ;
: temp0 ( -- reg ) RAX ;
: temp1 ( -- reg ) RCX ;
: temp2 ( -- reg ) RDX ;
: temp3 ( -- reg ) RBX ;
: pic-tail-reg ( -- reg ) RBX ;
: return-reg ( -- reg ) RAX ;
: nv-reg ( -- reg ) RBX ;
: stack-reg ( -- reg ) RSP ;
: frame-reg ( -- reg ) RBP ;
: link-reg ( -- reg ) R11 ;
: ctx-reg ( -- reg ) R12 ;
: vm-reg ( -- reg ) R13 ;
: ds-reg ( -- reg ) R14 ;
: rs-reg ( -- reg ) R15 ;
: fixnum>slot@ ( -- ) temp0 1 SAR ;
: rex-length ( -- n ) 1 ;

: jit-call ( name -- )
    RAX 0 MOV f rc-absolute-cell rel-dlsym
    RAX CALL ;

:: jit-call-1arg ( arg1s name -- )
    arg1 arg1s MOV
    name jit-call ;

:: jit-call-2arg ( arg1s arg2s name -- )
    arg1 arg1s MOV
    arg2 arg2s MOV
    name jit-call ;

[
    pic-tail-reg 5 [RIP+] LEA
    0 JMP f rc-relative rel-word-pic-tail
] JIT-WORD-JUMP jit-define

: jit-load-vm ( -- )
    ! no-op on x86-64. in factor contexts vm-reg always contains the
    ! vm pointer.
    ;

: jit-load-context ( -- )
    ctx-reg vm-reg vm-context-offset [+] MOV ;

: jit-save-context ( -- )
    jit-load-context
    ! The reason for -8 I think is because we are anticipating a CALL
    ! instruction. After the call instruction, the contexts frame_top
    ! will point to the origin jump address.
    R11 RSP -8 [+] LEA
    ctx-reg context-callstack-top-offset [+] R11 MOV
    ctx-reg context-datastack-offset [+] ds-reg MOV
    ctx-reg context-retainstack-offset [+] rs-reg MOV ;

! ctx-reg must already have been loaded
: jit-restore-context ( -- )
    ds-reg ctx-reg context-datastack-offset [+] MOV
    rs-reg ctx-reg context-retainstack-offset [+] MOV ;

[
    ! ctx-reg is preserved across the call because it is non-volatile
    ! in the C ABI
    jit-save-context
    ! call the primitive
    arg1 vm-reg MOV
    RAX 0 MOV f f rc-absolute-cell rel-dlsym
    RAX CALL
    jit-restore-context
] JIT-PRIMITIVE jit-define

: jit-jump-quot ( -- )
    arg1 quot-entry-point-offset [+] JMP ;

: jit-call-quot ( -- ) arg1 quot-entry-point-offset [+] CALL ;

: signal-handler-save-regs ( -- regs )
    { RAX RCX RDX RBX RBP RSI RDI R8 R9 R10 R11 R12 R13 R14 R15 } ;

[
    arg1 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ (call) define-combinator-primitive

[
    jit-save-context
    arg2 vm-reg MOV
    "lazy_jit_compile" jit-call
    arg1 return-reg MOV
]
[ return-reg quot-entry-point-offset [+] CALL ]
[ jit-jump-quot ]
\ lazy-jit-compile define-combinator-primitive

[
    temp2 0 MOV f rc-absolute-cell rel-literal
    temp1 temp2 CMP
] PIC-CHECK-TUPLE jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- )
    pic-tail-reg RSP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    arg1 pic-tail-reg MOV
    arg2 vm-reg MOV
    RAX 0 MOV rc-absolute-cell rel-inline-cache-miss
    RAX CALL
    jit-load-context
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ return-reg CALL ]
[ return-reg JMP ]
\ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ]
[ return-reg CALL ]
[ return-reg JMP ]
\ inline-cache-miss-tail define-combinator-primitive

! Overflowing fixnum arithmetic
: jit-overflow ( insn func -- )
    ds-reg 8 SUB
    jit-save-context
    arg1 ds-reg [] MOV
    arg2 ds-reg 8 [+] MOV
    arg3 arg1 MOV
    [ [ arg3 arg2 ] dip call ] dip
    ds-reg [] arg3 MOV
    [ JNO ]
    [ arg3 vm-reg MOV jit-call ]
    jit-conditional ; inline

! Contexts
: jit-switch-context ( reg -- )
    ! Push a bogus return address so the GC can track this frame back
    ! to the owner
    0 CALL

    ! Make the new context the current one
    ctx-reg swap MOV
    vm-reg vm-context-offset [+] ctx-reg MOV

    ! Load new stack pointer
    RSP ctx-reg context-callstack-top-offset [+] MOV

    ! Load new ds, rs registers
    jit-restore-context

    ctx-reg jit-update-tib ;

: jit-pop-context-and-param ( -- )
    arg1 ds-reg [] MOV
    arg1 arg1 alien-offset [+] MOV
    arg2 ds-reg -8 [+] MOV
    ds-reg 16 SUB ;

: jit-push-param ( -- )
    ds-reg 8 ADD
    ds-reg [] arg2 MOV ;

: jit-set-context ( -- )
    jit-pop-context-and-param
    jit-save-context
    arg1 jit-switch-context
    RSP 8 ADD
    jit-push-param ;

: jit-pop-quot-and-param ( -- )
    arg1 ds-reg [] MOV
    arg2 ds-reg -8 [+] MOV
    ds-reg 16 SUB ;

: jit-start-context ( -- )
    ! Create the new context in return-reg. Have to save context
    ! twice, first before calling new_context() which may GC,
    ! and again after popping the two parameters from the stack.
    jit-save-context
    vm-reg "new_context" jit-call-1arg

    jit-pop-quot-and-param
    jit-save-context
    return-reg jit-switch-context
    jit-push-param
    jit-jump-quot ;

: jit-delete-current-context ( -- )
    vm-reg "delete_context" jit-call-1arg ;

! Resets the active context and instead the passed in quotation
! becomes the new code that it executes.
: jit-start-context-and-delete ( -- )
    ! Updates the context to match the values in the data and retain
    ! stack registers. reset_context can GC.
    jit-save-context

    ! Resets the context. The top two ds items are preserved.
    vm-reg "reset_context" jit-call-1arg

    ! Switches to the same context I think.
    ctx-reg jit-switch-context

    ! Pops the quotation from the stack and puts it in arg1.
    arg1 ds-reg [] MOV
    ds-reg 8 SUB

    ! Jump to quotation arg1
    jit-jump-quot ;

[
    0 [RIP+] EAX MOV rc-relative rel-safepoint
] JIT-SAFEPOINT jit-define

! # All x86.64 subprimitives
{
    ! ## Contexts
    { (set-context) [ jit-set-context ] }
    { (set-context-and-delete) [
        jit-delete-current-context
        jit-set-context
    ] }
    { (start-context) [ jit-start-context ] }
    { (start-context-and-delete) [ jit-start-context-and-delete ] }

    ! ## Entry points
    { c-to-factor [
        arg2 arg1 MOV
        vm-reg "begin_callback" jit-call-1arg

        ! call the quotation
        arg1 return-reg MOV
        jit-call-quot

        vm-reg "end_callback" jit-call-1arg
    ] }
    { unwind-native-frames [
        ! unwind-native-frames is marked as "special" in
        ! vm/quotations.cpp so it does not have a standard prolog
        ! Unwind stack frames
        RSP arg2 MOV

        ! Load VM pointer into vm-reg, since we're entering from
        ! C code
        vm-reg 0 MOV 0 rc-absolute-cell rel-vm

        ! Load ds and rs registers
        jit-load-context
        jit-restore-context

        ! Clear the fault flag
        vm-reg vm-fault-flag-offset [+] 0 MOV

        ! Call quotation
        jit-jump-quot
    ] }

    ! ## Math
    { fixnum+ [ [ ADD ] "overflow_fixnum_add" jit-overflow ] }
    { fixnum- [ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] }
    { fixnum* [
        ds-reg 8 SUB
        jit-save-context
        RCX ds-reg [] MOV
        RBX ds-reg 8 [+] MOV
        RBX tag-bits get SAR
        RAX RCX MOV
        RBX IMUL
        ds-reg [] RAX MOV
        [ JNO ]
        [
            arg1 RCX MOV
            arg1 tag-bits get SAR
            arg2 RBX MOV
            arg3 vm-reg MOV
            "overflow_fixnum_multiply" jit-call
        ]
        jit-conditional
    ] }

    ! ## Misc
    { fpu-state [
        RSP 2 SUB
        RSP [] FNSTCW
        FNINIT
        return-reg 16-bit-version-of RSP [] MOV
        RSP 2 ADD
    ] }
    { set-fpu-state [
        RSP 2 SUB
        RSP [] arg1 16-bit-version-of MOV
        RSP [] FLDCW
        RSP 2 ADD
    ] }
    { set-callstack [
        ! Load callstack object
        arg4 ds-reg [] MOV
        ds-reg bootstrap-cell SUB
        ! Get ctx->callstack_bottom
        jit-load-context
        arg1 ctx-reg context-callstack-bottom-offset [+] MOV
        ! Get top of callstack object -- 'src' for memcpy
        arg2 arg4 callstack-top-offset [+] LEA
        ! Get callstack length, in bytes --- 'len' for memcpy
        arg3 arg4 callstack-length-offset [+] MOV
        arg3 tag-bits get SHR
        ! Compute new stack pointer -- 'dst' for memcpy
        arg1 arg3 SUB
        ! Install new stack pointer
        RSP arg1 MOV
        ! Call memcpy; arguments are now in the correct registers
        ! Create register shadow area for Win64
        RSP 32 SUB
        "factor_memcpy" jit-call
        ! Tear down register shadow area
        RSP 32 ADD
        ! Return with new callstack
        0 RET
    ] }
} define-sub-primitives
