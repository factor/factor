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

: jit-save-context ( -- )
    EAX 0 [] MOV rc-absolute-cell rt-context jit-rel
    ! save stack pointer
    ECX ESP -4 [+] LEA
    EAX [] ECX MOV ;

[
    jit-save-context
    ! pass vm ptr to primitive
    EAX 0 MOV rc-absolute-cell rt-vm jit-rel
    ! call the primitive
    0 CALL rc-relative rt-primitive jit-rel
] jit-primitive jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- )
    EBX ESP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    ESP 4 [+] 0 MOV 0 rc-absolute-cell jit-vm
    ESP [] EBX MOV
    0 CALL "inline_cache_miss" f rc-relative jit-dlsym ;

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
    jit-save-context
    EAX ds-reg -4 [+] MOV
    EDX ds-reg [] MOV
    ds-reg 4 SUB
    ECX EAX MOV
    [ [ ECX EDX ] dip call( dst src -- ) ] dip
    ds-reg [] ECX MOV
    [ JNO ]
    [
        ECX 0 MOV 0 rc-absolute-cell jit-vm
        [ 0 CALL ] dip f rc-relative jit-dlsym
    ]
    jit-conditional ;

[ [ ADD ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    jit-save-context
    ECX ds-reg -4 [+] MOV
    EBX ds-reg [] MOV
    EBX tag-bits get SAR
    ds-reg 4 SUB
    EAX ECX MOV
    EBX IMUL
    ds-reg [] EAX MOV
    [ JNO ]
    [
        EAX ECX MOV
        EAX tag-bits get SAR
        EDX EBX MOV
        ECX 0 MOV 0 rc-absolute-cell jit-vm
        0 CALL "overflow_fixnum_multiply" f rc-relative jit-dlsym
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >>
call
