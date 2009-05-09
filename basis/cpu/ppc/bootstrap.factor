! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: bootstrap.image.private kernel kernel.private namespaces
system cpu.ppc.assembler compiler.codegen.fixup compiler.units
compiler.constants math math.private layouts words
vocabs slots.private locals.backend ;
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

[
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-immediate jit-rel
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
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-immediate jit-rel
    3 ds-reg 4 STWU
] jit-push-immediate jit-define

[
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-stack-chain jit-rel
    4 3 0 LWZ
    1 4 0 STW
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-primitive jit-rel
    3 MTCTR
    BCTR
] jit-primitive jit-define

[ 0 BL rc-relative-ppc-3 rt-xt-pic jit-rel ] jit-word-call jit-define

[
    0 6 LOAD32 rc-absolute-ppc-2/2 rt-here jit-rel
    0 B rc-relative-ppc-3 rt-xt-pic-tail jit-rel
] jit-word-jump jit-define

[ 0 B rc-relative-ppc-3 rt-xt jit-rel ] jit-word-special jit-define

[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    0 3 \ f tag-number CMPI
    2 BEQ
    0 B rc-relative-ppc-3 rt-xt jit-rel
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

: prepare-(execute) ( -- operand )
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 3 word-xt-offset LWZ
    4 ;

[ prepare-(execute) MTCTR BCTR ] jit-execute-jump jit-define

[ prepare-(execute) MTLR BLRL ] jit-execute-call jit-define

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

! Hi-tag
[
    3 4 MR
    load-tag
    0 4 object tag-number tag-fixnum CMPI
    2 BNE
    4 3 object tag-number neg LWZ
] pic-hi-tag jit-define

! Tuple
[
    3 4 MR
    load-tag
    0 4 tuple tag-number tag-fixnum CMPI
    2 BNE
    4 3 tuple tag-number neg bootstrap-cell + LWZ
] pic-tuple jit-define

! Hi-tag and tuple
[
    3 4 MR
    load-tag
    ! If bits 2 and 3 are set, the tag is either 6 (object) or 7 (tuple)
    0 4 BIN: 110 tag-fixnum CMPI
    5 BLT
    ! Untag r3
    3 3 0 0 31 tag-bits get - RLWINM
    ! Set r4 to 0 for objects, and bootstrap-cell for tuples
    4 4 1 tag-fixnum ANDI
    4 4 1 SRAWI
    ! Load header cell or tuple layout cell
    4 4 3 LWZX
] pic-hi-tag-tuple jit-define

[
    0 4 0 CMPI rc-absolute-ppc-2 rt-immediate jit-rel
] pic-check-tag jit-define

[
    0 5 LOAD32 rc-absolute-ppc-2/2 rt-immediate jit-rel
    4 0 5 CMP
] pic-check jit-define

[ 2 BNE 0 B rc-relative-ppc-3 rt-xt jit-rel ] pic-hit jit-define

! ! ! Megamorphic caches

[
    ! cache = ...
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-immediate jit-rel
    ! key = class
    5 4 MR
    ! key &= cache.length - 1
    5 5 mega-cache-size get 1- bootstrap-cell * ANDI
    ! cache += array-start-offset
    3 3 array-start-offset ADDI
    ! cache += key
    3 3 5 ADD
    ! if(get(cache) == class)
    6 3 0 LWZ
    6 0 4 CMP
    10 BNE
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
    ! fall-through on miss
] mega-lookup jit-define

! ! ! Sub-primitives

! Quotations and words
[
    3 ds-reg 0 LWZ
    ds-reg dup 4 SUBI
    4 3 quot-xt-offset LWZ
    4 MTCTR
    BCTR
] \ (call) define-sub-primitive

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
    3 3 1 SRAWI
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
    3 ds-reg 4 STWU
    4 ds-reg -4 STW
    3 ds-reg -8 STW
] \ tuck define-sub-primitive

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
    0 3 LOAD32 rc-absolute-ppc-2/2 rt-immediate jit-rel
    4 ds-reg 0 LWZ
    5 ds-reg -4 LWZU
    5 0 4 CMP
    2 swap execute( offset -- ) ! magic number
    \ f tag-number 3 LI
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
    \ f tag-number 4 LI
    0 3 0 CMPI
    2 BNE
    1 tag-fixnum 4 LI
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
    2 BGT
    5 7 MR
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
    3 3 1 SRAWI
    rs-reg 3 3 LWZX
    3 ds-reg 0 STW
] \ get-local define-sub-primitive

[
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    3 3 1 SRAWI
    rs-reg 3 rs-reg SUBF
] \ drop-locals define-sub-primitive

[ "bootstrap.ppc" forget-vocab ] with-compilation-unit
