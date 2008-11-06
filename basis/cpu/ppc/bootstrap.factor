! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.ppc.assembler compiler.codegen.fixup compiler.units
compiler.constants math math.private layouts words words.private
vocabs slots.private locals.backend ;
IN: bootstrap.ppc

4 \ cell set
big-endian on

4 jit-code-format set

: ds-reg 30 ;
: rs-reg 31 ;

: factor-area-size ( -- n ) 4 bootstrap-cells ;

: stack-frame ( -- n )
    factor-area-size c-area-size + 4 bootstrap-cells align ;

: next-save ( -- n ) stack-frame bootstrap-cell - ;
: xt-save ( -- n ) stack-frame 2 bootstrap-cells - ;

[
    0 6 LOAD32
    6 dup 0 LWZ
    11 6 profile-count-offset LWZ
    11 11 1 tag-fixnum ADDI
    11 6 profile-count-offset STW
    11 6 word-code-offset LWZ
    11 11 compiled-header-size ADDI
    11 MTCTR
    BCTR
] rc-absolute-ppc-2/2 rt-literal 1 jit-profiling jit-define

[
    0 6 LOAD32
    0 MFLR
    1 1 stack-frame SUBI
    6 1 xt-save STW
    stack-frame 6 LI
    6 1 next-save STW
    0 1 lr-save stack-frame + STW
] rc-absolute-ppc-2/2 rt-label 1 jit-prolog jit-define

[
    0 6 LOAD32
    6 dup 0 LWZ
    6 ds-reg 4 STWU
] rc-absolute-ppc-2/2 rt-literal 1 jit-push-literal jit-define

[
    0 6 LOAD32
    6 ds-reg 4 STWU
] rc-absolute-ppc-2/2 rt-immediate 1 jit-push-immediate jit-define

[
    0 6 LOAD32
    4 1 MR
    6 MTCTR
    BCTR
] rc-absolute-ppc-2/2 rt-primitive 1 jit-primitive jit-define

[ 0 BL ] rc-relative-ppc-3 rt-xt 0 jit-word-call jit-define

[ 0 B ] rc-relative-ppc-3 rt-xt 0 jit-word-jump jit-define

: jit-call-quot ( -- )
    4 3 quot-xt-offset LWZ
    4 MTCTR
    BCTR ;

[
    0 3 LOAD32
    6 ds-reg 0 LWZ
    0 6 \ f tag-number CMPI
    2 BNE
    3 3 4 ADDI
    3 3 0 LWZ
    ds-reg dup 4 SUBI
    jit-call-quot
] rc-absolute-ppc-2/2 rt-literal 1 jit-if-jump jit-define

[
    0 3 LOAD32
    3 3 0 LWZ
    6 ds-reg 0 LWZ
    6 6 1 SRAWI
    3 3 6 ADD
    3 3 array-start-offset LWZ
    ds-reg dup 4 SUBI
    jit-call-quot
] rc-absolute-ppc-2/2 rt-literal 1 jit-dispatch jit-define

[
    0 1 lr-save stack-frame + LWZ
    1 1 stack-frame ADDI
    0 MTLR
] f f f jit-epilog jit-define

[ BLR ] f f f jit-return jit-define

! Sub-primitives

! Quotations and words
[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    jit-call-quot
] f f f \ (call) define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 3 word-xt-offset LWZ
    4 MTCTR
    BCTR
] f f f \ (execute) define-sub-primitive

! Objects
[
    3 ds-reg 0 LWZ
    3 3 tag-mask get ANDI
    3 3 tag-bits get SLWI
    3 ds-reg 0 STW
] f f f \ tag define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZU
    3 3 1 SRAWI
    4 4 0 0 31 tag-bits get - RLWINM
    4 3 3 LWZX
    3 ds-reg 0 STW
] f f f \ slot define-sub-primitive

! Shufflers
[
    ds-reg dup 4 SUBI
] f f f \ drop define-sub-primitive

[
    ds-reg dup 8 SUBI
] f f f \ 2drop define-sub-primitive

[
    ds-reg dup 12 SUBI
] f f f \ 3drop define-sub-primitive

[
    3 ds-reg 0 LWZ
    3 ds-reg 4 STWU
] f f f \ dup define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    ds-reg dup 8 ADDI
    3 ds-reg 0 STW
    4 ds-reg -4 STW
] f f f \ 2dup define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    5 ds-reg -8 LWZ
    ds-reg dup 12 ADDI
    3 ds-reg 0 STW
    4 ds-reg -4 STW
    5 ds-reg -8 STW
] f f f \ 3dup define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    3 ds-reg 0 STW
] f f f \ nip define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 8 SUBI
    3 ds-reg 0 STW
] f f f \ 2nip define-sub-primitive

