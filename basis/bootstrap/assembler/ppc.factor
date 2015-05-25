! Copyright (C) 2011 Erik Charlebois
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.ppc.assembler compiler.units compiler.constants math
math.private math.ranges layouts words vocabs slots.private
locals locals.backend generic.single.private fry sequences
threads.private strings.private ;
FROM: cpu.ppc.assembler => B ;
IN: bootstrap.ppc

: jit-call ( string -- )
    dup
    0 swap jit-load-dlsym
    0 MTLR
    jit-load-dlsym-toc
    BLRL ;

: jit-call-quot ( -- )
    4 quot-entry-point-offset LI
    4 3 4 jit-load-cell-x
    4 MTLR
    BLRL ;

: jit-jump-quot ( -- )
    4 quot-entry-point-offset LI
    4 3 4 jit-load-cell-x
    4 MTCTR
    BCTR ;

: stack-frame ( -- n )
    reserved-size factor-area-size + 16 align ;

: save-at ( m -- n ) reserved-size + param-size + ;

: save-int ( reg off -- ) [ 1 ] dip save-at jit-save-int ;
: save-fp  ( reg off -- ) [ 1 ] dip save-at STFD ;
: save-vec ( reg offt -- ) save-at 11 swap LI 11 1 STVXL ;
: restore-int ( reg off -- ) [ 1 ] dip save-at jit-load-int ;
: restore-fp  ( reg off -- ) [ 1 ] dip save-at LFD ;
: restore-vec ( reg offt -- ) save-at 11 swap LI 11 1 LVXL ;

! Stop using intervals here.
: nv-fp-regs  ( -- seq ) 14 31 [a,b] ;
: nv-vec-regs ( -- seq ) 20 31 [a,b] ;

: saved-fp-regs-size  ( -- n ) 144 ;
: saved-vec-regs-size ( -- n ) 192 ;

: callback-frame-size ( -- n )
    reserved-size
    param-size +
    saved-int-regs-size +
    saved-fp-regs-size +
    saved-vec-regs-size +
    16 align ;

: old-context-save-offset ( -- n )
    cell-size 20 * saved-fp-regs-size + saved-vec-regs-size + save-at ;

[
    ! Save old stack pointer
    11 1 MR

    0 MFLR                                           ! Get return address
    0 1 lr-save jit-save-cell                        ! Stash return address
    1 1 callback-frame-size neg jit-save-cell-update ! Bump stack pointer and set back chain

    ! Save all non-volatile registers
    nv-int-regs [ cell-size * save-int ] each-index
    nv-fp-regs [ 8 * saved-int-regs-size + save-fp  ] each-index
    ! nv-vec-regs [ 16 * saved-int-regs-size saved-fp-regs-size + + save-vec ] each-index

    ! Stick old stack pointer in the frame register so callbacks
    ! can access their arguments
    frame-reg 11 MR

    ! Load VM into vm-reg
    vm-reg jit-load-vm-arg

    ! Save old context
    0 vm-reg vm-context-offset jit-load-cell
    0 1 old-context-save-offset jit-save-cell

    ! Switch over to the spare context
    11 vm-reg vm-spare-context-offset jit-load-cell
    11 vm-reg vm-context-offset jit-save-cell

    ! Save C callstack pointer and load Factor callstack
    1 11 context-callstack-save-offset jit-save-cell
    1 11 context-callstack-bottom-offset jit-load-cell

    ! Load new data and retain stacks
    rs-reg 11 context-retainstack-offset jit-load-cell
    ds-reg 11 context-datastack-offset jit-load-cell

    ! Call into Factor code
    0 jit-load-entry-point-arg
    0 MTLR
    BLRL

    ! Load VM again, pointlessly
    vm-reg jit-load-vm-arg

    ! Load C callstack pointer
    11 vm-reg vm-context-offset jit-load-cell
    1 11 context-callstack-save-offset jit-load-cell

    ! Load old context
    0 1 old-context-save-offset jit-load-cell
    0 vm-reg vm-context-offset jit-save-cell

    ! Restore non-volatile registers
    ! nv-vec-regs [ 16 * saved-int-regs-size saved-float-regs-size + + restore-vec ] each-index
    nv-fp-regs [ 8 * saved-int-regs-size + restore-fp ] each-index
    nv-int-regs [ cell-size * restore-int ] each-index

    1 1 callback-frame-size ADDI ! Bump stack back up
    0 1 lr-save jit-load-cell    ! Fetch return address
    0 MTLR                       ! Set up return
    BLR                          ! Branch back
] callback-stub jit-define

