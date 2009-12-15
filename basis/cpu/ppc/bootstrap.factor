! Copyright (C) 2007, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.ppc.assembler compiler.codegen.fixup compiler.units
compiler.constants math math.private layouts words vocabs
slots.private locals locals.backend generic.single.private fry ;
FROM: cpu.ppc.assembler => B ;
IN: bootstrap.ppc

4 \ cell set
big-endian on

CONSTANT: ds-reg 13
CONSTANT: rs-reg 14

: factor-area-size ( -- n ) 4 bootstrap-cells ;

: stack-frame ( -- n )
    factor-area-size c-area-size + 4 bootstrap-cells align ;

: next-save ( -- n ) stack-frame bootstrap-cell - ;
: xt-save ( -- n ) stack-frame 2 bootstrap-cells - ;

: jit-conditional* ( test-quot false-quot -- )
    [ '[ bootstrap-cell /i 1 + @ ] ] dip jit-conditional ; inline

: jit-save-context ( -- )
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-context jit-rel
    4 3 0 LWZ
    1 4 0 STW ;

[
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    11 3 profile-count-offset LWZ
    11 11 1 tag-fixnum ADDI
    11 3 profile-count-offset STW
    11 3 word-code-offset LWZ
    11 11 compiled-header-size ADDI
    11 MTCTR
    BCTR
] jit-profiling jit-define

[
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-this jit-rel
    0 MFLR
    1 1 stack-frame SUBI
    3 1 xt-save STW
    stack-frame 3 LI
    3 1 next-save STW
    0 1 lr-save stack-frame + STW
] jit-prolog jit-define

[
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    3 ds-reg 4 STWU
] jit-push jit-define

[
    jit-save-context
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-vm jit-rel
    0 4 LOAD32 rc-absolute-ppc-2/2 rt-primitive jit-rel
    4 MTLR
    BLRL
] jit-primitive jit-define

[ 0 BL rc-relative-ppc-3 rt-xt-pic jit-rel ] jit-word-call jit-define

[
    0 6 LOAD32 rc-absolute-ppc-2/2 rt-here jit-rel
    0 B rc-relative-ppc-3 rt-xt-pic-tail jit-rel
] jit-word-jump jit-define

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    0 3 \ f type-number CMPI
    [ BEQ ] [ 0 B rc-relative-ppc-3 rt-xt jit-rel ] jit-conditional*
    0 B rc-relative-ppc-3 rt-xt jit-rel
] jit-if jit-define

: jit->r ( -- )
    4 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 rs-reg 4 STWU ;

: jit-2>r ( -- )
    4 ds-reg 0 LWZ
    5 ds-reg -4 LWZ
    ds-reg dup 8 SUBI
    rs-reg dup 8 ADDI
    4 rs-reg 0 STW
    5 rs-reg -4 STW ;

: jit-3>r ( -- )
    4 ds-reg 0 LWZ
    5 ds-reg -4 LWZ
    6 ds-reg -8 LWZ
    ds-reg dup 12 SUBI
    rs-reg dup 12 ADDI
    4 rs-reg 0 STW
    5 rs-reg -4 STW
    6 rs-reg -8 STW ;

: jit-r> ( -- )
    4 rs-reg 0 LWZ
    rs-reg dup 4 SUBI
    4 ds-reg 4 STWU ;

: jit-2r> ( -- )
    4 rs-reg 0 LWZ
    5 rs-reg -4 LWZ
    rs-reg dup 8 SUBI
    ds-reg dup 8 ADDI
    4 ds-reg 0 STW
    5 ds-reg -4 STW ;

: jit-3r> ( -- )
    4 rs-reg 0 LWZ
    5 rs-reg -4 LWZ
    6 rs-reg -8 LWZ
    rs-reg dup 12 SUBI
    ds-reg dup 12 ADDI
    4 ds-reg 0 STW
    5 ds-reg -4 STW
    6 ds-reg -8 STW ;

[
    jit->r
    0 BL rc-relative-ppc-3 rt-xt jit-rel
    jit-r>
] jit-dip jit-define

[
    jit-2>r
    0 BL rc-relative-ppc-3 rt-xt jit-rel
    jit-2r>
] jit-2dip jit-define

[
    jit-3>r
    0 BL rc-relative-ppc-3 rt-xt jit-rel
    jit-3r>
] jit-3dip jit-define

[
    0 1 lr-save stack-frame + LWZ
    1 1 stack-frame ADDI
    0 MTLR
] jit-epilog jit-define

[ BLR ] jit-return jit-define

! ! ! Polymorphic inline caches

! Don't touch r6 here; it's used to pass the tail call site
! address for tail PICs

! Load a value from a stack position
[
    4 ds-reg 0 LWZ rc-absolute-ppc-2 rt-untagged jit-rel
] pic-load jit-define

! Tag
: load-tag ( -- )
    4 4 tag-mask get ANDI
    4 4 tag-bits get SLWI ;

