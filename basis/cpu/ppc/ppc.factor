! Copyright (C) 2011 Erik Charlebois
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.c-types alien.complex alien.data
alien.libraries assocs byte-arrays classes.algebra classes.struct combinators
compiler.cfg compiler.cfg.build-stack-frame compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen compiler.codegen.fixup
compiler.constants compiler.units cpu.architecture cpu.ppc.assembler fry io
kernel layouts literals locals make math math.order ranges memory
namespaces prettyprint sequences system vm words ;
QUALIFIED-WITH: alien.c-types c
FROM: cpu.ppc.assembler => B ;
FROM: math => float ;
IN: cpu.ppc

! PowerPC register assignments:
! r0: reserved for function prolog/epilogues
! r1: call stack register
! r2: toc register / system reserved
! r3-r12: integer vregs
! r13: reserved by OS
! r14: data stack
! r15: retain stack
! r16: VM pointer
! r17-r29: integer vregs
! r30: integer scratch
! r31: frame register
! f0-f29: float vregs
! f30: float scratch
! f31: ?

HOOK: lr-save os ( -- n )
HOOK: has-toc os ( -- ? )
HOOK: reserved-area-size os ( -- n )
HOOK: allows-null-dereference os ( -- ? )

M: label B  [ 0 B  ] dip rc-relative-ppc-3-pc label-fixup ;
M: label BL [ 0 BL ] dip rc-relative-ppc-3-pc label-fixup ;
M: label BC [ 0 BC ] dip rc-relative-ppc-2-pc label-fixup ;

CONSTANT: scratch-reg    30
CONSTANT: fp-scratch-reg 30
CONSTANT: ds-reg         14
CONSTANT: rs-reg         15
CONSTANT: vm-reg         16

M: ppc machine-registers
    {
        { int-regs $[ 3 12 [a..b] 17 29 [a..b] append ] }
        { float-regs $[ 0 29 [a..b] ] }
    } ;

M: ppc frame-reg 31 ;
M: ppc.32 vm-stack-space 16 ;
M: ppc.64 vm-stack-space 32 ;
M: ppc complex-addressing? f ;

! PW1-PW8 parameter save slots
: param-save-size ( -- n ) 8 cells ; foldable
! here be spill slots
! xt, size
: factor-area-size ( -- n ) 2 cells ; foldable

: spill@ ( n -- offset )
    spill-offset reserved-area-size + param-save-size + ;

: param@ ( n -- offset )
    reserved-area-size + ;

M: ppc gc-root-offset
    n>> spill@ cell /i ;

: LOAD32 ( r n -- )
    [ -16 shift 0xffff bitand LIS ]
    [ dupd 0xffff bitand ORI ] 2bi ;

: LOAD64 ( r n -- )
    dupd {
        [ nip -48 shift 0xffff bitand LIS ]
        [ -32 shift 0xffff bitand ORI ]
        [ drop 32 SLDI ]
        [ -16 shift 0xffff bitand ORIS ]
        [ 0xffff bitand ORI ]
    } 3cleave ;

HOOK: %clear-tag-bits cpu ( dst src -- )
M: ppc.32 %clear-tag-bits tag-bits get CLRRWI ;
M: ppc.64 %clear-tag-bits tag-bits get CLRRDI ;

HOOK: %store-cell cpu ( dst src offset -- )
M: ppc.32 %store-cell STW ;
M: ppc.64 %store-cell STD ;

HOOK: %store-cell-x cpu ( dst src offset -- )
M: ppc.32 %store-cell-x STWX ;
M: ppc.64 %store-cell-x STDX ;

HOOK: %store-cell-update cpu ( dst src offset -- )
M: ppc.32 %store-cell-update STWU ;
M: ppc.64 %store-cell-update STDU ;

HOOK: %load-cell cpu ( dst src offset -- )
M: ppc.32 %load-cell LWZ ;
M: ppc.64 %load-cell LD ;

HOOK: %trap-null cpu ( src -- )
M: ppc.32 %trap-null
    allows-null-dereference [ 0 TWEQI ] [ drop ] if ;
M: ppc.64 %trap-null
    allows-null-dereference [ 0 TDEQI ] [ drop ] if ;

HOOK: %load-cell-x cpu ( dst src offset -- )
M: ppc.32 %load-cell-x LWZX ;
M: ppc.64 %load-cell-x LDX ;

HOOK: %load-cell-imm cpu ( dst imm -- )
M: ppc.32 %load-cell-imm LOAD32 ;
M: ppc.64 %load-cell-imm LOAD64 ;

HOOK: %compare-cell cpu ( cr lhs rhs -- )
M: ppc.32 %compare-cell CMPW ;
M: ppc.64 %compare-cell CMPD ;

HOOK: %compare-cell-imm cpu ( cr lhs imm -- )
M: ppc.32 %compare-cell-imm CMPWI ;
M: ppc.64 %compare-cell-imm CMPDI ;

HOOK: %load-cell-imm-rc cpu ( -- rel-class )
M: ppc.32 %load-cell-imm-rc rc-absolute-ppc-2/2 ;
M: ppc.64 %load-cell-imm-rc rc-absolute-ppc-2/2/2/2  ;

