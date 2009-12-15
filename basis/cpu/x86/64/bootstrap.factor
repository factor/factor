! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel namespaces system
layouts vocabs parser compiler.constants math math.private
cpu.x86.assembler cpu.x86.assembler.operands sequences
generic.single.private ;
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

: jit-save-context ( -- )
    temp0 0 MOV rc-absolute-cell rt-context jit-rel
    temp0 temp0 [] MOV
    ! save stack pointer
    temp1 stack-reg bootstrap-cell neg [+] LEA
    temp0 [] temp1 MOV ;

[
    jit-save-context
    ! load vm ptr
    arg1 0 MOV rc-absolute-cell rt-vm jit-rel
    ! load XT
    temp1 0 MOV rc-absolute-cell rt-primitive jit-rel
    ! go
    temp1 CALL
] jit-primitive jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- )
    RBX RSP stack-frame-size bootstrap-cell - [+] MOV ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    arg1 RBX MOV
    arg2 0 MOV 0 rc-absolute-cell jit-vm
    0 CALL "inline_cache_miss" f rc-relative jit-dlsym ;

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
    jit-save-context
    arg1 ds-reg bootstrap-cell neg [+] MOV
    arg2 ds-reg [] MOV
    ds-reg bootstrap-cell SUB
    arg3 arg1 MOV
    [ [ arg3 arg2 ] dip call ] dip
    ds-reg [] arg3 MOV
    [ JNO ]
    [
        arg3 0 MOV 0 rc-absolute-cell jit-vm
        [ 0 CALL ] dip f rc-relative jit-dlsym
    ]
    jit-conditional ; inline

[ [ ADD ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUB ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    jit-save-context
    RCX ds-reg bootstrap-cell neg [+] MOV
    RBX ds-reg [] MOV
    RBX tag-bits get SAR
    ds-reg bootstrap-cell SUB
    RAX RCX MOV
    RBX IMUL
    ds-reg [] RAX MOV
    [ JNO ]
    [
        arg1 RCX MOV
        arg1 tag-bits get SAR
        arg2 RBX MOV
        arg3 0 MOV 0 rc-absolute-cell jit-vm
        0 CALL "overflow_fixnum_multiply" f rc-relative jit-dlsym
    ]
    jit-conditional
] \ fixnum* define-sub-primitive

<< "vocab:cpu/x86/bootstrap.factor" parse-file suffix! >>
call
