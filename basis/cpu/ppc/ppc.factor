! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences kernel combinators make math
math.order math.ranges system namespaces locals layouts words
alien alien.accessors alien.c-types literals cpu.architecture
cpu.ppc.assembler cpu.ppc.assembler.backend literals compiler.cfg.registers
compiler.cfg.instructions compiler.constants compiler.codegen
compiler.codegen.fixup compiler.cfg.intrinsics
compiler.cfg.stack-frame compiler.units ;
IN: cpu.ppc

! PowerPC register assignments:
! r2-r12: integer vregs
! r15-r29
! r30: integer scratch
! f0-f29: float vregs
! f30: float scratch

! Add some methods to the assembler that are useful to us
M: label (B) [ 0 ] 2dip (B) rc-relative-ppc-3 label-fixup ;
M: label BC [ 0 BC ] dip rc-relative-ppc-2 label-fixup ;

enable-float-intrinsics

<<
\ ##integer>float t frame-required? set-word-prop
\ ##float>integer t frame-required? set-word-prop
>>

M: ppc machine-registers
    {
        { int-regs $[ 2 12 [a,b] 15 29 [a,b] append ] }
        { double-float-regs $[ 0 29 [a,b] ] }
    } ;

CONSTANT: scratch-reg 30
CONSTANT: fp-scratch-reg 30

M: ppc two-operand? f ;

M: ppc %load-immediate ( reg n -- ) swap LOAD ;

M: ppc %load-reference ( reg obj -- )
    [ 0 swap LOAD32 ] [ rc-absolute-ppc-2/2 rel-immediate ] bi* ;

M: ppc %alien-global ( register symbol dll -- )
    [ 0 swap LOAD32 ] 2dip rc-absolute-ppc-2/2 rel-dlsym ;

CONSTANT: ds-reg 13
CONSTANT: rs-reg 14

GENERIC: loc-reg ( loc -- reg )

M: ds-loc loc-reg drop ds-reg ;
M: rs-loc loc-reg drop rs-reg ;

: loc>operand ( loc -- reg n )
    [ loc-reg ] [ n>> cells neg ] bi ; inline

M: ppc %peek loc>operand LWZ ;
M: ppc %replace loc>operand STW ;

: (%inc) ( n reg -- ) dup rot cells ADDI ; inline

M: ppc %inc-d ( n -- ) ds-reg (%inc) ;
M: ppc %inc-r ( n -- ) rs-reg (%inc) ;

HOOK: reserved-area-size os ( -- n )

! The start of the stack frame contains the size of this frame
! as well as the currently executing XT
: factor-area-size ( -- n ) 2 cells ; foldable
: next-save ( n -- i ) cell - ;
: xt-save ( n -- i ) 2 cells - ;

! Next, we have the spill area as well as the FFI parameter area.
! They overlap, since basic blocks with FFI calls will never
! spill.
: param@ ( n -- x ) reserved-area-size + ; inline

: param-save-size ( -- n ) 8 cells ; foldable

: local@ ( n -- x )
    reserved-area-size param-save-size + + ; inline

: spill-integer-base ( -- n )
    stack-frame get spill-counts>> double-float-regs swap at
    double-float-regs reg-size * ;

: spill-integer@ ( n -- offset )
    cells spill-integer-base + param@ ;

: spill-float@ ( n -- offset )
    double-float-regs reg-size * param@ ;

! Some FP intrinsics need a temporary scratch area in the stack
! frame, 8 bytes in size
: scratch@ ( n -- offset )
    stack-frame get total-size>>
    factor-area-size -
    param-save-size -
    + ;

! Finally we have the linkage area
HOOK: lr-save os ( -- n )

M: ppc stack-frame-size ( stack-frame -- i )
    [ spill-counts>> [ swap reg-size * ] { } assoc>map sum ]
    [ params>> ]
    [ return>> ]
    tri + +
    param-save-size +
    reserved-area-size +
    factor-area-size +
    4 cells align ;

M: ppc %call ( word -- ) 0 BL rc-relative-ppc-3 rel-word-pic ;

M: ppc %jump ( word -- )
    0 6 LOAD32 8 rc-absolute-ppc-2/2 rel-here
    0 B rc-relative-ppc-3 rel-word-pic-tail ;