: jit-conditional* ( test-quot false-quot -- )
    [ '[ 4 + @ ] ] dip jit-conditional ; inline

: jit-load-context ( -- )
    ctx-reg vm-reg vm-context-offset jit-load-cell ;

: jit-save-context ( -- )
    jit-load-context
    1 ctx-reg context-callstack-top-offset jit-save-cell
    ds-reg ctx-reg context-datastack-offset jit-save-cell
    rs-reg ctx-reg context-retainstack-offset jit-save-cell ;

: jit-restore-context ( -- )
    ds-reg ctx-reg context-datastack-offset jit-load-cell
    rs-reg ctx-reg context-retainstack-offset jit-load-cell ;

[
    12 jit-load-literal-arg
    0 profile-count-offset LI
    11 12 0 jit-load-cell-x
    11 11 1 tag-fixnum ADDI
    11 12 0 jit-save-cell-x
    0 word-code-offset LI
    11 12 0 jit-load-cell-x
    11 11 compiled-header-size ADDI
    11 MTCTR
    BCTR
] jit-profiling jit-define

[
    0 MFLR
    0 1 lr-save jit-save-cell
    0 jit-load-this-arg
    0 1 cell-size 2 * neg jit-save-cell
    0 stack-frame LI
    0 1 cell-size 1 * neg jit-save-cell
    1 1 stack-frame neg jit-save-cell-update
] jit-prolog jit-define

[
    3 jit-load-literal-arg
    3 ds-reg cell-size jit-save-cell-update
] jit-push jit-define

[
    jit-save-context
    3 vm-reg MR
    4 jit-load-dlsym-arg
    4 MTLR
    jit-load-dlsym-toc-arg ! Restore the TOC/GOT
    BLRL
    jit-restore-context
] jit-primitive jit-define

[ 0 BL rc-relative-ppc-3-pc rt-entry-point-pic jit-rel ] jit-word-call jit-define

[
    6 jit-load-here-arg
    0 B rc-relative-ppc-3-pc rt-entry-point-pic-tail jit-rel
] jit-word-jump jit-define

[
    3 ds-reg 0 jit-load-cell
    ds-reg dup cell-size SUBI
    0 3 \ f type-number jit-compare-cell-imm
    [ 0 swap BEQ ] [ 0 B rc-relative-ppc-3-pc rt-entry-point jit-rel ] jit-conditional*
    0 B rc-relative-ppc-3-pc rt-entry-point jit-rel
] jit-if jit-define

: jit->r ( -- )
    4 ds-reg 0 jit-load-cell
    ds-reg dup cell-size SUBI
    4 rs-reg cell-size jit-save-cell-update ;

: jit-2>r ( -- )
    4 ds-reg 0 jit-load-cell
    5 ds-reg cell-size neg jit-load-cell
    ds-reg dup 2 cell-size * SUBI
    rs-reg dup 2 cell-size * ADDI
    4 rs-reg 0 jit-save-cell
    5 rs-reg cell-size neg jit-save-cell ;

: jit-3>r ( -- )
    4 ds-reg 0 jit-load-cell
    5 ds-reg cell-size neg jit-load-cell
    6 ds-reg cell-size neg 2 * jit-load-cell
    ds-reg dup 3 cell-size * SUBI
    rs-reg dup 3 cell-size * ADDI
    4 rs-reg 0 jit-save-cell
    5 rs-reg cell-size neg jit-save-cell
    6 rs-reg cell-size neg 2 * jit-save-cell ;

: jit-r> ( -- )
    4 rs-reg 0 jit-load-cell
    rs-reg dup cell-size SUBI
    4 ds-reg cell-size jit-save-cell-update ;

: jit-2r> ( -- )
    4 rs-reg 0 jit-load-cell
    5 rs-reg cell-size neg jit-load-cell
    rs-reg dup 2 cell-size * SUBI
    ds-reg dup 2 cell-size * ADDI
    4 ds-reg 0 jit-save-cell
    5 ds-reg cell-size neg jit-save-cell ;

: jit-3r> ( -- )
    4 rs-reg 0 jit-load-cell
    5 rs-reg cell-size neg jit-load-cell
    6 rs-reg cell-size neg 2 * jit-load-cell
    rs-reg dup 3 cell-size * SUBI
    ds-reg dup 3 cell-size * ADDI
    4 ds-reg 0 jit-save-cell
    5 ds-reg cell-size neg jit-save-cell
    6 ds-reg cell-size neg 2 * jit-save-cell ;

[
    jit->r
    0 BL rc-relative-ppc-3-pc rt-entry-point jit-rel
    jit-r>
] jit-dip jit-define

[
    jit-2>r
    0 BL rc-relative-ppc-3-pc rt-entry-point jit-rel
    jit-2r>
] jit-2dip jit-define

[
    jit-3>r
    0 BL rc-relative-ppc-3-pc rt-entry-point jit-rel
    jit-3r>
] jit-3dip jit-define

[
    1 1 stack-frame ADDI
    0 1 lr-save jit-load-cell
    0 MTLR
] jit-epilog jit-define

[ BLR ] jit-return jit-define

! ! ! Polymorphic inline caches

! Don't touch r6 here; it's used to pass the tail call site
! address for tail PICs

! Load a value from a stack position
[
    4 ds-reg 0 jit-load-cell rc-absolute-ppc-2 rt-untagged jit-rel
] pic-load jit-define

[ 4 4 tag-mask get ANDI. ] pic-tag jit-define

[
    3 4 MR
    4 4 tag-mask get ANDI.
    0 4 tuple type-number jit-compare-cell-imm
    [ 0 swap BNE ]
    [ 4 tuple-class-offset LI 4 3 4 jit-load-cell-x ]
    jit-conditional*
] pic-tuple jit-define

[
    0 4 0 jit-compare-cell-imm rc-absolute-ppc-2 rt-untagged jit-rel
] pic-check-tag jit-define

[
    5 jit-load-literal-arg
    0 4 5 jit-compare-cell
] pic-check-tuple jit-define

[
    [ 0 swap BNE ] [ 0 B rc-relative-ppc-3-pc rt-entry-point jit-rel ] jit-conditional*
] pic-hit jit-define

! Inline cache miss entry points
: jit-load-return-address ( -- ) 6 MFLR ;

! These are always in tail position with an existing stack
! frame, and the stack. The frame setup takes this into account.
: jit-inline-cache-miss ( -- )
    jit-save-context
    3 6 MR
    4 vm-reg MR
    ctx-reg 6 MR
    "inline_cache_miss" jit-call
    6 ctx-reg MR
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
    4 4 tag-mask get ANDI. ! Mask and...
    4 4 tag-bits get jit-shift-left-logical-imm ! shift tag bits to fixnum
    0 4 tuple type-number tag-fixnum jit-compare-cell-imm
    [ 0 swap BNE ]
    [ 4 tuple-class-offset LI 4 3 4 jit-load-cell-x ]
    jit-conditional*
    ! cache = ...
    3 jit-load-literal-arg
    ! key = hashcode(class)
    5 4 jit-class-hashcode
    ! key &= cache.length - 1
    5 5 mega-cache-size get 1 - 4 * ANDI.
    ! cache += array-start-offset
    3 3 array-start-offset ADDI
    ! cache += key
    3 3 5 ADD
    ! if(get(cache) == class)
    6 3 0 jit-load-cell
    0 6 4 jit-compare-cell
    [ 0 swap BNE ]
    [
        ! megamorphic_cache_hits++
        4 jit-load-megamorphic-cache-arg
        5 4 0 jit-load-cell
        5 5 1 ADDI
        5 4 0 jit-save-cell
        ! ... goto get(cache + cell-size)
        5 word-entry-point-offset LI
        3 3 cell-size jit-load-cell
        3 3 5 jit-load-cell-x
        3 MTCTR
        BCTR
    ]
    jit-conditional*
    ! fall-through on miss
] mega-lookup jit-define