[ load-tag ] pic-tag jit-define

! Tuple
[
    3 4 MR
    load-tag
    0 4 tuple type-number tag-fixnum CMPI
    [ BNE ]
    [ 4 3 tuple type-number neg bootstrap-cell + LWZ ]
    jit-conditional*
] pic-tuple jit-define

[
    0 4 0 CMPI rc-absolute-ppc-2 rt-literal jit-rel
] pic-check-tag jit-define

[
    0 5 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    4 0 5 CMP
] pic-check-tuple jit-define

[
    [ BNE ] [ 0 B rc-relative-ppc-3 rt-xt jit-rel ] jit-conditional*
] pic-hit jit-define

! ! ! Megamorphic caches

[
    ! cache = ...
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    ! key = hashcode(class)
    5 4 1 SRAWI
    ! key &= cache.length - 1
    5 5 mega-cache-size get 1 - bootstrap-cell * ANDI
    ! cache += array-start-offset
    3 3 array-start-offset ADDI
    ! cache += key
    3 3 5 ADD
    ! if(get(cache) == class)
    6 3 0 LWZ
    6 0 4 CMP
    [ BNE ]
    [
        ! megamorphic_cache_hits++
        0 4 LOAD32 rc-absolute-ppc-2/2 rt-megamorphic-cache-hits jit-rel
        5 4 0 LWZ
        5 5 1 ADDI
        5 4 0 STW
        ! ... goto get(cache + bootstrap-cell)
        3 3 4 LWZ
        3 3 word-xt-offset LWZ
        3 MTCTR
        BCTR
    ]
    jit-conditional*
    ! fall-through on miss
] mega-lookup jit-define

[
    0 2 LOAD32 rc-absolute-ppc-2/2 rt-xt jit-rel
    2 MTCTR
    BCTR
] callback-stub jit-define

! ! ! Sub-primitives

! Quotations and words
[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    0 4 LOAD32 0 rc-absolute-ppc-2/2 jit-vm
    5 3 quot-xt-offset LWZ
]
[ 5 MTLR BLRL ]
[ 5 MTCTR BCTR ] \ (call) define-sub-primitive*

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 3 word-xt-offset LWZ
]
[ 4 MTLR BLRL ]
[ 4 MTCTR BCTR ] \ (execute) define-sub-primitive*

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 3 word-xt-offset LWZ
    4 MTCTR BCTR
] jit-execute jit-define

! Objects
[
    3 ds-reg 0 LWZ
    3 3 tag-mask get ANDI
    3 3 tag-bits get SLWI
    3 ds-reg 0 STW
] \ tag define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZU
    3 3 2 SRAWI
    4 4 0 0 31 tag-bits get - RLWINM
    4 3 3 LWZX
    3 ds-reg 0 STW
] \ slot define-sub-primitive

! Shufflers
[
    ds-reg dup 4 SUBI
] \ drop define-sub-primitive

[
    ds-reg dup 8 SUBI
] \ 2drop define-sub-primitive

[
    ds-reg dup 12 SUBI
] \ 3drop define-sub-primitive

[
    3 ds-reg 0 LWZ
    3 ds-reg 4 STWU
] \ dup define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    ds-reg dup 8 ADDI
    3 ds-reg 0 STW
    4 ds-reg -4 STW
] \ 2dup define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    5 ds-reg -8 LWZ
    ds-reg dup 12 ADDI
    3 ds-reg 0 STW
    4 ds-reg -4 STW
    5 ds-reg -8 STW
] \ 3dup define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    3 ds-reg 0 STW
] \ nip define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 8 SUBI
    3 ds-reg 0 STW
] \ 2nip define-sub-primitive

[
    3 ds-reg -4 LWZ
    3 ds-reg 4 STWU
] \ over define-sub-primitive

[
    3 ds-reg -8 LWZ
    3 ds-reg 4 STWU
] \ pick define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    4 ds-reg 0 STW
    3 ds-reg 4 STWU
] \ dupd define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    3 ds-reg -4 STW
    4 ds-reg 0 STW
] \ swap define-sub-primitive

[
    3 ds-reg -4 LWZ
    4 ds-reg -8 LWZ
    3 ds-reg -8 STW
    4 ds-reg -4 STW
] \ swapd define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    5 ds-reg -8 LWZ
    4 ds-reg -8 STW
    3 ds-reg -4 STW
    5 ds-reg 0 STW
] \ rot define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    5 ds-reg -8 LWZ
    3 ds-reg -8 STW
    5 ds-reg -4 STW
    4 ds-reg 0 STW
] \ -rot define-sub-primitive

[ jit->r ] \ load-local define-sub-primitive

! Comparisons
: jit-compare ( insn -- )
    t jit-literal
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    4 ds-reg 0 LWZ
    5 ds-reg -4 LWZU
    5 0 4 CMP
    2 swap execute( offset -- ) ! magic number
    \ f type-number 3 LI
    3 ds-reg 0 STW ;

