! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system layouts vocabs parser compiler.constants math
math.private cpu.x86.assembler cpu.x86.assembler.operands
sequences generic.single.private ;
IN: bootstrap.x86

8 \ cell set

: shift-arg ( -- reg ) RCX ;
: div-arg ( -- reg ) RAX ;
: mod-arg ( -- reg ) RDX ;
: temp0 ( -- reg ) RDI ;
: temp1 ( -- reg ) RSI ;
: temp2 ( -- reg ) RDX ;
: temp3 ( -- reg ) RBX ;
: return-reg ( -- reg ) RAX ;
: safe-reg ( -- reg ) RAX ;
: stack-reg ( -- reg ) RSP ;
: frame-reg ( -- reg ) RBP ;
: vm-reg ( -- reg ) R12 ;
: ctx-reg ( -- reg ) R13 ;
: ds-reg ( -- reg ) R14 ;
: rs-reg ( -- reg ) R15 ;
: fixnum>slot@ ( -- ) temp0 1 SAR ;
: rex-length ( -- n ) 1 ;

[
    ! load XT
    safe-reg 0 MOV rc-absolute-cell rt-this jit-rel
    ! save stack frame size
    stack-frame-size PUSH
    ! push XT
    safe-reg PUSH
    ! alignment
    RSP stack-frame-size 3 bootstrap-cells - SUB
] jit-prolog jit-define

: jit-load-vm ( -- )
    vm-reg 0 MOV 0 rc-absolute-cell jit-vm ;

: jit-load-context ( -- )
    ! VM pointer must be in vm-reg already
    ctx-reg vm-reg vm-context-offset [+] MOV ;

: jit-save-context ( -- )
    jit-load-context
    safe-reg RSP -8 [+] LEA
    ctx-reg context-callstack-top-offset [+] safe-reg MOV
    ctx-reg context-datastack-offset [+] ds-reg MOV
    ctx-reg context-retainstack-offset [+] rs-reg MOV ;

: jit-restore-context ( -- )
    jit-load-context
    ds-reg ctx-reg context-datastack-offset [+] MOV
    rs-reg ctx-reg context-retainstack-offset [+] MOV ;

[
    jit-load-vm
    jit-save-context
    ! call the primitive
    arg1 vm-reg MOV
    RAX 0 MOV rc-absolute-cell rt-primitive jit-rel
    RAX CALL
    jit-restore-context
] jit-primitive jit-define

[
    jit-load-vm
    jit-restore-context
    ! save ctx->callstack_bottom
    safe-reg stack-reg stack-frame-size 8 - [+] LEA
    ctx-reg context-callstack-bottom-offset [+] safe-reg MOV
    ! call the quotation
    arg1 quot-xt-offset [+] CALL
    jit-save-context
] \ c-to-factor define-sub-primitive

[
    arg1 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
]
[ arg1 quot-xt-offset [+] CALL ]
[ arg1 quot-xt-offset [+] JMP ]
\ (call) define-combinator-primitive

[
    ! Clear x87 stack, but preserve rounding mode and exception flags
    RSP 2 SUB
    RSP [] FNSTCW
    FNINIT
    RSP [] FLDCW

    ! Unwind stack frames
    RSP arg2 MOV

    ! Load ds and rs registers
    jit-load-vm
    jit-restore-context

    ! Call quotation
    arg1 quot-xt-offset [+] JMP
] \ unwind-native-frames define-sub-primitive

[
    ! Load callstack object
    arg4 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    ! Get ctx->callstack_bottom
    jit-load-vm
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
    safe-reg 0 MOV "memcpy" f rc-absolute-cell jit-dlsym
    safe-reg CALL
    ! Return with new callstack
    0 RET
] \ set-callstack define-sub-primitive

[
    jit-load-vm
    jit-save-context
    arg2 vm-reg MOV
    safe-reg 0 MOV "lazy_jit_compile" f rc-absolute-cell jit-dlsym
    safe-reg CALL
]
[ return-reg quot-xt-offset [+] CALL ]
[ return-reg quot-xt-offset [+] JMP ]
\ lazy-jit-compile define-combinator-primitive

! Inline cache miss entry points
: jit-load-return-address ( -- )
    RBX RSP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-load-vm
    jit-save-context
    arg1 RBX MOV
    arg2 vm-reg MOV
    RAX 0 MOV "inline_cache_miss" f rc-absolute-cell jit-dlsym
    RAX CALL
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ RAX CALL ]
[ RAX JMP ]
\ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ]
[ RAX CALL ]
[ RAX JMP ]
\ inline-cache-miss-tail define-combinator-primitive

! Overflowing fixnum arithmetic
: jit-overflow ( insn func -- )
    ds-reg 8 SUB
    jit-load-vm
    jit-save-context
    arg1 ds-reg [] MOV
    arg2 ds-reg 8 [+] MOV
    arg3 arg1 MOV
    [ [ arg3 arg2 ] dip call ] dip
    ds-reg [] arg3 MOV
    [ JNO ]
    [
        arg3 vm-reg MOV
        RAX 0 MOV f rc-absolute-cell jit-dlsym
        RAX CALL
    ]
    jit-conditional ; inline

[ [ ADD ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    ds-reg 8 SUB
    jit-load-vm
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
        RAX 0 MOV "overflow_fixnum_multiply" f rc-absolute-cell jit-dlsym
        RAX CALL
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >>
call