M: ppc %jump-label ( label -- ) B ;
M: ppc %return ( -- ) BLR ;

M:: ppc %dispatch ( src temp offset -- )
    0 temp LOAD32
    4 offset + cells rc-absolute-ppc-2/2 rel-here
    temp temp src LWZX
    temp MTCTR
    BCTR ;

M: ppc %dispatch-label ( word -- )
    B{ 0 0 0 0 } % rc-absolute-cell rel-word ;

:: (%slot) ( obj slot tag temp -- reg offset )
    temp slot obj ADD
    temp tag neg ; inline

: (%slot-imm) ( obj slot tag -- reg offset )
    [ cells ] dip - ; inline

M: ppc %slot ( dst obj slot tag temp -- ) (%slot) LWZ ;
M: ppc %slot-imm ( dst obj slot tag -- ) (%slot-imm) LWZ ;
M: ppc %set-slot ( src obj slot tag temp -- ) (%slot) STW ;
M: ppc %set-slot-imm ( src obj slot tag -- ) (%slot-imm) STW ;

M:: ppc %string-nth ( dst src index temp -- )
    [
        "end" define-label
        temp src index ADD
        dst temp string-offset LBZ
        0 dst HEX: 80 CMPI
        "end" get BLT
        temp src string-aux-offset LWZ
        temp temp index ADD
        temp temp index ADD
        temp temp byte-array-offset LHZ
        temp temp 7 SLWI
        dst dst temp XOR
        "end" resolve-label
    ] with-scope ;

M:: ppc %set-string-nth-fast ( ch obj index temp -- )
    temp obj index ADD
    ch temp string-offset STB ;

M: ppc %add     ADD ;
M: ppc %add-imm ADDI ;
M: ppc %sub     swap SUBF ;
M: ppc %sub-imm SUBI ;
M: ppc %mul     MULLW ;
M: ppc %mul-imm MULLI ;
M: ppc %and     AND ;
M: ppc %and-imm ANDI ;
M: ppc %or      OR ;
M: ppc %or-imm  ORI ;
M: ppc %xor     XOR ;
M: ppc %xor-imm XORI ;
M: ppc %shl-imm swapd SLWI ;
M: ppc %shr-imm swapd SRWI ;
M: ppc %sar-imm SRAWI ;
M: ppc %not     NOT ;

: %alien-invoke-tail ( func dll -- )
    [ scratch-reg ] 2dip %alien-global scratch-reg MTCTR BCTR ;

:: exchange-regs ( r1 r2 -- )
    scratch-reg r1 MR
    r1 r2 MR
    r2 scratch-reg MR ;

: ?MR ( r1 r2 -- ) 2dup = [ 2drop ] [ MR ] if ;

:: move>args ( src1 src2 -- )
    {
        { [ src1 4 = ] [ 3 src2 ?MR 3 4 exchange-regs ] }
        { [ src1 3 = ] [ 4 src2 ?MR ] }
        { [ src2 3 = ] [ 4 src1 ?MR 3 4 exchange-regs ] }
        { [ src2 4 = ] [ 3 src1 ?MR ] }
        [ 3 src1 MR 4 src2 MR ]
    } cond ;

: clear-xer ( -- )
    0 0 LI
    0 MTXER ; inline

:: overflow-template ( src1 src2 insn func -- )
    "no-overflow" define-label
    clear-xer
    scratch-reg src2 src1 insn call
    scratch-reg ds-reg 0 STW
    "no-overflow" get BNO
    src1 src2 move>args
    %prepare-alien-invoke
    func f %alien-invoke
    "no-overflow" resolve-label ; inline

:: overflow-template-tail ( src1 src2 insn func -- )
    "overflow" define-label
    clear-xer
    scratch-reg src2 src1 insn call
    "overflow" get BO
    scratch-reg ds-reg 0 STW
    BLR
    "overflow" resolve-label
    src1 src2 move>args
    %prepare-alien-invoke
    func f %alien-invoke-tail ; inline

M: ppc %fixnum-add ( src1 src2 -- )
    [ ADDO. ] "overflow_fixnum_add" overflow-template ;

M: ppc %fixnum-add-tail ( src1 src2 -- )
    [ ADDO. ] "overflow_fixnum_add" overflow-template-tail ;

