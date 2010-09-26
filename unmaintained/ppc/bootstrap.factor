! Copyright (C) 2007, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.ppc.assembler compiler.units compiler.constants math
math.private math.ranges layouts words vocabs slots.private
locals locals.backend generic.single.private fry sequences
threads.private strings.private ;
FROM: cpu.ppc.assembler => B ;
IN: bootstrap.ppc

4 \ cell set
big-endian on

CONSTANT: ds-reg 13
CONSTANT: rs-reg 14
CONSTANT: vm-reg 15
CONSTANT: ctx-reg 16
CONSTANT: nv-reg 17

: jit-call ( string -- )
    0 2 LOAD32 rc-absolute-ppc-2/2 jit-dlsym
    2 MTLR
    BLRL ;

: jit-call-quot ( -- )
    4 3 quot-entry-point-offset LWZ
    4 MTLR
    BLRL ;

: jit-jump-quot ( -- )
    4 3 quot-entry-point-offset LWZ
    4 MTCTR
    BCTR ;

: factor-area-size ( -- n ) 16 ;

: stack-frame ( -- n )
    reserved-size
    factor-area-size +
    16 align ;

: next-save ( -- n ) stack-frame 4 - ;
: xt-save ( -- n ) stack-frame 8 - ;

: param-size ( -- n ) 32 ;

: save-at ( m -- n ) reserved-size + param-size + ;

: save-int ( register offset -- ) [ 1 ] dip save-at STW ;
: restore-int ( register offset -- ) [ 1 ] dip save-at LWZ ;

: save-fp ( register offset -- ) [ 1 ] dip save-at STFD ;
: restore-fp ( register offset -- ) [ 1 ] dip save-at LFD ;

: save-vec ( register offset -- ) save-at 2 LI 2 1 STVXL ;
: restore-vec ( register offset -- ) save-at 2 LI 2 1 LVXL ;

: nv-int-regs ( -- seq ) 13 31 [a,b] ;
: nv-fp-regs ( -- seq ) 14 31 [a,b] ;
: nv-vec-regs ( -- seq ) 20 31 [a,b] ;

: saved-int-regs-size ( -- n ) 96 ;
: saved-fp-regs-size ( -- n ) 144 ;
: saved-vec-regs-size ( -- n ) 208 ;

: callback-frame-size ( -- n )
    reserved-size
    param-size +
    saved-int-regs-size +
    saved-fp-regs-size +
    saved-vec-regs-size +
    4 +
    16 align ;

: old-context-save-offset ( -- n )
    432 save-at ;

[
    ! Save old stack pointer
    11 1 MR

    ! Create stack frame
    0 MFLR
    1 1 callback-frame-size SUBI
    0 1 callback-frame-size lr-save + STW

    ! Save all non-volatile registers
    nv-int-regs [ 4 * save-int ] each-index
    nv-fp-regs [ 8 * 80 + save-fp ] each-index
    nv-vec-regs [ 16 * 224 + save-vec ] each-index

    ! Stick old stack pointer in a non-volatile register so that
    ! callbacks can access their arguments
    nv-reg 11 MR

    ! Load VM into vm-reg
    0 vm-reg LOAD32 rc-absolute-ppc-2/2 rt-vm jit-rel

    ! Save old context
    2 vm-reg vm-context-offset LWZ
    2 1 old-context-save-offset STW

    ! Switch over to the spare context
    2 vm-reg vm-spare-context-offset LWZ
    2 vm-reg vm-context-offset STW

    ! Save C callstack pointer
    1 2 context-callstack-save-offset STW

    ! Load Factor callstack pointer
    1 2 context-callstack-bottom-offset LWZ

    ! Call into Factor code
    0 2 LOAD32 rc-absolute-ppc-2/2 rt-entry-point jit-rel
    2 MTLR
    BLRL

    ! Load VM again, pointlessly
    0 vm-reg LOAD32 rc-absolute-ppc-2/2 rt-vm jit-rel

    ! Load C callstack pointer
    2 vm-reg vm-context-offset LWZ
    1 2 context-callstack-save-offset LWZ

    ! Load old context
    2 1 old-context-save-offset LWZ
    2 vm-reg vm-context-offset STW

    ! Restore non-volatile registers
    nv-vec-regs [ 16 * 224 + restore-vec ] each-index
    nv-fp-regs [ 8 * 80 + restore-fp ] each-index
    nv-int-regs [ 4 * restore-int ] each-index

    ! Tear down stack frame and return
    0 1 callback-frame-size lr-save + LWZ
    1 1 callback-frame-size ADDI
    0 MTLR
    BLR
] callback-stub jit-define