! ! ! Sub-primitives

! Quotations and words
[
    3 ds-reg 0 jit-load-cell
    ds-reg dup cell-size SUBI
]
[ jit-call-quot ]
[ jit-jump-quot ] \ (call) define-combinator-primitive

[
    3 ds-reg 0 jit-load-cell
    ds-reg dup cell-size SUBI
    4 word-entry-point-offset LI
    4 3 4 jit-load-cell-x
]
[ 4 MTLR BLRL ]
[ 4 MTCTR BCTR ] \ (execute) define-combinator-primitive

[
    3 ds-reg 0 jit-load-cell
    ds-reg dup cell-size SUBI
    4 word-entry-point-offset LI
    4 3 4 jit-load-cell-x
    4 MTCTR BCTR
] jit-execute jit-define

! Special primitives
[
    frame-reg 3 MR

    3 vm-reg MR
    "begin_callback" jit-call

    jit-load-context
    jit-restore-context

    ! Call quotation
    3 frame-reg MR
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
    vm-reg jit-load-vm

    ! Load ds and rs registers
    jit-load-context
    jit-restore-context

    ! We have changed the stack; load return address again
    0 1 lr-save jit-load-cell
    0 MTLR

    ! Call quotation
    jit-jump-quot
] \ unwind-native-frames define-sub-primitive

