! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: cpu.ppc.architecture

! PowerPC register assignments
! r3-r11, r16-r31: integer vregs
! f0-f13: float vregs
! r12: scratch
! r14: data stack
! r15: retain stack

<< {
    { [ os macosx? ] [
        4 "longlong" c-type (>>align)
        4 "ulonglong" c-type (>>align)
        4 "double" c-type (>>align)
    ] }
    { [ os linux? ] [
        t "longlong" c-type (>>stack-align?)
        t "ulonglong" c-type (>>stack-align?)
    ] }
} cond >>

M: ppc machine-registers
    {
        { int-regs { 3 4 5 6 7 8 9 10 11 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 } }
        { double-float-regs { 0 1 2 3 4 5 6 7 8 9 10 11 12 13 } }
    } ;

: scratch-reg 12 ; inline

M: ppc two-operand? t ;

M: ppc %load-immediate ( reg n -- ) swap LOAD ;

M:: ppc %load-indirect ( reg obj -- )
    0 reg LOAD32
    obj rc-absolute-ppc-2/2 rel-literal
    reg reg 0 LWZ ;

: ds-reg 14 ; inline
: rs-reg 15 ; inline

GENERIC: loc-reg ( loc -- reg )

M: ds-loc log-reg drop ds-reg ;
M: rs-loc log-reg drop rs-reg ;

: loc>operand ( loc -- reg n )
    [ loc-reg ] [ n>> cells neg ] bi ; inline

M: ppc %peek loc>operand LWZ ;
M: ppc %replace loc>operand STW ;

: (%inc) ( n reg -- ) dup rot cells ADDI ; inline

M: ppc %inc-d ( n -- ) ds-reg (%inc) ;
M: ppc %inc-r ( n -- ) rs-reg (%inc) ;

: reserved-area-size ( -- n )
    os {
        { linux [ 2 ] }
        { macosx [ 6 ] }
    } case cells ; foldable

: lr-save ( -- n )
    os {
        { linux [ 1 ] }
        { macosx [ 2 ] }
    } case cells ; foldable

: param@ ( n -- x ) reserved-area-size + ; inline

: param-save-size ( -- n ) 8 cells ; foldable

: local@ ( n -- x )
    reserved-area-size param-save-size + + ; inline

: factor-area-size ( -- n ) 2 cells ; foldable

: next-save ( n -- i ) cell - ;

: xt-save ( n -- i ) 2 cells - ;

M: ppc stack-frame-size ( stack-frame -- i )
    local@ factor-area-size + 4 cells align ;

! M: x86 stack-frame-size ( stack-frame -- i )
!     [ spill-counts>> [ swap reg-size * ] { } assoc>map sum ]
!     [ params>> ]
!     [ return>> ]
!     tri + +
!     3 cells +
!     align-stack ;

M: ppc %call ( label -- ) BL ;
M: ppc %jump-label ( label -- ) B ;
M: ppc %return ( -- ) BLR ;

M:: ppc %dispatch ( src temp -- )
    0 temp LOAD32 rc-absolute-ppc-2/2 rel-here
    temp temp src ADD
    temp temp 5 cells LWZ
    temp MTCTR
    BCTR ;

M: ppc %dispatch-label ( word -- )
    0 , rc-absolute-cell rel-word ;

:: (%slot) ( obj slot tag temp -- reg offset )
    temp slot obj ADD
    temp tag neg ; inline

: (%slot-imm) ( obj slot tag -- reg offset )
    [ cells ] dip - ; inline

M: ppc %slot ( dst obj slot tag temp -- ) (%slot) LWZ ;
M: ppc %slot-imm ( dst obj slot tag -- ) (%slot-imm) LWZ ;
M: ppc %set-slot ( src obj slot tag temp -- ) (%slot) STW ;
M: ppc %set-slot-imm ( src obj slot tag -- ) (%slot-imm) STW ;

M: ppc %add     ADD ;
M: ppc %add-imm ADDI ;
M: ppc %sub     swapd SUBF ;
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

M: ppc %integer>bignum ( dst src temp -- )
    [
        { "end" "non-zero" "pos" "store" } [ define-label ] each
        ! is it zero?
        0 over v>operand 0 CMPI
        "non-zero" get BNE
        dup 0 >bignum %load-literal
        "end" get B
        ! it is non-zero
        "non-zero" resolve-label
        1 bignum over 3 + cells %allot
        1+ v>operand 12 LI ! compute the length
        12 11 cell STW ! store the length
        ! is the fixnum negative?
        0 over v>operand 0 CMPI
        "pos" get BGE
        1 12 LI
        ! store negative sign
        12 11 2 cells STW
        ! negate fixnum
        dup v>operand dup -1 MULI
        "store" get B
        "pos" resolve-label
        0 12 LI
        ! store positive sign
        12 11 2 cells STW
        "store" resolve-label
        ! store the number
        dup v>operand 11 3 cells STW
        ! tag the bignum, store it in reg
        bignum %store-tagged
        "end" resolve-label
    ] with-scope ;