: jit-conditional* ( test-quot false-quot -- )
    [ '[ 4 /i 1 + @ ] ] dip jit-conditional ; inline

: jit-load-context ( -- )
    ctx-reg vm-reg vm-context-offset LWZ ;

: jit-save-context ( -- )
    jit-load-context
    1 ctx-reg context-callstack-top-offset STW
    ds-reg ctx-reg context-datastack-offset STW
    rs-reg ctx-reg context-retainstack-offset STW ;

: jit-restore-context ( -- )
    ds-reg ctx-reg context-datastack-offset LWZ
    rs-reg ctx-reg context-retainstack-offset LWZ ;

[
    0 12 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    11 12 profile-count-offset LWZ
    11 11 1 tag-fixnum ADDI
    11 12 profile-count-offset STW
    11 12 word-code-offset LWZ
    11 11 compiled-header-size ADDI
    11 MTCTR
    BCTR
] jit-profiling jit-define

[
    0 2 LOAD32 rc-absolute-ppc-2/2 rt-this jit-rel
    0 MFLR
    1 1 stack-frame SUBI
    2 1 xt-save STW
    stack-frame 2 LI
    2 1 next-save STW
    0 1 lr-save stack-frame + STW
] jit-prolog jit-define

[
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    3 ds-reg 4 STWU
] jit-push jit-define

[
    jit-save-context
    3 vm-reg MR
    0 4 LOAD32 rc-absolute-ppc-2/2 rt-dlsym jit-rel
    4 MTLR
    BLRL
    jit-restore-context
] jit-primitive jit-define

[ 0 BL rc-relative-ppc-3 rt-entry-point-pic jit-rel ] jit-word-call jit-define

[
    0 6 LOAD32 rc-absolute-ppc-2/2 rt-here jit-rel
    0 B rc-relative-ppc-3 rt-entry-point-pic-tail jit-rel
] jit-word-jump jit-define

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    0 3 \ f type-number CMPI
    [ BEQ ] [ 0 B rc-relative-ppc-3 rt-entry-point jit-rel ] jit-conditional*
    0 B rc-relative-ppc-3 rt-entry-point jit-rel
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
    0 BL rc-relative-ppc-3 rt-entry-point jit-rel
    jit-r>
] jit-dip jit-define

[
    jit-2>r
    0 BL rc-relative-ppc-3 rt-entry-point jit-rel
    jit-2r>
] jit-2dip jit-define

[
    jit-3>r
    0 BL rc-relative-ppc-3 rt-entry-point jit-rel
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

[ 4 4 tag-mask get ANDI ] pic-tag jit-define

[
    3 4 MR
    4 4 tag-mask get ANDI
    0 4 tuple type-number CMPI
    [ BNE ]
    [ 4 3 tuple-class-offset LWZ ]
    jit-conditional*
] pic-tuple jit-define

[
    0 4 0 CMPI rc-absolute-ppc-2 rt-untagged jit-rel
] pic-check-tag jit-define

[
    0 5 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    4 0 5 CMP
] pic-check-tuple jit-define

[
    [ BNE ] [ 0 B rc-relative-ppc-3 rt-entry-point jit-rel ] jit-conditional*
] pic-hit jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- ) 6 MFLR ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    3 6 MR
    4 vm-reg MR
    "inline_cache_miss" jit-call
    jit-load-context
    jit-restore-context ;

[ jit-load-return-address jit-inline-cache-miss ]
[ 3 MTLR BLRL ]
[ 3 MTCTR BCTR ]
\ inline-cache-miss define-combinator-primitive

[ jit-inline-cache-miss ]
[ 3 MTLR BLRL ]
[ 3 MTCTR BCTR ]
\ inline-cache-miss-tail define-combinator-primitive

! ! ! Megamorphic caches

[
    ! class = ...
    3 4 MR
    4 4 tag-mask get ANDI
    4 4 tag-bits get SLWI
    0 4 tuple type-number tag-fixnum CMPI
    [ BNE ]
    [ 4 3 tuple-class-offset LWZ ]
    jit-conditional*
    ! cache = ...
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-literal jit-rel
    ! key = hashcode(class)
    5 4 1 SRAWI
    ! key &= cache.length - 1
    5 5 mega-cache-size get 1 - 4 * ANDI
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
        ! ... goto get(cache + 4)
        3 3 4 LWZ
        3 3 word-entry-point-offset LWZ
        3 MTCTR
        BCTR
    ]
    jit-conditional*
    ! fall-through on miss
] mega-lookup jit-define

! ! ! Sub-primitives

! Quotations and words
[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
]
[ jit-call-quot ]
[ jit-jump-quot ] \ (call) define-combinator-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 3 word-entry-point-offset LWZ
]
[ 4 MTLR BLRL ]
[ 4 MTCTR BCTR ] \ (execute) define-combinator-primitive

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 3 word-entry-point-offset LWZ
    4 MTCTR BCTR
] jit-execute jit-define

! Special primitives
[
    nv-reg 3 MR

    3 vm-reg MR
    "begin_callback" jit-call

    jit-load-context
    jit-restore-context

    ! Call quotation
    3 nv-reg MR
    jit-call-quot

    jit-save-context

    3 vm-reg MR
    "end_callback" jit-call
] \ c-to-factor define-sub-primitive

