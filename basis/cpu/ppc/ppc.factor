! Copyright (C) 2005, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs sequences kernel combinators make math
math.order math.ranges system namespaces locals layouts words
alien alien.accessors alien.c-types alien.complex alien.data
literals cpu.architecture cpu.ppc.assembler
cpu.ppc.assembler.backend compiler.cfg.registers
compiler.cfg.instructions compiler.cfg.comparisons
compiler.codegen.fixup compiler.cfg.intrinsics
compiler.cfg.stack-frame compiler.cfg.build-stack-frame
compiler.units compiler.constants compiler.codegen vm ;
FROM: cpu.ppc.assembler => B ;
FROM: layouts => cell ;
FROM: math => float ;
IN: cpu.ppc

! PowerPC register assignments:
! r2-r12: integer vregs
! r13: data stack
! r14: retain stack
! r15: VM pointer
! r16-r29: integer vregs
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
        { int-regs $[ 2 12 [a,b] 16 29 [a,b] append ] }
        { float-regs $[ 0 29 [a,b] ] }
    } ;

CONSTANT: scratch-reg 30
CONSTANT: fp-scratch-reg 30

M: ppc %load-immediate ( reg n -- ) swap LOAD ;

M: ppc %load-reference ( reg obj -- )
    [ 0 swap LOAD32 ] [ rc-absolute-ppc-2/2 rel-literal ] bi* ;

M: ppc %alien-global ( register symbol dll -- )
    [ 0 swap LOAD32 ] 2dip rc-absolute-ppc-2/2 rel-dlsym ;

CONSTANT: ds-reg 13
CONSTANT: rs-reg 14
CONSTANT: vm-reg 15

: %load-vm-addr ( reg -- ) vm-reg MR ;

M: ppc %vm-field ( dst field -- ) [ vm-reg ] dip LWZ ;

M: ppc %set-vm-field ( src field -- ) [ vm-reg ] dip STW ;

GENERIC: loc-reg ( loc -- reg )

M: ds-loc loc-reg drop ds-reg ;
M: rs-loc loc-reg drop rs-reg ;

: loc>operand ( loc -- reg n )
    [ loc-reg ] [ n>> cells neg ] bi ; inline

M: ppc %peek loc>operand LWZ ;
M: ppc %replace loc>operand STW ;

:: (%inc) ( n reg -- ) reg reg n cells ADDI ; inline

M: ppc %inc-d ( n -- ) ds-reg (%inc) ;
M: ppc %inc-r ( n -- ) rs-reg (%inc) ;

HOOK: reserved-area-size os ( -- n )

! The start of the stack frame contains the size of this frame
! as well as the currently executing code block
: factor-area-size ( -- n ) 2 cells ; foldable
: next-save ( n -- i ) cell - ; foldable
: xt-save ( n -- i ) 2 cells - ; foldable

! Next, we have the spill area as well as the FFI parameter area.
! It is safe for them to overlap, since basic blocks with FFI calls
! will never spill -- indeed, basic blocks with FFI calls do not
! use vregs at all, and the FFI call is a stack analysis sync point.
! In the future this will change and the stack frame logic will
! need to be untangled somewhat.

: param@ ( n -- x ) reserved-area-size + ; inline

: param-save-size ( -- n ) 8 cells ; foldable

: local@ ( n -- x )
    reserved-area-size param-save-size + + ; inline

: spill@ ( n -- offset )
    spill-offset local@ ;

! Some FP intrinsics need a temporary scratch area in the stack
! frame, 8 bytes in size. This is in the param-save area so it
! does not overlap with spill slots.
: scratch@ ( n -- offset )
    factor-area-size + ;

! GC root area
: gc-root@ ( n -- offset )
    gc-root-offset local@ ;

! Finally we have the linkage area
HOOK: lr-save os ( -- n )

M: ppc stack-frame-size ( stack-frame -- i )
    (stack-frame-size)
    param-save-size +
    reserved-area-size +
    factor-area-size +
    4 cells align ;

M: ppc %call ( word -- ) 0 BL rc-relative-ppc-3 rel-word-pic ;