[
    7 0 LI
    7 1 lr-save jit-save-cell

    ! Load callstack object
    6 ds-reg 0 jit-load-cell
    ds-reg ds-reg cell-size SUBI
    ! Get ctx->callstack_bottom
    jit-load-context
    3 ctx-reg context-callstack-bottom-offset jit-load-cell
    ! Get top of callstack object -- 'src' for memcpy
    4 6 callstack-top-offset ADDI
    ! Get callstack length, in bytes --- 'len' for memcpy
    7 callstack-length-offset LI
    5 6 7 jit-load-cell-x
    5 5 jit-shift-tag-bits
    ! Compute new stack pointer -- 'dst' for memcpy
    3 3 5 SUB
    ! Install new stack pointer
    1 3 MR
    ! Call memcpy; arguments are now in the correct registers
    1 1 -16 cell-size * jit-save-cell-update
    "factor_memcpy" jit-call
    1 1 0 jit-load-cell
    ! Return with new callstack
    0 1 lr-save jit-load-cell
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
    3 ds-reg 0 jit-load-cell
    3 3 tag-mask get ANDI.
    3 3 tag-bits get jit-shift-left-logical-imm
    3 ds-reg 0 jit-save-cell
] \ tag define-sub-primitive

[
    3 ds-reg 0 jit-load-cell   ! Load m
    4 ds-reg cell-size neg jit-load-cell-update ! Load obj
    3 3 jit-shift-fixnum-slot  ! Shift to a cell-size multiple
    4 4 jit-mask-tag-bits      ! Clear tag bits on obj
    3 4 3 jit-load-cell-x      ! Load cell at &obj[m]
    3 ds-reg 0 jit-save-cell   ! Push the result to the stack
] \ slot define-sub-primitive

[
    ! load string index from stack
    3 ds-reg cell-size neg jit-load-cell
    3 3 jit-shift-tag-bits
    ! load string from stack
    4 ds-reg 0 jit-load-cell
    ! load character
    4 4 string-offset ADDI
    3 3 4 LBZX
    3 3 tag-bits get jit-shift-left-logical-imm
    ! store character to stack
    ds-reg ds-reg cell-size SUBI
    3 ds-reg 0 jit-save-cell
] \ string-nth-fast define-sub-primitive

! Shufflers
[
    ds-reg dup cell-size SUBI
] \ drop define-sub-primitive

[
    ds-reg dup 2 cell-size * SUBI
] \ 2drop define-sub-primitive

[
    ds-reg dup 3 cell-size * SUBI
] \ 3drop define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    3 ds-reg cell-size jit-save-cell-update
] \ dup define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    ds-reg dup 2 cell-size * ADDI
    3 ds-reg 0 jit-save-cell
    4 ds-reg cell-size neg jit-save-cell
] \ 2dup define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    5 ds-reg cell-size neg 2 * jit-load-cell
    ds-reg dup cell-size 3 * ADDI
    3 ds-reg 0 jit-save-cell
    4 ds-reg cell-size neg jit-save-cell
    5 ds-reg cell-size neg 2 * jit-save-cell
] \ 3dup define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    ds-reg dup cell-size SUBI
    3 ds-reg 0 jit-save-cell
] \ nip define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    ds-reg dup cell-size 2 * SUBI
    3 ds-reg 0 jit-save-cell
] \ 2nip define-sub-primitive

[
    3 ds-reg cell-size neg jit-load-cell
    3 ds-reg cell-size jit-save-cell-update
] \ over define-sub-primitive