M: ppc.32 %load-immediate
    dup -0x8000 0x7fff between? [ LI ] [ LOAD32 ] if ;
M: ppc.64 %load-immediate
    dup -0x8000 0x7fff between? [ LI ] [ LOAD64 ] if ;

M: ppc %load-reference
    [ [ 0 %load-cell-imm ] [ %load-cell-imm-rc rel-literal ] bi* ]
    [ \ f type-number LI ]
    if* ;

M:: ppc %load-float ( dst val -- )
    scratch-reg 0 %load-cell-imm val %load-cell-imm-rc rel-binary-literal
    dst scratch-reg 0 LFS ;

M:: ppc %load-double ( dst val -- )
    scratch-reg 0 %load-cell-imm val %load-cell-imm-rc rel-binary-literal
    dst scratch-reg 0 LFD ;

M:: ppc %load-vector ( dst val rep -- )
    scratch-reg 0 %load-cell-imm val %load-cell-imm-rc rel-binary-literal
    dst 0 scratch-reg LVX ;

GENERIC: loc-reg ( loc -- reg )
M: ds-loc loc-reg drop ds-reg ;
M: rs-loc loc-reg drop rs-reg ;

! Load value at stack location loc into vreg.
M: ppc %peek
    [ loc-reg ] [ n>> cells neg ] bi %load-cell ;

! Replace value at stack location loc with value in vreg.
M: ppc %replace
    [ loc-reg ] [ n>> cells neg ] bi %store-cell ;

! Replace value at stack location with an immediate value.
M:: ppc %replace-imm ( src loc -- )
    loc loc-reg :> reg
    loc n>> cells neg :> offset
    src {
        { [ dup not ] [
            drop scratch-reg \ f type-number LI ] }
        { [ dup fixnum? ] [
            [ scratch-reg ] dip tag-fixnum LI ] }
        [ scratch-reg 0 LI rc-absolute rel-literal ]
    } cond
    scratch-reg reg offset %store-cell ;

M: ppc %clear
    297 swap %replace-imm ;

! Increment stack pointer by n cells.
M: ppc %inc
    [ ds-loc? [ ds-reg ds-reg ] [ rs-reg rs-reg ] if ] [ n>> ] bi cells ADDI ;

M: ppc stack-frame-size
    (stack-frame-size)
    reserved-area-size +
    param-save-size +
    factor-area-size +
    16 align ;

M: ppc %call
    0 BL rc-relative-ppc-3-pc rel-word-pic ;

: instrs ( n -- b ) 4 * ; inline

M: ppc %jump
    6 0 %load-cell-imm 1 instrs %load-cell-imm-rc rel-here
    0 B rc-relative-ppc-3-pc rel-word-pic-tail ;

M: ppc %dispatch
    [ nip 0 %load-cell-imm 3 instrs %load-cell-imm-rc rel-here ]
    [ swap dupd %load-cell-x ]
    [ nip MTCTR ] 2tri BCTR ;

M: ppc %slot
    [ 0 assert= ] bi@ %load-cell-x ;

M: ppc %slot-imm
    slot-offset scratch-reg swap LI
    scratch-reg %load-cell-x ;

M: ppc %set-slot
    [ 0 assert= ] bi@ %store-cell-x ;

M: ppc %set-slot-imm
    slot-offset [ scratch-reg ] dip LI scratch-reg %store-cell-x ;

M: ppc    %jump-label B     ;
M: ppc    %return     BLR   ;
M: ppc    %add        ADD   ;
M: ppc    %add-imm    ADDI  ;
M: ppc    %sub        SUB   ;
M: ppc    %sub-imm    SUBI  ;
M: ppc.32 %mul        MULLW ;
M: ppc.64 %mul        MULLD ;
M: ppc    %mul-imm    MULLI ;
M: ppc    %and        AND   ;
M: ppc    %and-imm    ANDI. ;
M: ppc    %or         OR    ;
M: ppc    %or-imm     ORI   ;
M: ppc    %xor        XOR   ;
M: ppc    %xor-imm    XORI  ;
M: ppc.32 %shl        SLW   ;
M: ppc.64 %shl        SLD   ;
M: ppc.32 %shl-imm    SLWI  ;
M: ppc.64 %shl-imm    SLDI  ;
M: ppc.32 %shr        SRW   ;
M: ppc.64 %shr        SRD   ;
M: ppc.32 %shr-imm    SRWI  ;
M: ppc.64 %shr-imm    SRDI  ;
M: ppc.32 %sar        SRAW  ;
M: ppc.64 %sar        SRAD  ;
M: ppc.32 %sar-imm    SRAWI ;
M: ppc.64 %sar-imm    SRADI ;
M: ppc.32 %min        [ 0 CMPW ] [ 0 ISEL ] 2bi ;
M: ppc.64 %min        [ 0 CMPD ] [ 0 ISEL ] 2bi ;
M: ppc.32 %max        [ 0 CMPW ] [ swap 0 ISEL ] 2bi ;
M: ppc.64 %max        [ 0 CMPD ] [ swap 0 ISEL ] 2bi ;
M: ppc    %not        NOT ;
M: ppc    %neg        NEG ;
M: ppc.32 %log2       [ CNTLZW ] [ drop dup NEG ] [ drop dup 31 ADDI ] 2tri ;
M: ppc.64 %log2       [ CNTLZD ] [ drop dup NEG ] [ drop dup 63 ADDI ] 2tri ;
M: ppc.32 %bit-count  POPCNTW ;
M: ppc.64 %bit-count  POPCNTD ;