M: ppc %jump ( word -- )
    0 6 LOAD32 4 rc-absolute-ppc-2/2 rel-here
    0 B rc-relative-ppc-3 rel-word-pic-tail ;

M: ppc %jump-label ( label -- ) B ;
M: ppc %return ( -- ) BLR ;

M:: ppc %dispatch ( src temp -- )
    0 temp LOAD32
    3 cells rc-absolute-ppc-2/2 rel-here
    temp temp src LWZX
    temp MTCTR
    BCTR ;

M: ppc %slot ( dst obj slot -- ) swapd LWZX ;
M: ppc %slot-imm ( dst obj slot tag -- ) slot-offset LWZ ;
M: ppc %set-slot ( src obj slot -- ) swapd STWX ;
M: ppc %set-slot-imm ( src obj slot tag -- ) slot-offset STW ;

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
M: ppc %shl     SLW ;
M: ppc %shl-imm swapd SLWI ;
M: ppc %shr     SRW ;
M: ppc %shr-imm swapd SRWI ;
M: ppc %sar     SRAW ;
M: ppc %sar-imm SRAWI ;
M: ppc %not     NOT ;
M: ppc %neg     NEG ;

:: overflow-template ( label dst src1 src2 insn -- )
    0 0 LI
    0 MTXER
    dst src2 src1 insn call
    label BO ; inline

M: ppc %fixnum-add ( label dst src1 src2 -- )
    [ ADDO. ] overflow-template ;

M: ppc %fixnum-sub ( label dst src1 src2 -- )
    [ SUBFO. ] overflow-template ;

M: ppc %fixnum-mul ( label dst src1 src2 -- )
    [ MULLWO. ] overflow-template ;

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

M: ppc %copy ( dst src rep -- )
    2over eq? [ 3drop ] [
        {
            { int-rep [ MR ] }
            { double-rep [ FMR ] }
        } case
    ] if ;

GENERIC: float-function-param* ( dst src -- )

M: spill-slot float-function-param* [ 1 ] dip n>> spill@ LFD ;
M: integer float-function-param* FMR ;

: float-function-param ( i src -- )
    [ float-regs cdecl param-regs nth ] dip float-function-param* ;

: float-function-return ( reg -- )
    float-regs return-reg double-rep %copy ;

M:: ppc %unary-float-function ( dst src func -- )
    0 src float-function-param
    func f %alien-invoke
    dst float-function-return ;

M:: ppc %binary-float-function ( dst src1 src2 func -- )
    0 src1 float-function-param
    1 src2 float-function-param
    func f %alien-invoke
    dst float-function-return ;

! Internal format is always double-precision on PowerPC
M: ppc %single>double-float double-rep %copy ;
M: ppc %double>single-float FRSP ;

M: ppc %unbox-alien ( dst src -- )
    alien-offset LWZ ;

M:: ppc %unbox-any-c-ptr ( dst src -- )
    [
        "end" define-label
        0 dst LI
        ! Is the object f?
        0 src \ f type-number CMPI
        "end" get BEQ
        ! Compute tag in dst register
        dst src tag-mask get ANDI
        ! Is the object an alien?
        0 dst alien type-number CMPI
        ! Add an offset to start of byte array's data
        dst src byte-array-offset ADDI
        "end" get BNE
        ! If so, load the offset and add it to the address
        dst src alien-offset LWZ
        "end" resolve-label
    ] with-scope ;