[
    3 ds-reg -4 LWZ
    3 ds-reg 4 STWU
] f f f \ over define-sub-primitive

[
    3 ds-reg -8 LWZ
    3 ds-reg 4 STWU
] f f f \ pick define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    4 ds-reg 0 STW
    3 ds-reg 4 STWU
] f f f \ dupd define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    3 ds-reg 4 STWU
    4 ds-reg -4 STW
    3 ds-reg -8 STW
] f f f \ tuck define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    3 ds-reg -4 STW
    4 ds-reg 0 STW
] f f f \ swap define-sub-primitive

[
    3 ds-reg -4 LWZ
    4 ds-reg -8 LWZ
    3 ds-reg -8 STW
    4 ds-reg -4 STW
] f f f \ swapd define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    5 ds-reg -8 LWZ
    4 ds-reg -8 STW
    3 ds-reg -4 STW
    5 ds-reg 0 STW
] f f f \ rot define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    5 ds-reg -8 LWZ
    3 ds-reg -8 STW
    5 ds-reg -4 STW
    4 ds-reg 0 STW
] f f f \ -rot define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    3 rs-reg 4 STWU
] f f f \ >r define-sub-primitive

[
    3 rs-reg 0 LWZ
    rs-reg dup 4 SUBI
    3 ds-reg 4 STWU
] f f f \ r> define-sub-primitive

! Comparisons
: jit-compare ( insn -- )
    0 3 LOAD32
    3 3 0 LWZ
    4 ds-reg 0 LWZ
    5 ds-reg -4 LWZU
    5 0 4 CMP
    2 swap execute ! magic number
    \ f tag-number 3 LI
    3 ds-reg 0 STW ;

: define-jit-compare ( insn word -- )
    [ [ jit-compare ] curry rc-absolute-ppc-2/2 rt-literal 1 ] dip
    define-sub-primitive ;

\ BEQ \ eq? define-jit-compare
\ BGE \ fixnum>= define-jit-compare
\ BLE \ fixnum<= define-jit-compare
\ BGT \ fixnum> define-jit-compare
\ BLT \ fixnum< define-jit-compare

! Math
: jit-math ( insn -- )
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZU
    [ 5 3 4 ] dip execute
    5 ds-reg 0 STW ;

[ \ ADD jit-math ] f f f \ fixnum+fast define-sub-primitive

[ \ SUBF jit-math ] f f f \ fixnum-fast define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZU
    4 4 tag-bits get SRAWI
    5 3 4 MULLW
    5 ds-reg 0 STW
] f f f \ fixnum*fast define-sub-primitive

[ \ AND jit-math ] f f f \ fixnum-bitand define-sub-primitive

[ \ OR jit-math ] f f f \ fixnum-bitor define-sub-primitive

[ \ XOR jit-math ] f f f \ fixnum-bitxor define-sub-primitive

[
    3 ds-reg 0 LWZ
    3 3 NOT
    3 3 tag-mask get XORI
    3 ds-reg 0 STW
] f f f \ fixnum-bitnot define-sub-primitive

[
    3 ds-reg 0 LWZ
    3 3 tag-bits get SRAWI
    ds-reg ds-reg 4 SUBI
    4 ds-reg 0 LWZ
    5 4 3 SLW
    6 3 NEG
    7 4 6 SRAW
    7 7 0 0 31 tag-bits get - RLWINM
    0 3 0 CMPI
    2 BGT
    5 7 MR
    5 ds-reg 0 STW
] f f f \ fixnum-shift-fast define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    4 ds-reg 0 LWZ
    5 4 3 DIVW
    6 5 3 MULLW
    7 6 4 SUBF
    7 ds-reg 0 STW
] f f f \ fixnum-mod define-sub-primitive

[
    3 ds-reg 0 LWZ
    3 3 1 SRAWI
    4 4 LI
    4 3 4 SUBF
    rs-reg 3 4 LWZX
    3 ds-reg 0 STW
] f f f \ get-local define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    3 3 1 SRAWI
    rs-reg 3 rs-reg SUBF
] f f f \ drop-locals define-sub-primitive

[ "bootstrap.ppc" forget-vocab ] with-compilation-unit