: bignum@ ( n -- offset ) cells bignum tag-number - ; inline

M:: %bignum>integer ( dst src -- )
    [
        "end" define-label
        scratch-reg src 1 bignum@ LWZ
        ! if the length is 1, its just the sign and nothing else,
        ! so output 0
        0 dst LI
        0 scratch-reg 1 v>operand CMPI
        "end" get BEQ
        ! load the value
        dst src 3 bignum@ LWZ
        ! load the sign
        scratch-reg src 2 bignum@ LWZ
        ! branchless arithmetic: we want to turn 0 into 1,
        ! and 1 into -1
        scratch-reg scratch-reg 1 SLWI
        scratch-reg scratch-reg NEG
        scratch-reg scratch-reg 1 ADDI
        ! multiply value by sign
        dst dst scratch-reg MULLW
        "end" resolve-label
    ] with-scope ;

M: ppc %add-float FADD ;
M: ppc %sub-float FSUB ;
M: ppc %mul-float FMUL ;
M: ppc %div-float FDIV ;

M: ppc %integer>float
    HEX: 4330 "scratch" operand LIS
    "scratch" operand 1 0 param@ STW
    "in" operand dup HEX: 8000 XORIS
    "in" operand 1 cell param@ STW
    "f1" operand 1 0 param@ LFD
    4503601774854144.0 "in" operand load-indirect
    "f2" operand "in" operand float-offset LFD
    "f1" operand "f1" operand "f2" operand FSUB ;

M: ppc %float>integer
    "scratch" operand "in" operand FCTIWZ
    "scratch" operand 1 0 param@ STFD
    "out" operand 1 cell param@ LWZ ;

M: ppc %copy ( dst src -- ) MR ;

M: ppc %copy-float ( dst src -- ) MFR ;

M: ppc %unbox-float ( dst src -- ) float-offset LFD ;

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
        dst src 3 alien@ STW
        temp \ f tag-number %load-immediate
        ! Store expired slot
        temp dst 1 alien@ STW
        ! Store underlying-alien slot
        temp dst 2 alien@ STW
        "f" resolve-label
    ] with-scope ;

M: ppc %alien-unsigned-1 0 LBZ ;
M: ppc %alien-unsigned-2 0 LHZ ;

M: ppc %alien-signed-1 dupd 0 LBZ EXTSB ;
M: ppc %alien-signed-2 0 LHA ;

M: ppc %alien-cell 0 LWZ ;

M: ppc %alien-float 0 LFS ;
M: ppc %alien-double 0 LFD ;

M: ppc %set-alien-integer-1 0 STB ;
M: ppc %set-alien-integer-2 0 STH ;

M: ppc %set-alien-cell 0 STW ;

M: ppc %set-alien-float 0 STFS ;
M: ppc %set-alien-double 0 STFD ;

: load-zone-ptr ( reg -- )
    [ "nursery" f ] dip %load-dlsym ;

: load-allot-ptr ( nursery-ptr allot-ptr -- )
    [ drop load-zone-ptr ] [ swap cell LWZ ] 2bi ;

:: inc-allot-ptr ( nursery-ptr n -- )
    scratch-reg inc-allot-ptr 4 LWZ
    scratch-reg scratch-reg n 8 align ADD
    scratch-reg inc-allot-ptr 4 STW ;

:: store-header ( temp class -- )
    class type-number tag-fixnum scratch-reg LI
    temp scratch-reg 0 STW ;

: store-tagged ( dst tag -- )
    dupd tag-number ORI ;

M:: ppc %allot ( dst size class nursery-ptr -- )
    nursery-ptr dst load-allot-ptr
    dst class store-header
    dst class store-tagged
    nursery-ptr size inc-allot-ptr ;

: %alien-global ( dest name -- )
    [ f swap %load-dlsym ] [ drop dup 0 LWZ ] 2bi ;

: load-cards-offset ( dest -- )
    "cards_offset" %alien-global ;

: load-decks-offset ( dest -- )
    "decks_offset" %alien-global ;

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
    0 frame-required
    %prepare-alien-invoke
    "minor_gc" f %alien-invoke
    "end" resolve-label ;

M: ppc %prologue ( n -- )
    0 scrach-reg LOAD32 rc-absolute-ppc-2/2 rel-this
    0 MFLR
    1 1 pick neg ADDI
    scrach-reg 1 pick xt-save STW
    dup scrach-reg LI
    scrach-reg 1 pick next-save STW
    0 1 rot lr-save + STW ;

M: ppc %epilogue ( n -- )
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    0 1 pick lr-save + LWZ
    1 1 rot ADDI
    0 MTLR ;