M: ppc %copy
    2over eq? [ 3drop ] [
        {
            { tagged-rep [ MR ] }
            { int-rep    [ MR ] }
            { float-rep  [ FMR ] }
            { double-rep [ FMR ] }
            { vector-rep [ dup VOR ] }
            { scalar-rep [ dup VOR ] }
        } case
    ] if ;

:: overflow-template ( label dst src1 src2 cc insn -- )
    scratch-reg 0 LI
    scratch-reg MTXER
    dst src2 src1 insn call
    cc {
        { cc-o [ 0 label BSO ] }
        { cc/o [ 0 label BNS ] }
    } case ; inline

M: ppc %fixnum-add
    [ ADDO. ] overflow-template ;

M: ppc %fixnum-sub
    [ SUBFO. ] overflow-template ;

M: ppc.32 %fixnum-mul
    [ MULLWO. ] overflow-template ;
M: ppc.64 %fixnum-mul
    [ MULLDO. ] overflow-template ;

M: ppc %add-float FADD ;
M: ppc %sub-float FSUB ;
M: ppc %mul-float FMUL ;
M: ppc %div-float FDIV ;

M: ppc %min-float
    2dup [ scratch-reg ] 2dip FSUB
    [ scratch-reg ] 2dip FSEL ;

M: ppc %max-float
    2dup [ scratch-reg ] 2dip FSUB
    [ scratch-reg ] 2dip FSEL ;

M: ppc %sqrt                FSQRT ;
M: ppc %single>double-float FMR   ;
M: ppc %double>single-float FRSP  ;

M: ppc integer-float-needs-stack-frame? t ;

: scratch@ ( n -- offset )
    reserved-area-size + ;

M:: ppc.32 %integer>float ( dst src -- )
    ! Sign extend to a doubleword and store.
    scratch-reg src 31 %sar-imm
    scratch-reg 1 0 scratch@ STW
    src 1 4 scratch@ STW
    ! Load back doubleword into FPR and convert from integer.
    dst 1 0 scratch@ LFD
    dst dst FCFID ;

M:: ppc.64 %integer>float ( dst src -- )
    src 1 0 scratch@ STD
    dst 1 0 scratch@ LFD
    dst dst FCFID ;

M:: ppc.32 %float>integer ( dst src -- )
    fp-scratch-reg src FRIZ
    fp-scratch-reg fp-scratch-reg FCTIWZ
    fp-scratch-reg 1 0 scratch@ STFD
    dst 1 4 scratch@ LWZ ;

M:: ppc.64 %float>integer ( dst src -- )
    fp-scratch-reg src FRIZ
    fp-scratch-reg fp-scratch-reg FCTID
    fp-scratch-reg 1 0 scratch@ STFD
    dst 1 0 scratch@ LD ;

! Scratch registers by register class.
: scratch-regs ( -- regs )
    {
        { int-regs { 30 } }
        { float-regs { 30 } }
    } ;

! Return values of this class go here
M: ppc return-regs
    {
        { int-regs { 3 4 5 6 } }
        { float-regs { 1 2 3 4 } }
    } ;

! Is this structure small enough to be returned in registers?
M: ppc return-struct-in-registers?
    lookup-c-type return-in-registers?>> ;

! If t, the struct return pointer is never passed in a param reg
M: ppc struct-return-on-stack? f ;

GENERIC: load-param ( reg src -- )
M: integer load-param int-rep %copy ;
M: spill-slot load-param [ 1 ] dip n>> spill@ %load-cell ;

GENERIC: store-param ( reg dst -- )
M: integer store-param swap int-rep %copy ;
M: spill-slot store-param [ 1 ] dip n>> spill@ %store-cell ;

M:: ppc %unbox ( dst src func rep -- )
    3 src load-param
    4 vm-reg MR
    func f f %c-invoke
    3 dst store-param ;

M:: ppc %unbox-long-long ( dst1 dst2 src func -- )
    3 src load-param
    4 vm-reg MR
    func f f %c-invoke
    3 dst1 store-param
    4 dst2 store-param ;

M:: ppc %local-allot ( dst size align offset -- )
    dst 1 offset local-allot-offset reserved-area-size + ADDI ;

: param-reg ( n rep -- reg )
    reg-class-of cdecl param-regs at nth ;

M:: ppc %box ( dst src func rep gc-map -- )
    3 src load-param
    4 vm-reg MR
    func f gc-map %c-invoke
    3 dst store-param ;

M:: ppc %box-long-long ( dst src1 src2 func gc-map -- )
    3 src1 load-param
    4 src2 load-param
    5 vm-reg MR
    func f gc-map %c-invoke
    3 dst store-param ;