[
    3 ds-reg cell-size neg 2 * jit-load-cell
    3 ds-reg cell-size jit-save-cell-update
] \ pick define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    4 ds-reg 0 jit-save-cell
    3 ds-reg cell-size jit-save-cell-update
] \ dupd define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    3 ds-reg cell-size neg jit-save-cell
    4 ds-reg 0 jit-save-cell
] \ swap define-sub-primitive

[
    3 ds-reg cell-size neg jit-load-cell
    4 ds-reg cell-size neg 2 * jit-load-cell
    3 ds-reg cell-size neg 2 * jit-save-cell
    4 ds-reg cell-size neg jit-save-cell
] \ swapd define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    5 ds-reg cell-size neg 2 * jit-load-cell
    4 ds-reg cell-size neg 2 * jit-save-cell
    3 ds-reg cell-size neg jit-save-cell
    5 ds-reg 0 jit-save-cell
] \ rot define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    5 ds-reg cell-size neg 2 * jit-load-cell
    3 ds-reg cell-size neg 2 * jit-save-cell
    5 ds-reg cell-size neg jit-save-cell
    4 ds-reg 0 jit-save-cell
] \ -rot define-sub-primitive

[ jit->r ] \ load-local define-sub-primitive

! Comparisons
: jit-compare ( insn -- )
    t jit-literal
    3 jit-load-literal-arg
    4 ds-reg 0 jit-load-cell
    5 ds-reg cell-size neg jit-load-cell-update
    0 5 4 jit-compare-cell
    [ 0 8 ] dip execute( cr offset -- )
    3 \ f type-number LI
    3 ds-reg 0 jit-save-cell ;

: define-jit-compare ( insn word -- )
    [ [ jit-compare ] curry ] dip define-sub-primitive ;

\ BEQ \ eq? define-jit-compare
\ BGE \ fixnum>= define-jit-compare
\ BLE \ fixnum<= define-jit-compare
\ BGT \ fixnum> define-jit-compare
\ BLT \ fixnum< define-jit-compare

! Math
[
    3 ds-reg 0 jit-load-cell
    ds-reg ds-reg cell-size SUBI
    4 ds-reg 0 jit-load-cell
    3 3 4 OR
    3 3 tag-mask get ANDI.
    4 \ f type-number LI
    0 3 0 jit-compare-cell-imm
    [ 0 swap BNE ] [ 4 1 tag-fixnum LI ] jit-conditional*
    4 ds-reg 0 jit-save-cell
] \ both-fixnums? define-sub-primitive

: jit-math ( insn -- )
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell-update
    [ 5 3 4 ] dip execute( dst src1 src2 -- )
    5 ds-reg 0 jit-save-cell ;

[ \ ADD jit-math ] \ fixnum+fast define-sub-primitive

[ \ SUBF jit-math ] \ fixnum-fast define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell-update
    4 4 jit-shift-tag-bits
    5 3 4 jit-multiply-low
    5 ds-reg 0 jit-save-cell
] \ fixnum*fast define-sub-primitive

[ \ AND jit-math ] \ fixnum-bitand define-sub-primitive

[ \ OR jit-math ] \ fixnum-bitor define-sub-primitive

[ \ XOR jit-math ] \ fixnum-bitxor define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    3 3 NOT
    3 3 tag-mask get XORI
    3 ds-reg 0 jit-save-cell
] \ fixnum-bitnot define-sub-primitive

[
    3 ds-reg 0 jit-load-cell ! Load amount to shift
    3 3 jit-shift-tag-bits   ! Shift out tag bits
    ds-reg ds-reg cell-size SUBI
    4 ds-reg 0 jit-load-cell ! Load value to shift
    5 4 3 jit-shift-left-logical    ! Shift left
    6 3 NEG                         ! Negate shift amount
    7 4 6 jit-shift-right-algebraic ! Shift right
    7 7 jit-mask-tag-bits           ! Mask out tag bits
    0 3 0 jit-compare-cell-imm
    [ 0 swap BGT ] [ 5 7 MR ] jit-conditional*
    5 ds-reg 0 jit-save-cell
] \ fixnum-shift-fast define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    ds-reg ds-reg cell-size SUBI
    4 ds-reg 0 jit-load-cell
    5 4 3 jit-divide
    6 5 3 jit-multiply-low
    7 4 6 SUB
    7 ds-reg 0 jit-save-cell
] \ fixnum-mod define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    ds-reg ds-reg cell-size SUBI
    4 ds-reg 0 jit-load-cell
    5 4 3 jit-divide
    5 5 tag-bits get jit-shift-left-logical-imm
    5 ds-reg 0 jit-save-cell
] \ fixnum/i-fast define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    5 4 3 jit-divide
    6 5 3 jit-multiply-low
    7 4 6 SUB
    5 5 tag-bits get jit-shift-left-logical-imm
    5 ds-reg cell-size neg jit-save-cell
    7 ds-reg 0 jit-save-cell
] \ fixnum/mod-fast define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    3 3 jit-shift-fixnum-slot
    3 rs-reg 3 jit-load-cell-x
    3 ds-reg 0 jit-save-cell
] \ get-local define-sub-primitive

