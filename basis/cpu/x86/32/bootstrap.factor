! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
cpu.x86.assembler cpu.x86.assembler.operands layouts
vocabs parser compiler.constants sequences math math.private
generic.single.private ;
IN: bootstrap.x86

4 \ cell set

: stack-frame-size ( -- n ) 8 bootstrap-cells ;
: shift-arg ( -- reg ) ECX ;
: div-arg ( -- reg ) EAX ;
: mod-arg ( -- reg ) EDX ;
: arg1 ( -- reg ) EAX ;
: arg2 ( -- reg ) EDX ;
: temp0 ( -- reg ) EAX ;
: temp1 ( -- reg ) EDX ;
: temp2 ( -- reg ) ECX ;
: temp3 ( -- reg ) EBX ;
: safe-reg ( -- reg ) EAX ;
: stack-reg ( -- reg ) ESP ;
: ds-reg ( -- reg ) ESI ;
: rs-reg ( -- reg ) EDI ;
: fixnum>slot@ ( -- ) temp0 2 SAR ;
: rex-length ( -- n ) 0 ;

[
    ! save stack frame size
    stack-frame-size PUSH
    ! push XT
    0 PUSH rc-absolute-cell rt-this jit-rel
    ! alignment
    ESP stack-frame-size 3 bootstrap-cells - SUB
] jit-prolog jit-define

: jit-load-vm ( -- )
    EBP 0 MOV 0 rc-absolute-cell jit-vm ;

: jit-save-context ( -- )
    ! VM pointer must be in EBP already
    ECX EBP [] MOV
    ! save ctx->callstack_top
    EAX ESP -4 [+] LEA
    ECX [] EAX MOV
    ! save ctx->datastack
    ECX 8 [+] ds-reg MOV
    ! save ctx->retainstack
    ECX 12 [+] rs-reg MOV ;

: jit-restore-context ( -- )
    ! VM pointer must be in EBP already
    ECX EBP [] MOV
    ! restore ctx->datastack
    ds-reg ECX 8 [+] MOV
    ! restore ctx->retainstack
    rs-reg ECX 12 [+] MOV ;

[
    jit-load-vm
    ! save ds, rs registers
    jit-save-context
    ! call the primitive
    ESP [] EBP MOV
    0 CALL rc-relative rt-primitive jit-rel
    ! restore ds, rs registers
    jit-restore-context
] jit-primitive jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- )
    EBX ESP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-load-vm
    jit-save-context
    ESP 4 [+] EBP MOV
    ESP [] EBX MOV
    0 CALL "inline_cache_miss" f rc-relative jit-dlsym
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ EAX CALL ]
[ EAX JMP ]
\ inline-cache-miss define-sub-primitive*

[ jit-inline-cache-miss ]
[ EAX CALL ]
[ EAX JMP ]
\ inline-cache-miss-tail define-sub-primitive*

! Overflowing fixnum arithmetic
: jit-overflow ( insn func -- )
    ds-reg 4 SUB
    jit-load-vm
    jit-save-context
    EAX ds-reg [] MOV
    EDX ds-reg 4 [+] MOV
    ECX EAX MOV
    [ [ ECX EDX ] dip call( dst src -- ) ] dip
    ds-reg [] ECX MOV
    [ JNO ]
    [
        ECX EBP MOV
        [ 0 CALL ] dip f rc-relative jit-dlsym
    ]
    jit-conditional ;

[ [ ADD ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    ds-reg 4 SUB
    jit-load-vm
    jit-save-context
    ECX ds-reg [] MOV
    EAX ECX MOV
    EBX ds-reg 4 [+] MOV
    EBX tag-bits get SAR
    EBX IMUL
    ds-reg [] EAX MOV
    [ JNO ]
    [
        EAX ECX MOV
        EAX tag-bits get SAR
        EDX EBX MOV
        ECX EBP MOV
        0 CALL "overflow_fixnum_multiply" f rc-relative jit-dlsym
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >>
call