M: ppc %fixnum-sub ( src1 src2 -- )
    [ SUBFO. ] "overflow_fixnum_subtract" overflow-template ;

M: ppc %fixnum-sub-tail ( src1 src2 -- )
    [ SUBFO. ] "overflow_fixnum_subtract" overflow-template-tail ;

M:: ppc %fixnum-mul ( src1 src2 temp1 temp2 -- )
    "no-overflow" define-label
    clear-xer
    temp1 src1 tag-bits get SRAWI
    temp2 temp1 src2 MULLWO.
    temp2 ds-reg 0 STW
    "no-overflow" get BNO
    src2 src2 tag-bits get SRAWI
    temp1 src2 move>args
    %prepare-alien-invoke
    "overflow_fixnum_multiply" f %alien-invoke
    "no-overflow" resolve-label ;

M:: ppc %fixnum-mul-tail ( src1 src2 temp1 temp2 -- )
    "overflow" define-label
    clear-xer
    temp1 src1 tag-bits get SRAWI
    temp2 temp1 src2 MULLWO.
    "overflow" get BO
    temp2 ds-reg 0 STW
    BLR
    "overflow" resolve-label
    src2 src2 tag-bits get SRAWI
    temp1 src2 move>args
    %prepare-alien-invoke
    "overflow_fixnum_multiply" f %alien-invoke-tail ;

: bignum@ ( n -- offset ) cells bignum tag-number - ; inline

M:: ppc %integer>bignum ( dst src temp -- )
    [
        "end" define-label
        dst 0 >bignum %load-reference
        ! Is it zero? Then just go to the end and return this zero
        0 src 0 CMPI
        "end" get BEQ
        ! Allocate a bignum
        dst 4 cells bignum temp %allot
        ! Write length
        2 tag-fixnum temp LI
        temp dst 1 bignum@ STW
        ! Compute sign
        temp src MR
        temp temp cell-bits 1- SRAWI
        temp temp 1 ANDI
        ! Store sign
        temp dst 2 bignum@ STW
        ! Make negative value positive
        temp temp temp ADD
        temp temp NEG
        temp temp 1 ADDI
        temp src temp MULLW
        ! Store the bignum
        temp dst 3 bignum@ STW
        "end" resolve-label
    ] with-scope ;

M:: ppc %bignum>integer ( dst src temp -- )
    [
        "end" define-label
        temp src 1 bignum@ LWZ
        ! if the length is 1, its just the sign and nothing else,
        ! so output 0
        0 dst LI
        0 temp 1 tag-fixnum CMPI
        "end" get BEQ
        ! load the value
        dst src 3 bignum@ LWZ
        ! load the sign
        temp src 2 bignum@ LWZ
        ! branchless arithmetic: we want to turn 0 into 1,
        ! and 1 into -1
        temp temp temp ADD
        temp temp 1 SUBI
        temp temp NEG
        ! multiply value by sign
        dst dst temp MULLW
        "end" resolve-label
    ] with-scope ;

M: ppc %add-float FADD ;
M: ppc %sub-float FSUB ;
M: ppc %mul-float FMUL ;
M: ppc %div-float FDIV ;

M:: ppc %integer>float ( dst src -- )
    HEX: 4330 scratch-reg LIS
    scratch-reg 1 0 scratch@ STW
    scratch-reg src MR
    scratch-reg dup HEX: 8000 XORIS
    scratch-reg 1 4 scratch@ STW
    dst 1 0 scratch@ LFD
    scratch-reg 4503601774854144.0 %load-reference
    fp-scratch-reg scratch-reg float-offset LFD
    dst dst fp-scratch-reg FSUB ;

M:: ppc %float>integer ( dst src -- )
    fp-scratch-reg src FCTIWZ
    fp-scratch-reg 1 0 scratch@ STFD
    dst 1 4 scratch@ LWZ ;

M: ppc %copy ( dst src -- ) MR ;

M: ppc %copy-float ( dst src -- ) FMR ;

M: ppc %unbox-float ( dst src -- ) float-offset LFD ;

M:: ppc %box-float ( dst src temp -- )
    dst 16 float temp %allot
    src dst float-offset STFD ;