: alien@ ( n -- n' ) cells alien type-number - ;

M:: ppc %box-alien ( dst src temp -- )
    [
        "f" define-label
        dst \ f type-number %load-immediate
        0 src 0 CMPI
        "f" get BEQ
        dst 5 cells alien temp %allot
        temp \ f type-number %load-immediate
        temp dst 1 alien@ STW
        temp dst 2 alien@ STW
        src dst 3 alien@ STW
        src dst 4 alien@ STW
        "f" resolve-label
    ] with-scope ;

M:: ppc %box-displaced-alien ( dst displacement base temp base-class -- )
    ! This is ridiculous
    [
        "end" define-label
        "not-f" define-label
        "not-alien" define-label

        ! If displacement is zero, return the base
        dst base MR
        0 displacement 0 CMPI
        "end" get BEQ

        ! Displacement is non-zero, we're going to be allocating a new
        ! object
        dst 5 cells alien temp %allot

        ! Set expired to f
        temp \ f type-number %load-immediate
        temp dst 2 alien@ STW

        ! Is base f?
        0 base \ f type-number CMPI
        "not-f" get BNE

        ! Yes, it is f. Fill in new object
        base dst 1 alien@ STW
        displacement dst 3 alien@ STW
        displacement dst 4 alien@ STW

        "end" get B

        "not-f" resolve-label

        ! Check base type
        temp base tag-mask get ANDI

        ! Is base an alien?
        0 temp alien type-number CMPI
        "not-alien" get BNE

        ! Yes, it is an alien. Set new alien's base to base.base
        temp base 1 alien@ LWZ
        temp dst 1 alien@ STW

        ! Compute displacement
        temp base 3 alien@ LWZ
        temp temp displacement ADD
        temp dst 3 alien@ STW

        ! Compute address
        temp base 4 alien@ LWZ
        temp temp displacement ADD
        temp dst 4 alien@ STW

        ! We are done
        "end" get B

        ! Is base a byte array? It has to be, by now...
        "not-alien" resolve-label

        base dst 1 alien@ STW
        displacement dst 3 alien@ STW
        temp base byte-array-offset ADDI
        temp temp displacement ADD
        temp dst 4 alien@ STW

        "end" resolve-label
    ] with-scope ;

M: ppc %alien-unsigned-1 LBZ ;
M: ppc %alien-unsigned-2 LHZ ;

M: ppc %alien-signed-1 [ dup ] 2dip LBZ dup EXTSB ;
M: ppc %alien-signed-2 LHA ;

M: ppc %alien-cell LWZ ;

M: ppc %alien-float LFS ;
M: ppc %alien-double LFD ;

M: ppc %set-alien-integer-1 -rot STB ;
M: ppc %set-alien-integer-2 -rot STH ;

M: ppc %set-alien-cell -rot STW ;

M: ppc %set-alien-float -rot STFS ;
M: ppc %set-alien-double -rot STFD ;

: load-zone-ptr ( reg -- )
    vm-reg "nursery" vm-field-offset ADDI ;

: load-allot-ptr ( nursery-ptr allot-ptr -- )
    [ drop load-zone-ptr ] [ swap 0 LWZ ] 2bi ;

:: inc-allot-ptr ( nursery-ptr allot-ptr n -- )
    scratch-reg allot-ptr n data-alignment get align ADDI
    scratch-reg nursery-ptr 0 STW ;

:: store-header ( dst class -- )
    class type-number tag-header scratch-reg LI
    scratch-reg dst 0 STW ;

: store-tagged ( dst tag -- )
    dupd type-number ORI ;

M:: ppc %allot ( dst size class nursery-ptr -- )
    nursery-ptr dst load-allot-ptr
    nursery-ptr dst size inc-allot-ptr
    dst class store-header
    dst class store-tagged ;

: load-cards-offset ( dst -- )
    0 swap LOAD32 rc-absolute-ppc-2/2 rel-cards-offset ;

: load-decks-offset ( dst -- )
    0 swap LOAD32 rc-absolute-ppc-2/2 rel-decks-offset ;

:: (%write-barrier) ( temp1 temp2 -- )
    card-mark scratch-reg LI

    ! Mark the card
    temp1 temp1 card-bits SRWI
    temp2 load-cards-offset
    temp1 scratch-reg temp2 STBX

    ! Mark the card deck
    temp1 temp1 deck-bits card-bits - SRWI
    temp2 load-decks-offset
    temp1 scratch-reg temp2 STBX ;

M:: ppc %write-barrier ( src slot temp1 temp2 -- )
    temp1 src slot ADD
    temp1 temp2 (%write-barrier) ;

M:: ppc %write-barrier-imm ( src slot temp1 temp2 -- )
    temp1 src slot ADDI
    temp1 temp2 (%write-barrier) ;

M:: ppc %check-nursery ( label size temp1 temp2 -- )
    temp2 load-zone-ptr
    temp1 temp2 0 LWZ
    temp2 temp2 2 cells LWZ
    temp1 temp1 size ADDI
    ! is here >= end?
    temp1 0 temp2 CMP
    label BLE ;

M:: ppc %save-gc-root ( gc-root register -- )
    register 1 gc-root gc-root@ STW ;

M:: ppc %load-gc-root ( gc-root register -- )
    register 1 gc-root gc-root@ LWZ ;

M:: ppc %call-gc ( gc-root-count temp -- )
    3 1 gc-root-base local@ ADDI
    gc-root-count 4 LI
    5 %load-vm-addr
    "inline_gc" f %alien-invoke ;

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

:: (%boolean) ( dst temp branch1 branch2 -- )
    "end" define-label
    dst \ f type-number %load-immediate
    "end" get branch1 execute( label -- )
    branch2 [ "end" get branch2 execute( label -- ) ] when
    dst \ t %load-reference
    "end" get resolve-label ; inline

:: %boolean ( dst cc temp -- )
    cc negate-cc order-cc {
        { cc<  [ dst temp \ BLT f (%boolean) ] }
        { cc<= [ dst temp \ BLE f (%boolean) ] }
        { cc>  [ dst temp \ BGT f (%boolean) ] }
        { cc>= [ dst temp \ BGE f (%boolean) ] }
        { cc=  [ dst temp \ BEQ f (%boolean) ] }
        { cc/= [ dst temp \ BNE f (%boolean) ] }
    } case ;

: (%compare) ( src1 src2 -- ) [ 0 ] dip CMP ; inline
: (%compare-imm) ( src1 src2 -- ) [ 0 ] [ ] [ \ f type-number or ] tri* CMPI ; inline
: (%compare-float-unordered) ( src1 src2 -- ) [ 0 ] dip FCMPU ; inline
: (%compare-float-ordered) ( src1 src2 -- ) [ 0 ] dip FCMPO ; inline

:: (%compare-float) ( src1 src2 cc compare -- branch1 branch2 )
    cc {
        { cc<    [ src1 src2 \ compare execute( a b -- ) \ BLT f     ] }
        { cc<=   [ src1 src2 \ compare execute( a b -- ) \ BLT \ BEQ ] }
        { cc>    [ src1 src2 \ compare execute( a b -- ) \ BGT f     ] }
        { cc>=   [ src1 src2 \ compare execute( a b -- ) \ BGT \ BEQ ] }
        { cc=    [ src1 src2 \ compare execute( a b -- ) \ BEQ f     ] }
        { cc<>   [ src1 src2 \ compare execute( a b -- ) \ BLT \ BGT ] }
        { cc<>=  [ src1 src2 \ compare execute( a b -- ) \ BNO f     ] }
        { cc/<   [ src1 src2 \ compare execute( a b -- ) \ BGE f     ] }
        { cc/<=  [ src1 src2 \ compare execute( a b -- ) \ BGT \ BO  ] }
        { cc/>   [ src1 src2 \ compare execute( a b -- ) \ BLE f     ] }
        { cc/>=  [ src1 src2 \ compare execute( a b -- ) \ BLT \ BO  ] }
        { cc/=   [ src1 src2 \ compare execute( a b -- ) \ BNE f     ] }
        { cc/<>  [ src1 src2 \ compare execute( a b -- ) \ BEQ \ BO  ] }
        { cc/<>= [ src1 src2 \ compare execute( a b -- ) \ BO  f     ] }
    } case ; inline

M: ppc %compare [ (%compare) ] 2dip %boolean ;

M: ppc %compare-imm [ (%compare-imm) ] 2dip %boolean ;

M:: ppc %compare-float-ordered ( dst src1 src2 cc temp -- )
    src1 src2 cc negate-cc \ (%compare-float-ordered) (%compare-float) :> ( branch1 branch2 )
    dst temp branch1 branch2 (%boolean) ;

M:: ppc %compare-float-unordered ( dst src1 src2 cc temp -- )
    src1 src2 cc negate-cc \ (%compare-float-unordered) (%compare-float) :> ( branch1 branch2 )
    dst temp branch1 branch2 (%boolean) ;

:: %branch ( label cc -- )
    cc order-cc {
        { cc<  [ label BLT ] }
        { cc<= [ label BLE ] }
        { cc>  [ label BGT ] }
        { cc>= [ label BGE ] }
        { cc=  [ label BEQ ] }
        { cc/= [ label BNE ] }
    } case ;

M:: ppc %compare-branch ( label src1 src2 cc -- )
    src1 src2 (%compare)
    label cc %branch ;

M:: ppc %compare-imm-branch ( label src1 src2 cc -- )
    src1 src2 (%compare-imm)
    label cc %branch ;

:: (%branch) ( label branch1 branch2 -- )
    label branch1 execute( label -- )
    branch2 [ label branch2 execute( label -- ) ] when ; inline

M:: ppc %compare-float-ordered-branch ( label src1 src2 cc -- )
    src1 src2 cc \ (%compare-float-ordered) (%compare-float) :> ( branch1 branch2 )
    label branch1 branch2 (%branch) ;

M:: ppc %compare-float-unordered-branch ( label src1 src2 cc -- )
    src1 src2 cc \ (%compare-float-unordered) (%compare-float) :> ( branch1 branch2 )
    label branch1 branch2 (%branch) ;

: load-from-frame ( dst n rep -- )
    {
        { int-rep [ [ 1 ] dip LWZ ] }
        { float-rep [ [ 1 ] dip LFS ] }
        { double-rep [ [ 1 ] dip LFD ] }
        { stack-params [ [ 0 1 ] dip LWZ [ 0 1 ] dip param@ STW ] }
    } case ;

: next-param@ ( n -- reg x )
    [ 17 ] dip param@ ;

: store-to-frame ( src n rep -- )
    {
        { int-rep [ [ 1 ] dip STW ] }
        { float-rep [ [ 1 ] dip STFS ] }
        { double-rep [ [ 1 ] dip STFD ] }
        { stack-params [ [ [ 0 ] dip next-param@ LWZ 0 1 ] dip STW ] }
    } case ;

M: ppc %spill ( src rep dst -- )
    swap [ n>> spill@ ] dip store-to-frame ;

M: ppc %reload ( dst rep src -- )
    swap [ n>> spill@ ] dip load-from-frame ;

M: ppc %loop-entry ;

M: int-regs return-reg drop 3 ;
M: int-regs param-regs 2drop { 3 4 5 6 7 8 9 10 } ;
M: float-regs return-reg drop 1 ;

M:: ppc %save-param-reg ( stack reg rep -- )
    reg stack local@ rep store-to-frame ;

M:: ppc %load-param-reg ( stack reg rep -- )
    reg stack local@ rep load-from-frame ;

M: ppc %pop-stack ( n -- )
    [ 3 ] dip <ds-loc> loc>operand LWZ ;

M: ppc %push-stack ( -- )
    ds-reg ds-reg 4 ADDI
    int-regs return-reg ds-reg 0 STW ;

M: ppc %push-context-stack ( -- )
    11 %context
    12 11 "datastack" context-field-offset LWZ
    12 12 4 ADDI
    12 11 "datastack" context-field-offset STW
    int-regs return-reg 12 0 STW ;

M: ppc %pop-context-stack ( -- )
    11 %context
    12 11 "datastack" context-field-offset LWZ
    int-regs return-reg 12 0 LWZ
    12 12 4 SUBI
    12 11 "datastack" context-field-offset STW ;

M: ppc %unbox ( n rep func -- )
    ! Value must be in r3
    4 %load-vm-addr
    ! Call the unboxer
    f %alien-invoke
    ! Store the return value on the C stack
    over [ [ reg-class-of return-reg ] keep %save-param-reg ] [ 2drop ] if ;

M: ppc %unbox-long-long ( n func -- )
    4 %load-vm-addr
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
    6 %load-vm-addr
    ! Call the function
    "to_value_struct" f %alien-invoke ;

M:: ppc %box ( n rep func -- )
    ! If the source is a stack location, load it into freg #0.
    ! If the source is f, then we assume the value is already in
    ! freg #0.
    n [ 0 rep reg-class-of cdecl param-reg rep %load-param-reg ] when*
    rep double-rep? 5 4 ? %load-vm-addr
    func f %alien-invoke ;

M: ppc %box-long-long ( n func -- )
    [
        [
            [ [ 3 1 ] dip local@ LWZ ]
            [ [ 4 1 ] dip cell + local@ LWZ ] bi
        ] when*
        5 %load-vm-addr
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
    5 %load-vm-addr
    ! Call the function
    "from_value_struct" f %alien-invoke ;

M:: ppc %restore-context ( temp1 temp2 -- )
    temp1 %context
    ds-reg temp1 "datastack" context-field-offset LWZ
    rs-reg temp1 "retainstack" context-field-offset LWZ ;

M:: ppc %save-context ( temp1 temp2 -- )
    temp1 %context
    1 temp1 "callstack-top" context-field-offset STW
    ds-reg temp1 "datastack" context-field-offset STW
    rs-reg temp1 "retainstack" context-field-offset STW ;

M: ppc %alien-invoke ( symbol dll -- )
    [ 11 ] 2dip %alien-global 11 MTLR BLRL ;

M: ppc %prepare-alien-indirect ( -- )
    3 ds-reg 0 LWZ
    ds-reg ds-reg 4 SUBI
    4 %load-vm-addr
    "pinned_alien_offset" f %alien-invoke
    16 3 MR ;

M: ppc %alien-indirect ( -- )
    16 MTLR BLRL ;

M: ppc immediate-arithmetic? ( n -- ? ) -32768 32767 between? ;

M: ppc immediate-bitwise? ( n -- ? ) 0 65535 between? ;

M: ppc struct-return-pointer-type void* ;

M: ppc return-struct-in-registers? ( c-type -- ? )
    c-type return-in-registers?>> ;

M: ppc %box-small-struct ( c-type -- )
    #! Box a <= 16-byte struct returned in r3:r4:r5:r6
    heap-size 7 LI
    8 %load-vm-addr
    "from_medium_struct" f %alien-invoke ;

: %unbox-struct-1 ( -- )
    ! Alien must be in r3.
    4 %load-vm-addr
    "alien_offset" f %alien-invoke
    3 3 0 LWZ ;

: %unbox-struct-2 ( -- )
    ! Alien must be in r3.
    4 %load-vm-addr
    "alien_offset" f %alien-invoke
    4 3 4 LWZ
    3 3 0 LWZ ;

: %unbox-struct-4 ( -- )
    ! Alien must be in r3.
    4 %load-vm-addr
    "alien_offset" f %alien-invoke
    6 3 12 LWZ
    5 3 8 LWZ
    4 3 4 LWZ
    3 3 0 LWZ ;

M: ppc %begin-callback ( -- )
    3 %load-vm-addr
    "begin_callback" f %alien-invoke ;

M: ppc %alien-callback ( quot -- )
    3 4 %restore-context
    3 swap %load-reference
    4 3 quot-entry-point-offset LWZ
    4 MTLR
    BLRL
    3 4 %save-context ;

M: ppc %end-callback ( -- )
    3 %load-vm-addr
    "end_callback" f %alien-invoke ;

M: ppc %end-callback-value ( ctype -- )
    ! Save top of data stack
    16 ds-reg 0 LWZ
    %end-callback
    ! Restore top of data stack
    3 16 MR
    ! Unbox former top of data stack to return registers
    unbox-return ;

M: ppc %unbox-small-struct ( size -- )
    heap-size cell align cell /i {
        { 1 [ %unbox-struct-1 ] }
        { 2 [ %unbox-struct-2 ] }
        { 4 [ %unbox-struct-4 ] }
    } case ;

enable-float-functions

USE: vocabs.loader

{
    { [ os macosx? ] [ "cpu.ppc.macosx" require ] }
    { [ os linux? ] [ "cpu.ppc.linux" require ] }
} cond

complex-double c-type t >>return-in-registers? drop