M:: ppc %save-context ( temp1 temp2 -- )
    temp1 %context
    1 temp1 "callstack-top" context offset-of %store-cell
    ds-reg temp1 "datastack" context offset-of %store-cell
    rs-reg temp1 "retainstack" context offset-of %store-cell ;

M:: ppc %c-invoke ( name dll gc-map -- )
    11 0 %load-cell-imm name dll %load-cell-imm-rc rel-dlsym
    has-toc [
        2 0 %load-cell-imm name dll %load-cell-imm-rc rel-dlsym-toc
    ] when
    11 MTCTR
    BCTRL
    gc-map gc-map-here ;

: return-reg ( rep -- reg )
    reg-class-of return-regs at first ;

: scratch-reg-class ( rep -- reg )
    reg-class-of scratch-regs at first ;

:: store-stack-param ( vreg rep n -- )
    rep scratch-reg-class rep vreg %reload
    rep scratch-reg-class n param@ rep {
        { int-rep    [ [ 1 ] dip %store-cell ] }
        { tagged-rep [ [ 1 ] dip %store-cell ] }
        { float-rep  [ [ 1 ] dip STFS ] }
        { double-rep [ [ 1 ] dip STFD ] }
        { vector-rep [ scratch-reg swap LI 1 scratch-reg STVX ] }
        { scalar-rep [ scratch-reg swap LI 1 scratch-reg STVX ] }
    } case ;

:: store-reg-param ( vreg rep reg -- )
    reg rep vreg %reload ;

: discard-reg-param ( rep reg -- )
    2drop ;

:: load-reg-param ( vreg rep reg -- )
    reg rep vreg %spill ;

:: load-stack-param ( vreg rep n -- )
    rep scratch-reg-class n param@ rep {
        { int-rep    [ [ frame-reg ] dip %load-cell ] }
        { tagged-rep [ [ frame-reg ] dip %load-cell ] }
        { float-rep  [ [ frame-reg ] dip LFS ] }
        { double-rep [ [ frame-reg ] dip LFD ] }
        { vector-rep [ scratch-reg swap LI frame-reg scratch-reg LVX ] }
        { scalar-rep [ scratch-reg swap LI frame-reg scratch-reg LVX ] }
    } case
    rep scratch-reg-class rep vreg %spill ;

:: emit-alien-insn ( varargs? reg-inputs stack-inputs
                     reg-outputs dead-outputs
                     cleanup stack-size
                     quot -- )
    stack-inputs [ first3 store-stack-param ] each
    reg-inputs [ first3 store-reg-param ] each
    quot call
    reg-outputs [ first3 load-reg-param ] each
    dead-outputs [ first2 discard-reg-param ] each
    ; inline

M: ppc %alien-invoke
    '[ _ _ _ %c-invoke ] emit-alien-insn ;

M:: ppc %alien-indirect ( src
                          varargs? reg-inputs stack-inputs
                          reg-outputs dead-outputs
                          cleanup stack-size
                          gc-map -- )
    reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size [
        has-toc [
            11 src load-param
            2 11 1 cells %load-cell
            11 11 0 cells %load-cell
        ] [
            11 src load-param
        ] if
        11 MTCTR
        BCTRL
        gc-map gc-map-here
    ] emit-alien-insn ;

M: ppc %alien-assembly
    '[ _ call( -- ) ] emit-alien-insn ;

M: ppc %callback-inputs
    [ [ first3 load-reg-param ] each ]
    [ [ first3 load-stack-param ] each ] bi*
    3 vm-reg MR
    4 0 LI
    "begin_callback" f f %c-invoke ;

M: ppc %callback-outputs
    3 vm-reg MR
    "end_callback" f f %c-invoke
    [ first3 store-reg-param ] each ;

M: ppc stack-cleanup
    3drop 0 ;

M: ppc fused-unboxing? f ;

M: ppc %alien-global
    [ 0 %load-cell-imm ] 2dip %load-cell-imm-rc rel-dlsym ;

M: ppc %vm-field     [ vm-reg ] dip %load-cell  ;
M: ppc %set-vm-field [ vm-reg ] dip %store-cell ;

M: ppc %unbox-alien
    scratch-reg alien-offset LI scratch-reg %load-cell-x ;

! Convert a c-ptr object to a raw C pointer.
! if (src == F_TYPE)
!   dst = NULL;
! else if ((src & tag_mask) == ALIEN_TYPE)
!   dst = ((alien*)src)->address;
! else // Assume (src & tag_mask) == BYTE_ARRAY_TYPE
!   dst = ((byte_array*)src) + 1;
M:: ppc %unbox-any-c-ptr ( dst src -- )
    <label> :> end
    ! Is the object f?
    dst 0 LI
    0 src \ f type-number %compare-cell-imm
    0 end BEQ

    ! Is the object an alien?
    dst src tag-mask get ANDI.
    ! Assume unboxing a byte-array.
    0 dst alien type-number %compare-cell-imm
    dst src byte-array-offset ADDI
    0 end BNE

    ! Unbox the alien.
    scratch-reg alien-offset LI
    dst src scratch-reg %load-cell-x
    end resolve-label ;

