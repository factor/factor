! Copyright (C) 2007, 2009 Slava Pestov.
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
: safe-reg ( -- reg ) RAX ;
: stack-reg ( -- reg ) RSP ;
: frame-reg ( -- reg ) RBP ;
: ds-reg ( -- reg ) R14 ;
: rs-reg ( -- reg ) R15 ;
: fixnum>slot@ ( -- ) temp0 1 SAR ;
: rex-length ( -- n ) 1 ;

[
    ! load XT
    RDI 0 MOV rc-absolute-cell rt-this jit-rel
    ! save stack frame size
    stack-frame-size PUSH
    ! push XT
    RDI PUSH
    ! alignment
    RSP stack-frame-size 3 bootstrap-cells - SUB
] jit-prolog jit-define

: jit-load-vm ( -- )
    RBP 0 MOV 0 rc-absolute-cell jit-vm ;

: jit-save-context ( -- )
    ! VM pointer must be in RBP already
    RCX RBP [] MOV
    ! save ctx->callstack_top
    RAX RSP -8 [+] LEA
    RCX [] RAX MOV
    ! save ctx->datastack
    RCX 16 [+] ds-reg MOV
    ! save ctx->retainstack
    RCX 24 [+] rs-reg MOV ;

: jit-restore-context ( -- )
    ! VM pointer must be in EBP already
    RCX RBP [] MOV
    ! restore ctx->datastack
    ds-reg RCX 16 [+] MOV
    ! restore ctx->retainstack
    rs-reg RCX 24 [+] MOV ;

[
    jit-load-vm
    ! save ds, rs registers
    jit-save-context
    ! call the primitive
    arg1 RBP MOV
    RAX 0 MOV rc-absolute-cell rt-primitive jit-rel
    RAX CALL
    ! restore ds, rs registers
    jit-restore-context
] jit-primitive jit-define

[
    ! load from stack
    arg1 ds-reg [] MOV
    ! pop stack
    ds-reg bootstrap-cell SUB
    ! load VM pointer
    arg2 0 MOV 0 rc-absolute-cell jit-vm
]
[ arg1 quot-xt-offset [+] CALL ]
[ arg1 quot-xt-offset [+] JMP ]
\ (call) define-sub-primitive*

! Inline cache miss entry points
: jit-load-return-address ( -- )
    RBX RSP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-load-vm
    jit-save-context
    arg1 RBX MOV
    arg2 RBP MOV
    RAX 0 MOV "inline_cache_miss" f rc-absolute-cell jit-dlsym
    RAX CALL
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ RAX CALL ]
[ RAX JMP ]
\ inline-cache-miss define-sub-primitive*

[ jit-inline-cache-miss ]
[ RAX CALL ]
[ RAX JMP ]
\ inline-cache-miss-tail define-sub-primitive*

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
        arg3 RBP MOV
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
        arg3 RBP MOV
        RAX 0 MOV "overflow_fixnum_multiply" f rc-absolute-cell jit-dlsym
        RAX CALL
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >>
call