[
    ! Unwind stack frames
    1 4 MR

    ! Load VM pointer into vm-reg, since we're entering from
    ! C code
    0 vm-reg LOAD32 0 rc-absolute-ppc-2/2 jit-vm

    ! Load ds and rs registers
    jit-load-context
    jit-restore-context

    ! We have changed the stack; load return address again
    0 1 lr-save LWZ
    0 MTLR

    ! Call quotation
    jit-call-quot
] \ unwind-native-frames define-sub-primitive

[
    ! Load callstack object
    6 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    ! Get ctx->callstack_bottom
    jit-load-context
    3 ctx-reg context-callstack-bottom-offset LWZ
    ! Get top of callstack object -- 'src' for memcpy
    4 6 callstack-top-offset ADDI
    ! Get callstack length, in bytes --- 'len' for memcpy
    5 6 callstack-length-offset LWZ
    5 5 tag-bits get SRAWI
    ! Compute new stack pointer -- 'dst' for memcpy
    3 5 3 SUBF
    ! Install new stack pointer
    1 3 MR
    ! Call memcpy; arguments are now in the correct registers
    1 1 -64 STWU
    "factor_memcpy" jit-call
    1 1 0 LWZ
    ! Return with new callstack
    0 1 lr-save LWZ
    0 MTLR
    BLR
] \ set-callstack define-sub-primitive

[
    jit-save-context
    4 vm-reg MR
    "lazy_jit_compile" jit-call
]
[ jit-call-quot ]
[ jit-jump-quot ]
\ lazy-jit-compile define-combinator-primitive

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

[
    ! load string index from stack
    3 ds-reg -4 LWZ
    3 3 tag-bits get SRAWI
    ! load string from stack
    4 ds-reg 0 LWZ
    ! load character
    4 4 string-offset ADDI
    3 3 4 LBZX
    3 3 tag-bits get SLWI
    ! store character to stack
    ds-reg ds-reg 4 SUBI
    3 ds-reg 0 STW
] \ string-nth-fast define-sub-primitive

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

! Overflowing fixnum arithmetic
:: jit-overflow ( insn func -- )
    ds-reg ds-reg 4 SUBI
    jit-save-context
    3 ds-reg 0 LWZ
    4 ds-reg 4 LWZ
    0 0 LI
    0 MTXER
    6 4 3 insn call( d a s -- )
    6 ds-reg 0 STW
    [ BNO ]
    [
        5 vm-reg MR
        func jit-call
    ]
    jit-conditional* ;

[ [ ADDO. ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUBFO. ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    ds-reg ds-reg 4 SUBI
    jit-save-context
    3 ds-reg 0 LWZ
    3 3 tag-bits get SRAWI
    4 ds-reg 4 LWZ
    0 0 LI
    0 MTXER
    6 3 4 MULLWO.
    6 ds-reg 0 STW
    [ BNO ]
    [
        4 4 tag-bits get SRAWI
        5 vm-reg MR
        "overflow_fixnum_multiply" jit-call
    ]
    jit-conditional*
] \ fixnum* define-sub-primitive

! Contexts
: jit-switch-context ( reg -- )
    ! Save ds, rs registers
    jit-save-context

    ! Make the new context the current one
    ctx-reg swap MR
    ctx-reg vm-reg vm-context-offset STW

    ! Load new stack pointer
    1 ctx-reg context-callstack-top-offset LWZ

    ! Load new ds, rs registers
    jit-restore-context ;

: jit-pop-context-and-param ( -- )
    3 ds-reg 0 LWZ
    3 3 alien-offset LWZ
    4 ds-reg -4 LWZ
    ds-reg ds-reg 8 SUBI ;

: jit-push-param ( -- )
    ds-reg ds-reg 4 ADDI
    4 ds-reg 0 STW ;

: jit-set-context ( -- )
    jit-pop-context-and-param
    3 jit-switch-context
    jit-push-param ;

[ jit-set-context ] \ (set-context) define-sub-primitive

: jit-pop-quot-and-param ( -- )
    3 ds-reg 0 LWZ
    4 ds-reg -4 LWZ
    ds-reg ds-reg 8 SUBI ;

: jit-start-context ( -- )
    ! Create the new context in return-reg
    3 vm-reg MR
    "new_context" jit-call
    6 3 MR

    jit-pop-quot-and-param

    6 jit-switch-context

    jit-push-param

    jit-jump-quot ;

[ jit-start-context ] \ (start-context) define-sub-primitive

: jit-delete-current-context ( -- )
    jit-load-context
    3 vm-reg MR
    4 ctx-reg MR
    "delete_context" jit-call ;

[
    jit-delete-current-context
    jit-set-context
] \ (set-context-and-delete) define-sub-primitive

[
    jit-delete-current-context
    jit-start-context
] \ (start-context-and-delete) define-sub-primitive

[ "bootstrap.ppc" forget-vocab ] with-compilation-unit