: define-jit-compare ( insn word -- )
    [ [ jit-compare ] curry ] dip define-sub-primitive ;

\ BEQ \ eq? define-jit-compare
\ BGE \ fixnum>= define-jit-compare
\ BLE \ fixnum<= define-jit-compare
\ BGT \ fixnum> define-jit-compare
\ BLT \ fixnum< define-jit-compare

! Math
[
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    4 ds-reg 0 LWZ
    3 3 4 OR
    3 3 tag-mask get ANDI
    \ f type-number 4 LI
    0 3 0 CMPI
    [ BNE ] [ 1 tag-fixnum 4 LI ] jit-conditional*
    4 ds-reg 0 STW
] \ both-fixnums? define-sub-primitive

: jit-math ( insn -- )
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZU
    [ 5 3 4 ] dip execute( dst src1 src2 -- )
    5 ds-reg 0 STW ;

[ \ ADD jit-math ] \ fixnum+fast define-sub-primitive

[ \ SUBF jit-math ] \ fixnum-fast define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZU
    4 4 tag-bits get SRAWI
    5 3 4 MULLW
    5 ds-reg 0 STW
] \ fixnum*fast define-sub-primitive

[ \ AND jit-math ] \ fixnum-bitand define-sub-primitive

[ \ OR jit-math ] \ fixnum-bitor define-sub-primitive

[ \ XOR jit-math ] \ fixnum-bitxor define-sub-primitive

[
    3 ds-reg 0 LWZ
    3 3 NOT
    3 3 tag-mask get XORI
    3 ds-reg 0 STW
] \ fixnum-bitnot define-sub-primitive

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
    [ BGT ] [ 5 7 MR ] jit-conditional*
    5 ds-reg 0 STW
] \ fixnum-shift-fast define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    4 ds-reg 0 LWZ
    5 4 3 DIVW
    6 5 3 MULLW
    7 6 4 SUBF
    7 ds-reg 0 STW
] \ fixnum-mod define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    4 ds-reg 0 LWZ
    5 4 3 DIVW
    5 5 tag-bits get SLWI
    5 ds-reg 0 STW
] \ fixnum/i-fast define-sub-primitive

[
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    5 4 3 DIVW
    6 5 3 MULLW
    7 6 4 SUBF
    5 5 tag-bits get SLWI
    5 ds-reg -4 STW
    7 ds-reg 0 STW
] \ fixnum/mod-fast define-sub-primitive

[
    3 ds-reg 0 LWZ
    3 3 2 SRAWI
    rs-reg 3 3 LWZX
    3 ds-reg 0 STW
] \ get-local define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    3 3 2 SRAWI
    rs-reg 3 rs-reg SUBF
] \ drop-locals define-sub-primitive

! Inline cache miss entry points
: jit-load-return-address ( -- ) 6 MFLR ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    3 6 MR
    0 4 LOAD32 0 rc-absolute-ppc-2/2 jit-vm
    0 5 LOAD32 "inline_cache_miss" f rc-absolute-ppc-2/2 jit-dlsym
    5 MTLR
    BLRL ;

[ jit-load-return-address jit-inline-cache-miss ]
[ 3 MTLR BLRL ]
[ 3 MTCTR BCTR ]
\ inline-cache-miss define-sub-primitive*

[ jit-inline-cache-miss ]
[ 3 MTLR BLRL ]
[ 3 MTCTR BCTR ]
\ inline-cache-miss-tail define-sub-primitive*

! Overflowing fixnum arithmetic
:: jit-overflow ( insn func -- )
    jit-save-context
    3 ds-reg -4 LWZ
    4 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    0 0 LI
    0 MTXER
    6 4 3 insn call( d a s -- )
    6 ds-reg 0 STW
    [ BNO ]
    [
       0 5 LOAD32 0 rc-absolute-ppc-2/2 jit-vm
       0 6 LOAD32 func f rc-absolute-ppc-2/2 jit-dlsym
       6 MTLR
       BLRL
    ]
    jit-conditional* ;

[ [ ADDO. ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUBFO. ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    jit-save-context
    3 ds-reg 0 LWZ
    3 3 tag-bits get SRAWI
    4 ds-reg -4 LWZ
    ds-reg ds-reg 4 SUBI
    0 0 LI
    0 MTXER
    6 3 4 MULLWO.
    6 ds-reg 0 STW
    [ BNO ]
    [
        4 4 tag-bits get SRAWI
        0 5 LOAD32 0 rc-absolute-ppc-2/2 jit-vm
        0 6 LOAD32 "overflow_fixnum_multiply" f rc-absolute-ppc-2/2 jit-dlsym
        6 MTLR
        BLRL
    ]
    jit-conditional*
] \ fixnum* define-sub-primitive

[ "bootstrap.ppc" forget-vocab ] with-compilation-unit