! Be very careful with this. It cannot be used as an immediate
! offset to a load or store.
: alien@ ( n -- n' ) cells alien type-number - ;

! Convert a raw C pointer to a c-ptr object.
! if (src == NULL)
!   dst = F_TYPE;
! else {
!   dst = allot_alien(NULL);
!   dst->base = F_TYPE;
!   dst->expired = F_TYPE;
!   dst->displacement = src;
!   dst->address = src;
! }
M:: ppc %box-alien ( dst src temp -- )
    <label> :> f-label

    ! Is the object f?
    dst \ f type-number LI
    0 src 0 %compare-cell-imm
    0 f-label BEQ

    ! Allocate and initialize an alien object.
    dst 5 cells alien temp %allot
    temp \ f type-number LI
    scratch-reg dst %clear-tag-bits
    temp scratch-reg 1 cells %store-cell
    temp scratch-reg 2 cells %store-cell
    src scratch-reg 3 cells %store-cell
    src scratch-reg 4 cells %store-cell

    f-label resolve-label ;

! dst->base = base;
! dst->displacement = displacement;
! dst->displacement = displacement;
:: box-displaced-alien/f ( dst displacement base -- )
    scratch-reg dst %clear-tag-bits
    base scratch-reg 1 cells %store-cell
    displacement scratch-reg 3 cells %store-cell
    displacement scratch-reg 4 cells %store-cell ;

! dst->base = base->base;
! dst->displacement = base->displacement + displacement;
! dst->address = base->address + displacement;
:: box-displaced-alien/alien ( dst displacement base temp -- )
    ! Set new alien's base to base.base
    scratch-reg 1 alien@ LI
    temp base scratch-reg %load-cell-x
    temp dst scratch-reg %store-cell-x

    ! Compute displacement
    scratch-reg 3 alien@ LI
    temp base scratch-reg %load-cell-x
    temp temp displacement ADD
    temp dst scratch-reg %store-cell-x

    ! Compute address
    scratch-reg 4 alien@ LI
    temp base scratch-reg %load-cell-x
    temp temp displacement ADD
    temp dst scratch-reg %store-cell-x ;

! dst->base = base;
! dst->displacement = displacement
! dst->address = base + sizeof(byte_array) + displacement
:: box-displaced-alien/byte-array ( dst displacement base temp -- )
    scratch-reg dst %clear-tag-bits
    base scratch-reg 1 cells %store-cell
    displacement scratch-reg 3 cells %store-cell
    temp base byte-array-offset ADDI
    temp temp displacement ADD
    temp scratch-reg 4 cells %store-cell ;

! if (base == F_TYPE)
!   box_displaced_alien_f(dst, displacement, base);
! else if ((base & tag_mask) == ALIEN_TYPE)
!   box_displaced_alien_alien(dst, displacement, base, temp);
! else
!   box_displaced_alien_byte_array(dst, displacement, base, temp);
:: box-displaced-alien/dynamic ( dst displacement base temp end -- )
    <label> :> not-f
    <label> :> not-alien

    ! Is base f?
    0 base \ f type-number %compare-cell-imm
    0 not-f BNE
    dst displacement base box-displaced-alien/f
    end B

    ! Is base an alien?
    not-f resolve-label
    temp base tag-mask get ANDI.
    0 temp alien type-number %compare-cell-imm
    0 not-alien BNE
    dst displacement base temp box-displaced-alien/alien
    end B

    ! Assume base is a byte array.
    not-alien resolve-label
    dst displacement base temp box-displaced-alien/byte-array ;

! if (displacement == 0)
!   dst = base;
! else {
!   dst = allot_alien(NULL);
!   dst->expired = F_TYPE;
!   if (is_subclass(base_class, F_TYPE))
!      box_displaced_alien_f(dst, displacement, base);
!   else if (is_subclass(base_class, ALIEN_TYPE))
!      box_displaced_alien_alien(dst, displacement, base, temp);
!   else if (is_subclass(base_class, BYTE_ARRAY_TYPE))
!      box_displaced_alien_byte_array(dst, displacement, base, temp);
!   else
!      box_displaced_alien_dynamic(dst, displacement, base, temp);
! }
M:: ppc %box-displaced-alien ( dst displacement base temp base-class -- )
    <label> :> end

    ! If displacement is zero, return the base.
    dst base MR
    0 displacement 0 %compare-cell-imm
    0 end BEQ

    ! Displacement is non-zero, we're going to be allocating a new
    ! object
    dst 5 cells alien temp %allot

    ! Set expired to f
    temp \ f type-number %load-immediate
    scratch-reg 2 alien@ LI
    temp dst scratch-reg %store-cell-x

    dst displacement base temp
    {
        { [ base-class \ f class<= ] [ drop box-displaced-alien/f ] }
        { [ base-class \ alien class<= ] [ box-displaced-alien/alien ] }
        { [ base-class \ byte-array class<= ] [ box-displaced-alien/byte-array ] }
        [ end box-displaced-alien/dynamic ]
    } cond

    end resolve-label ;

M:: ppc.32 %convert-integer ( dst src c-type -- )
    c-type {
        { c:char   [ dst src 24 CLRLWI dst dst EXTSB ] }
        { c:uchar  [ dst src 24 CLRLWI ] }
        { c:short  [ dst src 16 CLRLWI dst dst EXTSH ] }
        { c:ushort [ dst src 16 CLRLWI ] }
        { c:int    [ ] }
        { c:uint   [ ] }
    } case ;

M:: ppc.64 %convert-integer ( dst src c-type -- )
    c-type {
        { c:char      [ dst src 56 CLRLDI dst dst EXTSB ] }
        { c:uchar     [ dst src 56 CLRLDI ] }
        { c:short     [ dst src 48 CLRLDI dst dst EXTSH ] }
        { c:ushort    [ dst src 48 CLRLDI ] }
        { c:int       [ dst src 32 CLRLDI dst dst EXTSW ] }
        { c:uint      [ dst src 32 CLRLDI ] }
        { c:longlong  [ ] }
        { c:ulonglong [ ] }
    } case ;

M: ppc.32 %load-memory-imm
    or* [
        pick %trap-null
        {
            { c:char   [ [ dup ] 2dip LBZ dup EXTSB ] }
            { c:uchar  [ LBZ ] }
            { c:short  [ LHA ] }
            { c:ushort [ LHZ ] }
            { c:int    [ LWZ ] }
            { c:uint   [ LWZ ] }
        } case
    ] [
        {
            { int-rep    [ LWZ ] }
            { float-rep  [ LFS ] }
            { double-rep [ LFD ] }
        } case
    ] if ;

M: ppc.64 %load-memory-imm
    or* [
        pick %trap-null
        {
            { c:char      [ [ dup ] 2dip LBZ dup EXTSB ] }
            { c:uchar     [ LBZ ] }
            { c:short     [ LHA ] }
            { c:ushort    [ LHZ ] }
            { c:int       [ LWZ ] }
            { c:uint      [ LWZ ] }
            { c:longlong  [ [ scratch-reg ] dip LI scratch-reg LDX ] }
            { c:ulonglong [ [ scratch-reg ] dip LI scratch-reg LDX ] }
        } case
    ] [
        {
            { int-rep    [ [ scratch-reg ] dip LI scratch-reg LDX  ] }
            { float-rep  [ [ scratch-reg ] dip LI scratch-reg LFSX ] }
            { double-rep [ [ scratch-reg ] dip LI scratch-reg LFDX ] }
        } case
    ] if ;


M: ppc.32 %load-memory
    [ [ 0 assert= ] bi@ ] 2dip
    or* [
        pick %trap-null
        {
            { c:char   [ [ LBZX ] [ drop dup EXTSB ] 2bi ] }
            { c:uchar  [ LBZX ] }
            { c:short  [ LHAX ] }
            { c:ushort [ LHZX ] }
            { c:int    [ LWZX ] }
            { c:uint   [ LWZX ] }
        } case
    ] [
        {
            { int-rep    [ LWZX ] }
            { float-rep  [ LFSX ] }
            { double-rep [ LFDX ] }
        } case
    ] if ;

M: ppc.64 %load-memory
    [ [ 0 assert= ] bi@ ] 2dip
    or* [
        pick %trap-null
        {
            { c:char      [ [ LBZX ] [ drop dup EXTSB ] 2bi ] }
            { c:uchar     [ LBZX ] }
            { c:short     [ LHAX ] }
            { c:ushort    [ LHZX ] }
            { c:int       [ LWZX ] }
            { c:uint      [ LWZX ] }
            { c:longlong  [ LDX  ] }
            { c:ulonglong [ LDX  ] }
        } case
    ] [
        {
            { int-rep    [ LDX  ] }
            { float-rep  [ LFSX ] }
            { double-rep [ LFDX ] }
        } case
    ] if ;


M: ppc.32 %store-memory-imm
    or* [
        {
            { c:char   [ STB ] }
            { c:uchar  [ STB ] }
            { c:short  [ STH ] }
            { c:ushort [ STH ] }
            { c:int    [ STW ] }
            { c:uint   [ STW ] }
        } case
    ] [
        {
            { int-rep    [ STW  ] }
            { float-rep  [ STFS ] }
            { double-rep [ STFD ] }
        } case
    ] if ;

M: ppc.64 %store-memory-imm
    or* [
        {
            { c:char      [ STB ] }
            { c:uchar     [ STB ] }
            { c:short     [ STH ] }
            { c:ushort    [ STH ] }
            { c:int       [ STW ] }
            { c:uint      [ STW ] }
            { c:longlong  [ [ scratch-reg ] dip LI scratch-reg STDX ] }
            { c:ulonglong [ [ scratch-reg ] dip LI scratch-reg STDX ] }
        } case
    ] [
        {
            { int-rep    [ [ scratch-reg ] dip LI scratch-reg STDX  ] }
            { float-rep  [ [ scratch-reg ] dip LI scratch-reg STFSX ] }
            { double-rep [ [ scratch-reg ] dip LI scratch-reg STFDX ] }
        } case
    ] if ;

M: ppc.32 %store-memory
    [ [ 0 assert= ] bi@ ] 2dip
    or* [
        {
            { c:char   [ STBX ] }
            { c:uchar  [ STBX ] }
            { c:short  [ STHX ] }
            { c:ushort [ STHX ] }
            { c:int    [ STWX ] }
            { c:uint   [ STWX ] }
        } case
    ] [
        {
            { int-rep    [ STWX  ] }
            { float-rep  [ STFSX ] }
            { double-rep [ STFDX ] }
        } case
    ] if ;

M: ppc.64 %store-memory
    [ [ 0 assert= ] bi@ ] 2dip
    or* [
        {
            { c:char      [ STBX ] }
            { c:uchar     [ STBX ] }
            { c:short     [ STHX ] }
            { c:ushort    [ STHX ] }
            { c:int       [ STWX ] }
            { c:uint      [ STWX ] }
            { c:longlong  [ STDX ] }
            { c:ulonglong [ STDX ] }
        } case
    ] [
        {
            { int-rep    [ STDX  ] }
            { float-rep  [ STFSX ] }
            { double-rep [ STFDX ] }
        } case
    ] if ;

M:: ppc %allot ( dst size class nursery-ptr -- )
    ! dst = vm->nursery.here;
    nursery-ptr vm-reg "nursery" vm offset-of ADDI
    dst nursery-ptr 0 %load-cell
    ! vm->nursery.here += align(size, data_alignment);
    scratch-reg dst size data-alignment get align ADDI
    scratch-reg nursery-ptr 0 %store-cell
    ! ((object*) dst)->header = type_number << 2;
    scratch-reg class type-number tag-header LI
    scratch-reg dst 0 %store-cell
    ! dst |= type_number
    dst dst class type-number ORI ;

:: (%write-barrier) ( temp1 temp2 -- )
    scratch-reg card-mark LI
    ! *(char *)(cards_offset + ((cell)slot_ptr >> card_bits))
    !    = card_mark_mask;
    temp1 temp1 card-bits %shr-imm
    temp2 0 %load-cell-imm %load-cell-imm-rc rel-cards-offset
    scratch-reg temp1 temp2 STBX
    ! *(char *)(decks_offset + ((cell)slot_ptr >> deck_bits))
    !    = card_mark_mask;
    temp1 temp1 deck-bits card-bits - %shr-imm
    temp2 0 %load-cell-imm %load-cell-imm-rc rel-decks-offset
    scratch-reg temp1 temp2 STBX ;

M:: ppc %write-barrier ( src slot scale tag temp1 temp2 -- )
    scale 0 assert= tag 0 assert=
    temp1 src slot ADD
    temp1 temp2 (%write-barrier) ;

M:: ppc %write-barrier-imm ( src slot tag temp1 temp2 -- )
    temp1 src slot tag slot-offset ADDI
    temp1 temp2 (%write-barrier) ;

M:: ppc %check-nursery-branch ( label size cc temp1 temp2 -- )
    ! if (vm->nursery.here + size >= vm->nursery.end) ...
    temp1 vm-reg "nursery" vm offset-of %load-cell
    temp2 vm-reg "nursery" vm offset-of 2 cells + %load-cell
    temp1 temp1 size ADDI
    0 temp1 temp2 %compare-cell
    cc {
        { cc<=  [ 0 label BLE ] }
        { cc/<= [ 0 label BGT ] }
    } case ;

M: ppc %call-gc
    \ minor-gc %call gc-map-here ;

M:: ppc %prologue ( stack-size -- )
    0 MFLR
    0 1 lr-save %store-cell
    11 0 %load-cell-imm %load-cell-imm-rc rel-this
    11 1 2 cells neg %store-cell
    11 stack-size LI
    11 1 1 cells neg %store-cell
    1 1 stack-size neg %store-cell-update ;

! At the end of each word that calls a subroutine, we store
! the previous link register value in r0 by popping it off
! the stack, set the link register to the contents of r0,
! and jump to the link register.
M:: ppc %epilogue ( stack-size -- )
    1 1 stack-size ADDI
    0 1 lr-save %load-cell
    0 MTLR ;

:: (%boolean) ( dst temp branch1 branch2 -- )
    "end" define-label
    dst \ f type-number %load-immediate
    0 "end" get branch1 execute( n addr -- )
    branch2 [ 0 "end" get branch2 execute( n addr -- ) ] when
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

: (%compare) ( src1 src2 -- ) [ 0 ] 2dip %compare-cell ; inline

: (%compare-integer-imm) ( src1 src2 -- )
    [ 0 ] 2dip %compare-cell-imm ; inline

: (%compare-imm) ( src1 src2 -- )
    [ tag-fixnum ] [ \ f type-number ] if* (%compare-integer-imm) ; inline

: (%compare-float-unordered) ( src1 src2 -- )
    [ 0 ] 2dip FCMPU ; inline

: (%compare-float-ordered) ( src1 src2 -- )
    [ 0 ] 2dip FCMPO ; inline

:: (%compare-float) ( src1 src2 cc compare -- branch1 branch2 )
    cc {
        { cc<    [ src1 src2 \ compare execute( a b -- ) \ BLT f     ] }
        { cc<=   [ src1 src2 \ compare execute( a b -- ) \ BLT \ BEQ ] }
        { cc>    [ src1 src2 \ compare execute( a b -- ) \ BGT f     ] }
        { cc>=   [ src1 src2 \ compare execute( a b -- ) \ BGT \ BEQ ] }
        { cc=    [ src1 src2 \ compare execute( a b -- ) \ BEQ f     ] }
        { cc<>   [ src1 src2 \ compare execute( a b -- ) \ BLT \ BGT ] }
        { cc<>=  [ src1 src2 \ compare execute( a b -- ) \ BNS f     ] }
        { cc/<   [ src1 src2 \ compare execute( a b -- ) \ BGE f     ] }
        { cc/<=  [ src1 src2 \ compare execute( a b -- ) \ BGT \ BSO ] }
        { cc/>   [ src1 src2 \ compare execute( a b -- ) \ BLE f     ] }
        { cc/>=  [ src1 src2 \ compare execute( a b -- ) \ BLT \ BSO ] }
        { cc/=   [ src1 src2 \ compare execute( a b -- ) \ BNE f     ] }
        { cc/<>  [ src1 src2 \ compare execute( a b -- ) \ BEQ \ BSO ] }
        { cc/<>= [ src1 src2 \ compare execute( a b -- ) \ BSO f     ] }
    } case ; inline

M: ppc %compare [ (%compare) ] 2dip %boolean ;

M: ppc %compare-imm [ (%compare-imm) ] 2dip %boolean ;

M: ppc %compare-integer-imm [ (%compare-integer-imm) ] 2dip %boolean ;

M:: ppc %compare-float-ordered ( dst src1 src2 cc temp -- )
    src1 src2 cc negate-cc \ (%compare-float-ordered) (%compare-float) :> ( branch1 branch2 )
    dst temp branch1 branch2 (%boolean) ;

M:: ppc %compare-float-unordered ( dst src1 src2 cc temp -- )
    src1 src2 cc negate-cc \ (%compare-float-unordered) (%compare-float) :> ( branch1 branch2 )
    dst temp branch1 branch2 (%boolean) ;

:: %branch ( label cc -- )
    cc order-cc {
        { cc<  [ 0 label BLT ] }
        { cc<= [ 0 label BLE ] }
        { cc>  [ 0 label BGT ] }
        { cc>= [ 0 label BGE ] }
        { cc=  [ 0 label BEQ ] }
        { cc/= [ 0 label BNE ] }
    } case ;

M:: ppc %compare-branch ( label src1 src2 cc -- )
    src1 src2 (%compare)
    label cc %branch ;

M:: ppc %compare-imm-branch ( label src1 src2 cc -- )
    src1 src2 (%compare-imm)
    label cc %branch ;

M:: ppc %compare-integer-imm-branch ( label src1 src2 cc -- )
    src1 src2 (%compare-integer-imm)
    label cc %branch ;

:: (%branch) ( label branch1 branch2 -- )
    0 label branch1 execute( cr label -- )
    branch2 [ 0 label branch2 execute( cr label -- ) ] when ; inline

M:: ppc %compare-float-ordered-branch ( label src1 src2 cc -- )
    src1 src2 cc \ (%compare-float-ordered) (%compare-float) :> ( branch1 branch2 )
    label branch1 branch2 (%branch) ;

M:: ppc %compare-float-unordered-branch ( label src1 src2 cc -- )
    src1 src2 cc \ (%compare-float-unordered) (%compare-float) :> ( branch1 branch2 )
    label branch1 branch2 (%branch) ;

M: ppc %spill
    n>> spill@ swap  {
        { int-rep    [ [ 1 ] dip %store-cell ] }
        { tagged-rep [ [ 1 ] dip %store-cell ] }
        { float-rep  [ [ 1 ] dip STFS ] }
        { double-rep [ [ 1 ] dip STFD ] }
        { vector-rep [ scratch-reg swap LI 1 scratch-reg STVX ] }
        { scalar-rep [ scratch-reg swap LI 1 scratch-reg STVX ] }
    } case ;

M: ppc %reload
    n>> spill@ swap {
        { int-rep    [ [ 1 ] dip %load-cell ] }
        { tagged-rep [ [ 1 ] dip %load-cell ] }
        { float-rep  [ [ 1 ] dip LFS ] }
        { double-rep [ [ 1 ] dip LFD ] }
        { vector-rep [ scratch-reg swap LI 1 scratch-reg LVX ] }
        { scalar-rep [ scratch-reg swap LI 1 scratch-reg LVX ] }
    } case ;

M: ppc immediate-arithmetic? -32768 32767 between? ;
M: ppc immediate-bitwise?    0 65535 between? ;
M: ppc immediate-store?      immediate-comparand? ;

M: ppc enable-cpu-features
    enable-float-intrinsics ;

USE: vocabs
{
    { [ os linux? ] [
        {
            { [ cpu ppc.32? ] [ "cpu.ppc.32.linux" require ] }
            { [ cpu ppc.64? ] [ "cpu.ppc.64.linux" require ] }
            [ ]
        } cond
      ] }
    [ ]
} cond

complex-double lookup-c-type t >>return-in-registers? drop