[
    3 ds-reg 0 jit-load-cell
    ds-reg ds-reg cell-size SUBI
    3 3 jit-shift-fixnum-slot
    rs-reg rs-reg 3 SUB
] \ drop-locals define-sub-primitive

! Overflowing fixnum arithmetic
:: jit-overflow ( insn func -- )
    ds-reg ds-reg cell-size SUBI
    jit-save-context
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size jit-load-cell
    0 0 LI
    0 MTXER
    6 4 3 insn call( d a s -- )
    6 ds-reg 0 jit-save-cell
    [ 0 swap BNS ]
    [
        5 vm-reg MR
        func jit-call
    ]
    jit-conditional* ;

[ [ ADDO. ] "overflow_fixnum_add" jit-overflow ] \ fixnum+ define-sub-primitive

[ [ SUBFO. ] "overflow_fixnum_subtract" jit-overflow ] \ fixnum- define-sub-primitive

[
    ds-reg ds-reg cell-size SUBI
    jit-save-context
    3 ds-reg 0 jit-load-cell
    3 3 jit-shift-tag-bits
    4 ds-reg cell-size jit-load-cell
    0 0 LI
    0 MTXER
    6 3 4 jit-multiply-low-ov-rc
    6 ds-reg 0 jit-save-cell
    [ 0 swap BNS ]
    [
        4 4 jit-shift-tag-bits
        5 vm-reg MR
        "overflow_fixnum_multiply" jit-call
    ]
    jit-conditional*
] \ fixnum* define-sub-primitive

! Contexts
:: jit-switch-context ( reg -- )
    7 0 LI
    7 1 lr-save jit-save-cell

    ! Make the new context the current one
    ctx-reg reg MR
    ctx-reg vm-reg vm-context-offset jit-save-cell

    ! Load new stack pointer
    1 ctx-reg context-callstack-top-offset jit-load-cell

    ! Load new ds, rs registers
    jit-restore-context ;

: jit-pop-context-and-param ( -- )
    3 ds-reg 0 jit-load-cell
    4 alien-offset LI
    3 3 4 jit-load-cell-x
    4 ds-reg cell-size neg jit-load-cell
    ds-reg ds-reg cell-size 2 * SUBI ;

: jit-push-param ( -- )
    ds-reg ds-reg cell-size ADDI
    4 ds-reg 0 jit-save-cell ;

: jit-set-context ( -- )
    jit-pop-context-and-param
    jit-save-context
    3 jit-switch-context
    jit-push-param ;

[ jit-set-context ] \ (set-context) define-sub-primitive

: jit-pop-quot-and-param ( -- )
    3 ds-reg 0 jit-load-cell
    4 ds-reg cell-size neg jit-load-cell
    ds-reg ds-reg cell-size 2 * SUBI ;

: jit-start-context ( -- )
    ! Create the new context in return-reg. Have to save context
    ! twice, first before calling new_context() which may GC,
    ! and again after popping the two parameters from the stack.
    jit-save-context
    3 vm-reg MR
    "new_context" jit-call

    6 3 MR
    jit-pop-quot-and-param
    jit-save-context
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

: jit-start-context-and-delete ( -- )
    jit-load-context
    3 vm-reg MR
    4 ctx-reg MR
    "reset_context" jit-call
    jit-pop-quot-and-param
    ctx-reg jit-switch-context
    jit-push-param
    jit-jump-quot ;

[
    jit-start-context-and-delete
] \ (start-context-and-delete) define-sub-primitive

[ "bootstrap.ppc" forget-vocab ] with-compilation-unit