M:: ppc %unbox-any-c-ptr ( dst src temp -- )
    [
        { "is-byte-array" "end" "start" } [ define-label ] each
        ! Address is computed in dst
        0 dst LI
        ! Load object into scratch-reg
        scratch-reg src MR
        ! We come back here with displaced aliens
        "start" resolve-label
        ! Is the object f?
        0 scratch-reg \ f tag-number CMPI
        ! If so, done
        "end" get BEQ
        ! Is the object an alien?
        0 scratch-reg header-offset LWZ
        0 0 alien type-number tag-fixnum CMPI
        "is-byte-array" get BNE
        ! If so, load the offset
        0 scratch-reg alien-offset LWZ
        ! Add it to address being computed
        dst dst 0 ADD
        ! Now recurse on the underlying alien
        scratch-reg scratch-reg underlying-alien-offset LWZ
        "start" get B
        "is-byte-array" resolve-label
        ! Add byte array address to address being computed
        dst dst scratch-reg ADD
        ! Add an offset to start of byte array's data area
        dst dst byte-array-offset ADDI
        "end" resolve-label
    ] with-scope ;

: alien@ ( n -- n' ) cells object tag-number - ;

M:: ppc %box-alien ( dst src temp -- )
    [
        "f" define-label
        dst \ f tag-number %load-immediate
        0 src 0 CMPI
        "f" get BEQ
        dst 4 cells alien temp %allot
        ! Store offset
        src dst 3 alien@ STW
        ! Store expired slot
        temp \ f tag-number %load-immediate
        temp dst 1 alien@ STW
        ! Store underlying-alien slot
        temp dst 2 alien@ STW
        "f" resolve-label
    ] with-scope ;

M: ppc %alien-unsigned-1 0 LBZ ;
M: ppc %alien-unsigned-2 0 LHZ ;

M: ppc %alien-signed-1 dupd 0 LBZ dup EXTSB ;
M: ppc %alien-signed-2 0 LHA ;

M: ppc %alien-cell 0 LWZ ;

M: ppc %alien-float 0 LFS ;
M: ppc %alien-double 0 LFD ;

M: ppc %set-alien-integer-1 swap 0 STB ;
M: ppc %set-alien-integer-2 swap 0 STH ;

M: ppc %set-alien-cell swap 0 STW ;

M: ppc %set-alien-float swap 0 STFS ;
M: ppc %set-alien-double swap 0 STFD ;

: load-zone-ptr ( reg -- )
    "nursery" f %alien-global ;

: load-allot-ptr ( nursery-ptr allot-ptr -- )
    [ drop load-zone-ptr ] [ swap 4 LWZ ] 2bi ;

:: inc-allot-ptr ( nursery-ptr allot-ptr n -- )
    scratch-reg allot-ptr n 8 align ADDI
    scratch-reg nursery-ptr 4 STW ;

:: store-header ( dst class -- )
    class type-number tag-fixnum scratch-reg LI
    scratch-reg dst 0 STW ;

: store-tagged ( dst tag -- )
    dupd tag-number ORI ;

M:: ppc %allot ( dst size class nursery-ptr -- )
    nursery-ptr dst load-allot-ptr
    nursery-ptr dst size inc-allot-ptr
    dst class store-header
    dst class store-tagged ;

: load-cards-offset ( dst -- )
    [ "cards_offset" f %alien-global ] [ dup 0 LWZ ] bi ;

: load-decks-offset ( dst -- )
    [ "decks_offset" f %alien-global ] [ dup 0 LWZ ] bi  ;

M:: ppc %write-barrier ( src card# table -- )
    card-mark scratch-reg LI

    ! Mark the card
    table load-cards-offset
    src card# card-bits SRWI
    table scratch-reg card# STBX

    ! Mark the card deck
    table load-decks-offset
    src card# deck-bits SRWI
    table scratch-reg card# STBX ;

M: ppc %gc
    "end" define-label
    12 load-zone-ptr
    11 12 cell LWZ ! nursery.here -> r11
    12 12 3 cells LWZ ! nursery.end -> r12
    11 11 1024 ADDI ! add ALLOT_BUFFER_ZONE to here
    11 0 12 CMP ! is here >= end?
    "end" get BLE
    %prepare-alien-invoke
    "minor_gc" f %alien-invoke
    "end" resolve-label ;

M: ppc %prologue ( n -- )
    0 11 LOAD32 rc-absolute-ppc-2/2 rel-this
    0 MFLR
    {
        [ [ 1 1 ] dip neg ADDI ]
        [ [ 11 1 ] dip xt-save STW ]
        [ 11 LI ]
        [ [ 11 1 ] dip next-save STW ]
        [ [ 0 1 ] dip lr-save + STW ]
    } cleave ;

M: ppc %epilogue ( n -- )
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    [ [ 0 1 ] dip lr-save + LWZ ]
    [ [ 1 1 ] dip ADDI ] bi
    0 MTLR ;

:: (%boolean) ( dst temp word -- )
    "end" define-label
    dst \ f tag-number %load-immediate
    "end" get word execute
    dst \ t %load-reference
    "end" get resolve-label ; inline

: %boolean ( dst temp cc -- )
    negate-cc {
        { cc< [ \ BLT (%boolean) ] }
        { cc<= [ \ BLE (%boolean) ] }
        { cc> [ \ BGT (%boolean) ] }
        { cc>= [ \ BGE (%boolean) ] }
        { cc= [ \ BEQ (%boolean) ] }
        { cc/= [ \ BNE (%boolean) ] }
    } case ;

: (%compare) ( src1 src2 -- ) [ 0 ] dip CMP ; inline
: (%compare-imm) ( src1 src2 -- ) [ 0 ] 2dip CMPI ; inline
: (%compare-float) ( src1 src2 -- ) [ 0 ] dip FCMPU ; inline

M: ppc %compare (%compare) %boolean ;
M: ppc %compare-imm (%compare-imm) %boolean ;
M: ppc %compare-float (%compare-float) %boolean ;

: %branch ( label cc -- )
    {
        { cc< [ BLT ] }
        { cc<= [ BLE ] }
        { cc> [ BGT ] }
        { cc>= [ BGE ] }
        { cc= [ BEQ ] }
        { cc/= [ BNE ] }
    } case ;

M: ppc %compare-branch (%compare) %branch ;
M: ppc %compare-imm-branch (%compare-imm) %branch ;
M: ppc %compare-float-branch (%compare-float) %branch ;

M: ppc %spill-integer ( src n -- ) spill-integer@ 1 swap STW ;
M: ppc %reload-integer ( dst n -- ) spill-integer@ 1 swap LWZ ;

M: ppc %spill-float ( src n -- ) spill-float@ 1 swap STFD ;
M: ppc %reload-float ( dst n -- ) spill-float@ 1 swap LFD ;

M: ppc %loop-entry ;

M: int-regs return-reg drop 3 ;
M: int-regs param-regs drop { 3 4 5 6 7 8 9 10 } ;
M: float-regs return-reg drop 1 ;

M: int-regs %save-param-reg drop 1 rot local@ STW ;
M: int-regs %load-param-reg drop 1 rot local@ LWZ ;

GENERIC: STF ( src dst off reg-class -- )

M: single-float-regs STF drop STFS ;
M: double-float-regs STF drop STFD ;

M: float-regs %save-param-reg [ 1 rot local@ ] dip STF ;

GENERIC: LF ( dst src off reg-class -- )

M: single-float-regs LF drop LFS ;
M: double-float-regs LF drop LFD ;

M: float-regs %load-param-reg [ 1 rot local@ ] dip LF ;

M: stack-params %load-param-reg ( stack reg reg-class -- )
    drop [ 0 1 rot local@ LWZ 0 1 ] dip param@ STW ;

: next-param@ ( n -- x ) param@ stack-frame get total-size>> + ;

M: stack-params %save-param-reg ( stack reg reg-class -- )
    #! Funky. Read the parameter from the caller's stack frame.
    #! This word is used in callbacks
    drop
    [ 0 1 ] dip next-param@ LWZ
    [ 0 1 ] dip local@ STW ;

M: ppc %prepare-unbox ( -- )
    ! First parameter is top of stack
    3 ds-reg 0 LWZ
    ds-reg dup cell SUBI ;

M: ppc %unbox ( n reg-class func -- )
    ! Value must be in r3
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: ppc %unbox-long-long ( n func -- )
    ! Value must be in r3:r4
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    [
        [ [ 3 1 ] dip local@ STW ]
        [ [ 4 1 ] dip cell + local@ STW ] bi
    ] when* ;

M: ppc %unbox-large-struct ( n c-type -- )
    ! Value must be in r3
    ! Compute destination address and load struct size
    [ [ 4 1 ] dip local@ ADDI ] [ heap-size 5 LI ] bi*
    ! Call the function
    "to_value_struct" f %alien-invoke ;

M: ppc %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    [ over [ 0 over param-reg swap %load-param-reg ] [ 2drop ] if ] dip
    f %alien-invoke ;

M: ppc %box-long-long ( n func -- )
    [
        [
            [ [ 3 1 ] dip local@ LWZ ]
            [ [ 4 1 ] dip cell + local@ LWZ ] bi
        ] when*
    ] dip f %alien-invoke ;

: struct-return@ ( n -- n )
    [ stack-frame get params>> ] unless* local@ ;

M: ppc %prepare-box-struct ( -- )
    #! Compute target address for value struct return
    3 1 f struct-return@ ADDI
    3 1 0 local@ STW ;

M: ppc %box-large-struct ( n c-type -- )
    ! If n = f, then we're boxing a returned struct
    ! Compute destination address and load struct size
    [ [ 3 1 ] dip struct-return@ ADDI ] [ heap-size 4 LI ] bi*
    ! Call the function
    "box_value_struct" f %alien-invoke ;

M: ppc %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    scratch-reg "stack_chain" f %alien-global
    scratch-reg scratch-reg 0 LWZ
    1 scratch-reg 0 STW
    ds-reg scratch-reg 8 STW
    rs-reg scratch-reg 12 STW ;

M: ppc %alien-invoke ( symbol dll -- )
    [ 11 ] 2dip %alien-global 11 MTLR BLRL ;

M: ppc %alien-callback ( quot -- )
    3 swap %load-reference "c_to_factor" f %alien-invoke ;

M: ppc %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    15 3 MR ;

M: ppc %alien-indirect ( -- )
    15 MTLR BLRL ;

M: ppc %callback-value ( ctype -- )
    ! Save top of data stack
    3 ds-reg 0 LWZ
    3 1 0 local@ STW
    ! Restore data/call/retain stacks
    "unnest_stacks" f %alien-invoke
    ! Restore top of data stack
    3 1 0 local@ LWZ
    ! Unbox former top of data stack to return registers
    unbox-return ;

M: ppc small-enough? ( n -- ? ) -32768 32767 between? ;

M: ppc return-struct-in-registers? ( c-type -- ? )
    c-type return-in-registers?>> ;

M: ppc %box-small-struct ( c-type -- )
    #! Box a <= 16-byte struct returned in r3:r4:r5:r6
    heap-size 7 LI
    "box_medium_struct" f %alien-invoke ;

: %unbox-struct-1 ( -- )
    ! Alien must be in r3.
    "alien_offset" f %alien-invoke
    3 3 0 LWZ ;

: %unbox-struct-2 ( -- )
    ! Alien must be in r3.
    "alien_offset" f %alien-invoke
    4 3 4 LWZ
    3 3 0 LWZ ;

: %unbox-struct-4 ( -- )
    ! Alien must be in r3.
    "alien_offset" f %alien-invoke
    6 3 12 LWZ
    5 3 8 LWZ
    4 3 4 LWZ
    3 3 0 LWZ ;

M: ppc %unbox-small-struct ( size -- )
    #! Alien must be in EAX.
    heap-size cell align cell /i {
        { 1 [ %unbox-struct-1 ] }
        { 2 [ %unbox-struct-2 ] }
        { 4 [ %unbox-struct-4 ] }
    } case ;

USE: vocabs.loader

{
    { [ os macosx? ] [ "cpu.ppc.macosx" require ] }
    { [ os linux? ] [ "cpu.ppc.linux" require ] }
} cond

"complex-double" c-type t >>return-in-registers? drop

[
    <c-type>
        [ alien-unsigned-4 c-bool> ] >>getter
        [ [ >c-bool ] 2dip set-alien-unsigned-4 ] >>setter
        4 >>size
        4 >>align
        "box_boolean" >>boxer
        "to_boolean" >>unboxer
    "bool" define-primitive-type
] with-compilation-unit