:: (%boolean) ( dst word -- )
    "end" define-label
    \ f tag-number %load-immediate
    "end" get word execute
    dst \ t %load-indirect
    "end" get resolve-label ; inline

: %boolean ( dst cc -- )
    negate-cc {
        { cc< [ \ BLT %boolean ] }
        { cc<= [ \ BLE %boolean ] }
        { cc> [ \ BGT %boolean ] }
        { cc>= [ \ BGE %boolean ] }
        { cc= [ \ BEQ %boolean ] }
        { cc/= [ \ BNE %boolean ] }
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

! M: ppc %spill-integer ( src n -- ) spill-integer@ swap MOV ;
! M: ppc %reload-integer ( dst n -- ) spill-integer@ MOV ;
! 
! M: ppc %spill-float ( src n -- ) spill-float@ swap MOVSD ;
! M: ppc %reload-float ( dst n -- ) spill-float@ MOVSD ;

M: ppc %loop-entry ;

M: int-regs return-reg drop 3 ;
M: int-regs param-regs drop { 3 4 5 6 7 8 9 10 } ;
M: float-regs return-reg drop 1 ;
M: float-regs param-regs 
    drop os H{
        { macosx { 1 2 3 4 5 6 7 8 9 10 11 12 13 } }
        { linux { 1 2 3 4 5 6 7 8 } }
    } at ;

M: int-regs %save-param-reg drop 1 rot local@ STW ;
M: int-regs %load-param-reg drop 1 rot local@ LWZ ;

GENERIC: STF ( src dst off reg-class -- )

M: single-float-regs STF drop STFS ;
M: double-float-regs STF drop STFD ;

M: float-regs %save-param-reg >r 1 rot local@ r> STF ;

GENERIC: LF ( dst src off reg-class -- )

M: single-float-regs LF drop LFS ;
M: double-float-regs LF drop LFD ;

M: float-regs %load-param-reg >r 1 rot local@ r> LF ;

M: stack-params %load-param-reg ( stack reg reg-class -- )
    drop >r 0 1 rot local@ LWZ 0 1 r> param@ STW ;

: next-param@ ( n -- x ) param@ stack-frame get total-size>> + ;

M: stack-params %save-param-reg ( stack reg reg-class -- )
    #! Funky. Read the parameter from the caller's stack frame.
    #! This word is used in callbacks
    drop
    0 1 rot next-param@ LWZ
    0 1 rot local@ STW ;

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
        3 1 pick local@ STW
        4 1 rot cell + local@ STW
    ] when* ;

M: ppc %unbox-large-struct ( n c-type -- )
    ! Value must be in r3
    ! Compute destination address and load struct size
    [ 4 1 rot local@ ADDI ] [ heap-size 5 LI ] bi*
    ! Call the function
    "to_value_struct" f %alien-invoke ;

M: ppc %box ( n reg-class func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    >r
    over [ 0 over param-reg swap %load-param-reg ] [ 2drop ] if
    r> f %alien-invoke ;

M: ppc %box-long-long ( n func -- )
    >r [
        3 1 pick local@ LWZ
        4 1 rot cell + local@ LWZ
    ] when* r> f %alien-invoke ;

: struct-return@ ( n -- n )
    [ stack-frame get params>> ] unless* local@ ;

M: ppc %prepare-box-struct ( -- )
    #! Compute target address for value struct return
    3 1 f struct-return@ ADDI
    3 1 0 local@ STW ;

M: ppc %box-large-struct ( n c-type -- )
    ! If n = f, then we're boxing a returned struct
    ! Compute destination address and load struct size
    [ 3 1 rot struct-return@ ADDI ] [ heap-size 4 LI ] bi*
    ! Call the function
    "box_value_struct" f %alien-invoke ;

M: ppc %prepare-alien-invoke
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "stack_chain" f 11 %load-dlsym
    11 11 0 LWZ
    1 11 0 STW
    ds-reg 11 8 STW
    rs-reg 11 12 STW ;

M: ppc %alien-invoke ( symbol dll -- )
    11 %load-dlsym 11 MTLR BLRL ;

M: ppc %alien-callback ( quot -- )
    3 load-indirect "c_to_factor" f %alien-invoke ;

M: ppc %prepare-alien-indirect ( -- )
    "unbox_alien" f %alien-invoke
    13 3 MR ;

M: ppc %alien-indirect ( -- )
    13 MTLR BLRL ;

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

M: ppc value-structs?
    #! On Linux/PPC, value structs are passed in the same way
    #! as reference structs, we just have to make a copy first.
    os linux? not ;

M: ppc fp-shadows-int? ( -- ? ) os macosx? ;

M: ppc small-enough? ( n -- ? ) -32768 32767 between? ;

M: ppc struct-small-enough? ( size -- ? ) drop f ;

M: ppc %box-small-struct
    drop "No small structs" throw ;

M: ppc %unbox-small-struct
    drop "No small structs" throw ;
