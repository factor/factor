! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
! Scalar System z optimizer foundation. Baseline ISA: z196.
USING: accessors alien alien.c-types arrays assocs byte-arrays combinators
compiler.cfg compiler.cfg.intrinsics compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stack-frame
compiler.cfg.comparisons compiler.codegen.labels compiler.codegen.relocation
compiler.codegen.gc-maps compiler.constants cpu.architecture cpu.s390x.abi cpu.s390x.assembler
cpu.s390x.assembler.registers generalizations kernel layouts literals locals math
math.bitwise math.order memory namespaces sequences sequences.generalizations system ;
IN: cpu.s390x

ALIAS: DS R6
ALIAS: RS R7
ALIAS: CTX R8
ALIAS: VM R9
ALIAS: TRAMPOLINE2 R10
ALIAS: TRAMPOLINE R11
ALIAS: FP R12
ALIAS: SAFEPOINT R13
ALIAS: RA R14
ALIAS: SP R15
ALIAS: temp R0
ALIAS: temp2 R1
ALIAS: fp-temp F1

M: s390x machine-registers
    { { int-regs ${ R2 R3 R4 R5 } }
      { float-regs ${ F0 F2 F3 F4 F5 F6 F7 } } } ;
M: s390x frame-reg FP ;
M: s390x gc-root-offset n>> spill-offset 16 + 8 /i ;
: simm16? ( n -- ? ) dup 16 >signed = ;
: simm20? ( n -- ? ) dup 20 >signed = ;
M: s390x %load-immediate LI ;
:: add-offset ( DST SRC offset -- )
    offset simm20? [
        SRC R0 eq? [ temp2 SRC LGR DST R0 temp2 offset LAY ]
        [ DST R0 SRC offset LAY ] if
    ] [
        SRC temp2 eq? [ temp offset LI DST SRC temp AGRK ]
        [ temp2 offset LI DST SRC temp2 AGRK ] if
    ] if ;
:: memory-offset ( base offset -- base' offset' )
    offset simm20? [
        base R0 eq? [ temp2 base LGR temp2 offset ] [ base offset ] if
    ] [
        base temp2 eq? [ temp offset LI temp2 base temp AGRK ]
        [ temp2 offset LI temp2 base temp2 AGRK ] if temp2 0
    ] if ;
:: load-cell ( DST BASE offset -- )
    BASE offset memory-offset :> ( base disp ) DST R0 base disp LG ;
:: store-cell ( SRC BASE offset -- )
    BASE offset memory-offset :> ( base disp ) SRC R0 base disp STG ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> cells neg ] bi ;
M: s390x %peek loc>address load-cell ;
M: s390x %replace loc>address store-cell ;
M: s390x %replace-imm [ temp swap [ tag-fixnum ] [ \ f type-number ] if* LI temp ] dip %replace ;
M: s390x %clear [ 297 ] dip %replace-imm ;
M: s390x %inc [ ds-loc? DS RS ? dup ] [ n>> cells ] bi add-offset ;
M: s390x stack-frame-size (stack-frame-size) 16 + 16 align ;
M: s390x %return RET ;
M: s390x %slot 2drop temp2 -rot AGRK temp2 0 load-cell ;
M: s390x %slot-imm slot-offset load-cell ;
M: s390x %set-slot 2drop temp2 -rot AGRK temp2 0 store-cell ;
M: s390x %set-slot-imm slot-offset store-cell ;
M: s390x %add AGRK ;
M: s390x %add-imm add-offset ;
M: s390x %sub SGRK ;
M: s390x %sub-imm neg add-offset ;
M:: s390x %mul ( DST SRC1 SRC2 -- )
    temp SRC2 LGR DST SRC1 LGR DST temp MSGR ;
M:: s390x %mul-imm ( DST SRC value -- )
    temp value LI DST SRC LGR DST temp MSGR ;
M:: s390x %mneg ( DST SRC1 SRC2 -- )
    DST SRC1 SRC2 %mul DST DST LCGR ;
M: s390x %and NGRK ;
M: s390x %or OGRK ;
M: s390x %xor XGRK ;
M:: s390x %and-imm ( DST SRC value -- ) temp value LI DST SRC temp NGRK ;
M:: s390x %or-imm ( DST SRC value -- ) temp value LI DST SRC temp OGRK ;
M:: s390x %xor-imm ( DST SRC value -- ) temp value LI DST SRC temp XGRK ;
M: s390x %shl 0 SLLG ;
M: s390x %shr 0 SRLG ;
M: s390x %sar 0 SRAG ;
M: s390x %shl-imm [ R0 ] dip SLLG ;
M: s390x %shr-imm [ R0 ] dip SRLG ;
M: s390x %sar-imm [ R0 ] dip SRAG ;
M: s390x %not -1 %xor-imm ;
M: s390x %neg LCGR ;
M: s390x %vm-field [ VM ] dip load-cell ;
M: s390x %set-vm-field [ VM ] dip store-cell ;
M: s390x %unbox-alien alien-offset load-cell ;
M:: s390x %save-context ( TEMP1 TEMP2 -- )
    FP CTX context-callstack-top-offset store-cell
    DS CTX context-datastack-offset store-cell
    RS CTX context-retainstack-offset store-cell ;
M: s390x %prologue
    SP SP -16 add-offset FP SP 0 store-cell RA SP 8 store-cell FP SP LGR
    16 - neg SP SP rot add-offset ;
M: s390x %epilogue
    16 - SP SP rot add-offset FP SP 0 load-cell RA SP 8 load-cell
    SP SP 16 add-offset ;
M: s390x %safepoint SAFEPOINT SAFEPOINT 0 store-cell ;

:: float-op ( DST SRC1 SRC2 op -- )
    fp-temp SRC2 LDR DST SRC1 LDR DST fp-temp op call( dst src -- ) ; inline
M: s390x %add-float [ ADBR ] float-op ;
M: s390x %sub-float [ SDBR ] float-op ;
M: s390x %mul-float [ MDBR ] float-op ;
M: s390x %div-float [ DDBR ] float-op ;
M: s390x %sqrt SQDBR ;
M: s390x %single>double-float LDEBR ;
M: s390x %double>single-float LEDBR ;
M: s390x integer-float-needs-stack-frame? f ;
M: s390x complex-addressing? f ;
M: s390x fused-unboxing? t ;
M: s390x immediate-arithmetic? simm16? ;
! Bitwise masks are materialized by LI before the register operation.
M: s390x immediate-bitwise? drop t ;
M: s390x immediate-comparand? dup fixnum? [ simm16? ] [ not ] if ;
M: s390x immediate-store? drop f ;

UNION: integer-rep int-rep tagged-rep ;
:: load-rep ( DST base offset rep -- )
    base offset memory-offset :> ( BASE disp )
    rep {
        { int-rep [ DST R0 BASE disp LG ] }
        { tagged-rep [ DST R0 BASE disp LG ] }
        { float-rep [ DST R0 BASE disp LEY ] }
        { double-rep [ DST R0 BASE disp LDY ] }
    } case ;
:: store-rep ( SRC base offset rep -- )
    base offset memory-offset :> ( BASE disp )
    rep {
        { int-rep [ SRC R0 BASE disp STG ] }
        { tagged-rep [ SRC R0 BASE disp STG ] }
        { float-rep [ SRC R0 BASE disp STEY ] }
        { double-rep [ SRC R0 BASE disp STDY ] }
    } case ;
:: copy-register ( DST SRC rep -- )
    rep integer-rep? [ DST SRC LGR ] [ DST SRC LDR ] if ;
M:: s390x %copy ( DST SRC rep -- )
    DST SRC eq? [ ] [
        DST spill-slot? [
            SRC spill-slot? [
                rep integer-rep? temp fp-temp ? :> scratch
                scratch SP SRC n>> spill-offset rep load-rep
                scratch SP DST n>> spill-offset rep store-rep
            ] [ SRC SP DST n>> spill-offset rep store-rep ] if
        ] [
            SRC spill-slot? [ DST SP SRC n>> spill-offset rep load-rep ]
            [ DST SRC rep copy-register ] if
        ] if
    ] if ;
: s390x-copy ( DST SRC rep -- ) M\ s390x %copy execute ;
M: s390x %spill -rot s390x-copy ;
M: s390x %reload swap s390x-copy ;
:: load-memory ( DST base offset rep c-type -- )
    base offset memory-offset :> ( BASE disp )
    c-type rep integer-rep? and [
        c-type heap-size c-type c-type-signed :> signed?
        { { 1 [ signed? [ DST R0 BASE disp LGB ] [ DST R0 BASE disp LLGC ] if ] }
          { 2 [ signed? [ DST R0 BASE disp LGH ] [ DST R0 BASE disp LLGH ] if ] }
          { 4 [ signed? [ DST R0 BASE disp LGF ] [ DST R0 BASE disp LLGF ] if ] }
          { 8 [ DST R0 BASE disp LG ] } } case
    ] [ DST BASE disp rep load-rep ] if ;
:: store-memory ( SRC base offset rep c-type -- )
    base offset memory-offset :> ( BASE disp )
    c-type rep integer-rep? and [
        c-type heap-size {
            { 1 [ SRC R0 BASE disp STCY ] }
            { 2 [ SRC R0 BASE disp STHY ] }
            { 4 [ SRC R0 BASE disp STY ] }
            { 8 [ SRC R0 BASE disp STG ] }
        } case
    ] [ SRC BASE disp rep store-rep ] if ;
M: s390x %load-memory-imm load-memory ;
M: s390x %store-memory-imm store-memory ;
M:: s390x %load-memory ( DST BASE DISP scale offset rep c-type -- )
    temp2 DISP R0 scale SLLG temp2 BASE temp2 AGRK DST temp2 offset rep c-type load-memory ;
M:: s390x %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    temp2 DISP R0 scale SLLG temp2 BASE temp2 AGRK SRC temp2 offset rep c-type store-memory ;
M:: s390x %convert-integer ( DST SRC c-type -- )
    64 c-type heap-size 8 * - :> count
    count zero? [ DST SRC LGR ] [
        DST SRC R0 count SLLG
        c-type c-type-signed [ DST DST R0 count SRAG ] [ DST DST R0 count SRLG ] if
    ] if ;

M: s390x %load-reference
    [ swap load-address rel-literal ] [ \ f type-number LI ] if* ;
M: s390x %call call-relative rel-word-pic ;
M: s390x %jump R5 12 LARL jump-relative rel-word-pic-tail ;
M: s390x %jump-label jump-relative label-fixup ;
:: cc-mask ( cc -- mask )
    cc order-cc {
        { cc< [ 4 ] } { cc<= [ 12 ] } { cc> [ 2 ] }
        { cc>= [ 10 ] } { cc= [ 8 ] } { cc/= [ 7 ] }
        { t [ 15 ] } { f [ 0 ] }
    } case ;
:: branch-cc ( label cc -- )
    cc cc-mask 0 BRCL label 14 label-fixup ;
M:: s390x %compare-branch ( label SRC1 SRC2 cc -- )
    SRC1 SRC2 CGR label cc branch-cc ;
M:: s390x %compare-integer-imm-branch ( label SRC value cc -- )
    value simm16? [ SRC value CGHI ] [ temp value LI SRC temp CGR ] if
    label cc branch-cc ;
M:: s390x %compare-imm-branch ( label SRC value cc -- )
    label SRC value [ tag-fixnum ] [ \ f type-number ] if* cc
    M\ s390x %compare-integer-imm-branch execute ;
:: boolean-result ( DST cc -- )
    DST \ f type-number LI cc cc-mask 12 BRCL 15 18 BRCL
    t DST load-address rel-literal ;
M:: s390x %compare ( DST SRC1 SRC2 cc TEMP -- )
    SRC1 SRC2 CGR DST cc boolean-result ;
M:: s390x %compare-integer-imm ( DST SRC value cc TEMP -- )
    value simm16? [ SRC value CGHI ] [ temp value LI SRC temp CGR ] if
    DST cc boolean-result ;
M:: s390x %compare-imm ( DST SRC value cc TEMP -- )
    DST SRC value [ tag-fixnum ] [ \ f type-number ] if* cc TEMP
    M\ s390x %compare-integer-imm execute ;
M:: s390x %min ( DST SRC1 SRC2 -- )
    temp SRC2 LGR DST SRC1 LGR DST temp CGR 12 10 BRCL DST temp LGR ;
M:: s390x %max ( DST SRC1 SRC2 -- )
    temp SRC2 LGR DST SRC1 LGR DST temp CGR 10 10 BRCL DST temp LGR ;

M: s390x %integer>float CDGBR ;
M: s390x %float>integer 5 CGDBR ;
M:: s390x %integer>scalar ( DST SRC rep -- )
    rep float-rep? [ temp SRC R0 32 SLLG DST temp LDGR ] [ DST SRC LDGR ] if ;
M:: s390x %scalar>integer ( DST SRC rep -- )
    DST SRC LGDR rep float-rep? [ DST DST R0 32 SRLG ] when ;
:: float-cc-mask ( cc -- mask )
    cc { { cc< [ 4 ] } { cc<= [ 12 ] } { cc> [ 2 ] } { cc>= [ 10 ] }
      { cc= [ 8 ] } { cc<> [ 6 ] } { cc<>= [ 14 ] }
      { cc/< [ 11 ] } { cc/<= [ 3 ] } { cc/> [ 13 ] } { cc/>= [ 5 ] }
      { cc/= [ 7 ] } { cc/<> [ 9 ] } { cc/<>= [ 1 ] } } case ;
:: branch-mask ( label mask -- ) mask 0 BRCL label 14 label-fixup ;
M:: s390x %compare-float-ordered-branch ( label SRC1 SRC2 cc -- )
    SRC1 SRC2 KDBR label cc float-cc-mask branch-mask ;
M:: s390x %compare-float-unordered-branch ( label SRC1 SRC2 cc -- )
    SRC1 SRC2 CDBR label cc float-cc-mask branch-mask ;
:: boolean-mask-result ( DST mask -- )
    DST \ f type-number LI mask 12 BRCL 15 18 BRCL t DST load-address rel-literal ;
M:: s390x %compare-float-ordered ( DST SRC1 SRC2 cc TEMP -- )
    SRC1 SRC2 KDBR DST cc float-cc-mask boolean-mask-result ;
M:: s390x %compare-float-unordered ( DST SRC1 SRC2 cc TEMP -- )
    SRC1 SRC2 CDBR DST cc float-cc-mask boolean-mask-result ;

M:: s390x %dispatch ( SRC TEMP -- )
    temp2 18 LARL temp2 temp2 SRC AGRK temp2 temp2 0 load-cell 15 temp2 BCR ;
M:: s390x %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset load-cell
    temp2 DST size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset store-cell
    temp class type-number tag-header LI temp DST 0 store-cell
    DST DST class type-number add-offset ;
:: write-barrier ( CARD TEMP -- )
    temp card-mark LI CARD CARD R0 card-bits SRLG
    TEMP VM vm-cards-offset-offset load-cell
    temp2 TEMP CARD AGRK temp R0 temp2 0 STCY
    CARD CARD R0 deck-bits card-bits - SRLG
    TEMP VM vm-decks-offset-offset load-cell
    temp2 TEMP CARD AGRK temp R0 temp2 0 STCY ;
M:: s390x %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SRC SLOT AGRK CARD TEMP write-barrier ;
M:: s390x %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot tag slot-offset add-offset CARD TEMP write-barrier ;
M:: s390x %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset load-cell TEMP1 TEMP1 size add-offset
    TEMP2 VM vm-nursery-end-offset load-cell
    TEMP1 TEMP2 CLGR label cc branch-cc ;
M: s390x %call-gc \ minor-gc %call gc-map-here ;

! System z SysV scalar arguments; floating stack arguments occupy the
! rightmost four bytes of an eight-byte parameter slot.
M: s390x return-regs { { int-regs ${ R2 } } { float-regs ${ F0 } } } ;
M: s390x param-regs
    drop { { int-regs ${ R2 R3 R4 R5 R6 } }
           { float-regs ${ F0 F2 F4 F6 } } } ;
M: s390x dummy-stack-params? f ;
M: s390x dummy-int-params? f ;
M: s390x dummy-fp-params? f ;
M: s390x long-long-on-stack? f ;
M: s390x long-long-odd-register? f ;
M: s390x float-right-align-on-stack? t ;
M: s390x struct-return-on-stack? f ;
: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
: load-reg-param ( vreg rep reg -- ) swap s390x-copy ;
: store-reg-param ( vreg rep reg -- ) -rot s390x-copy ;
M:: s390x %alien-global ( DST symbol library -- )
    symbol library DST load-address rel-dlsym ;
! R6/R7 hold the live Factor stacks and are callee-saved by native code.
! The context can contain an older snapshot after an intervening Factor call.
M:: s390x %c-invoke ( symbol dll gc-map -- )
    symbol dll temp2 load-address rel-dlsym RA TRAMPOLINE BASR
    gc-map gc-map-here ;
M:: s390x %unbox ( DST SRC func rep -- )
    R2 SRC tagged-rep s390x-copy R3 VM LGR func f f %c-invoke
    DST rep rep return-reg load-reg-param ;
M:: s390x %box ( DST SRC func rep gc-map -- )
    rep reg-class-of f param-regs at first SRC rep s390x-copy
    rep int-rep? R3 R2 ? VM LGR func f gc-map %c-invoke
    DST int-rep int-rep return-reg load-reg-param ;
M:: s390x %local-allot ( DST size align offset -- )
    DST SP offset local-allot-offset add-offset ;

! Materialize IEEE bits directly so cross compilation does not depend on
! the host byte order of a binary literal buffer.
M:: s390x %load-double ( DST value -- )
    temp value double>bits LI DST temp LDGR ;
M:: s390x %load-float ( DST value -- )
    temp value float>bits 32 shift LI DST temp LDGR ;

:: stack-call-gc-map ( gc-map size -- gc-map' )
    gc-map dup gc-map-needed? [
        [ clone [ size - ] change-n ] :> shift-slot
        clone [ shift-slot map ] change-gc-roots
        [ [ shift-slot bi@ ] assoc-map ] change-derived-roots
    ] when ;
:: c-invoke-stack ( size symbol dll gc-map -- )
    temp SP size 16 - add-offset
    symbol dll temp2 load-address rel-dlsym RA TRAMPOLINE2 BASR
    gc-map size stack-call-gc-map gc-map-here ;
M: s390x %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ] [ -roll '[ _ _ _ _ c-invoke-stack ] ]
    if-zero %alien-assembly ;
: ?spill-slot ( obj -- reg )
    dup spill-slot? [ n>> spill-offset temp2 SP rot load-cell temp2 ] when ;
:: c-indirect-stack ( size src gc-map -- )
    temp SP size 16 - add-offset temp2 src ?spill-slot LGR
    RA TRAMPOLINE2 BASR
    gc-map size stack-call-gc-map gc-map-here ;
M: s390x %alien-indirect
    [ 8 nrot ] dip pick [ '[
        temp2 _ ?spill-slot LGR RA TRAMPOLINE BASR _ gc-map-here
    ] ] [ -rot '[ _ _ _ c-indirect-stack ] ] if-zero %alien-assembly ;
:: store-stack-param ( vreg rep offset size -- )
    rep integer-rep? temp fp-temp ? :> scratch
    scratch vreg rep s390x-copy scratch SP offset 160 + rep f store-memory ;
M:: s390x %alien-assembly ( varargs? reg-inputs stack-inputs reg-outputs
                              dead-outputs cleanup stack-size quot -- )
    ! The fifth integer argument occupies R6, which is also Factor's DS.
    ! Other calls retain the live hardware stacks instead of an older snapshot.
    reg-inputs [ third DS eq? ] any? :> clobbers-ds?
    reg-inputs [ first3 store-reg-param ] each
    stack-inputs [ first4 store-stack-param ] each
    quot call( -- )
    clobbers-ds? [ DS CTX context-datastack-offset load-cell ] when
    reg-outputs [ first3 load-reg-param ] each ;
:: load-stack-param ( vreg rep offset size -- )
    temp2 CTX context-callstack-save-offset load-cell
    vreg spill-slot? [
        rep integer-rep? temp fp-temp ? :> scratch
        scratch temp2 offset 480 + rep f load-memory vreg scratch rep s390x-copy
    ] [ vreg temp2 offset 480 + rep f load-memory ] if ;
:: load-callback-reg ( vreg rep reg -- )
    reg R6 eq? [
        temp2 CTX context-callstack-save-offset load-cell
        temp temp2 160 load-cell vreg temp rep s390x-copy
    ] [ vreg rep reg load-reg-param ] if ;
M: s390x %callback-inputs
    [ [ first3 load-callback-reg ] each ] [ [ first4 load-stack-param ] each ] bi*
    R2 VM LGR R3 0 LI "begin_callback" f f %c-invoke ;
M: s390x %callback-stack
    dup CTX context-callstack-save-offset load-cell dup 320 add-offset ;
M: s390x %callback-outputs
    R2 VM LGR "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;

M: s390x enable-cpu-features
    enable-float-intrinsics enable-fsqrt enable-min/max
    enable-log2 enable-bit-count ;

M:: s390x %unbox-any-c-ptr ( DST SRC -- )
    <label> :> null <label> :> indirect <label> :> end
    SRC \ f type-number CGHI null cc= branch-cc
    temp tag-mask get LI temp SRC temp NGRK
    temp alien type-number CGHI indirect cc= branch-cc
    DST SRC byte-array-offset add-offset end M\ s390x %jump-label execute
    indirect resolve-label DST SRC alien-offset load-cell end M\ s390x %jump-label execute
    null resolve-label DST 0 LI end resolve-label ;
M:: s390x %box-alien ( DST SRC TEMP -- )
    <label> :> end TEMP SRC LGR DST \ f type-number LI
    TEMP 0 CGHI end cc= branch-cc
    DST 5 cells alien TEMP M\ s390x %allot execute
    temp \ f type-number LI
    temp DST 1 cells alien type-number - store-cell
    temp DST 2 cells alien type-number - store-cell
    TEMP DST 3 cells alien type-number - store-cell
    TEMP DST 4 cells alien type-number - store-cell end resolve-label ;

:: overflow-branch ( label cc -- )
    label cc cc/o eq? 14 1 ? branch-mask ;
M:: s390x %fixnum-add ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 AGRK label cc overflow-branch ;
M:: s390x %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 SGRK label cc overflow-branch ;
M:: s390x %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    temp2 SRC1 LGR temp SRC2 MLGR
    SRC1 0 CGHI 10 10 BRCL temp SRC2 SGR
    SRC2 0 CGHI 10 10 BRCL temp SRC1 SGR
    DST temp2 R0 63 SRAG temp DST CGR DST temp2 LGR
    label cc cc/o eq? 8 7 ? branch-mask ;
M:: s390x %test-branch ( label SRC1 SRC2 cc -- )
    temp SRC1 SRC2 NGRK label cc branch-cc ;
M:: s390x %test-imm-branch ( label SRC value cc -- )
    temp2 value LI temp SRC temp2 NGRK label cc branch-cc ;
M:: s390x %test ( DST SRC1 SRC2 cc TEMP -- )
    temp SRC1 SRC2 NGRK DST cc boolean-result ;
M:: s390x %test-imm ( DST SRC value cc TEMP -- )
    temp2 value LI temp SRC temp2 NGRK DST cc boolean-result ;

M:: s390x %log2 ( DST SRC -- )
    temp SRC FLOGR DST 63 LI DST temp SGR ;
M:: s390x %bit-count ( DST SRC -- )
    temp SRC POPCNT
    temp2 temp R0 32 SRLG temp temp2 AGR
    temp2 temp R0 16 SRLG temp temp2 AGR
    temp2 temp R0 8 SRLG temp temp2 AGR
    temp2 255 LI DST temp temp2 NGRK ;

M:: s390x %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    <label> :> end <label> :> not-f <label> :> not-alien
    DST BASE eq? [ TEMP BASE LGR ] when
    DST DISP eq? [ TEMP DISP LGR ] when
    DST BASE eq? TEMP BASE ? :> base
    DST DISP eq? TEMP DISP ? :> displacement
    displacement 0 CGHI DST base LGR end cc= branch-cc
    DST 5 cells alien TEMP M\ s390x %allot execute
    temp \ f type-number LI temp DST 2 cells alien type-number - store-cell
    base \ f type-number CGHI not-f cc/= branch-cc
    temp DST 1 cells alien type-number - store-cell
    displacement DST 3 cells alien type-number - store-cell
    displacement DST 4 cells alien type-number - store-cell
    end M\ s390x %jump-label execute
    not-f resolve-label
    temp tag-mask get LI temp base temp NGRK
    temp alien type-number CGHI not-alien cc/= branch-cc
    temp base 1 cells alien type-number - load-cell
    temp DST 1 cells alien type-number - store-cell
    temp base 2 cells alien type-number - load-cell
    temp DST 2 cells alien type-number - store-cell
    temp base 3 cells alien type-number - load-cell temp displacement AGR
    temp DST 3 cells alien type-number - store-cell
    temp base 4 cells alien type-number - load-cell temp displacement AGR
    temp DST 4 cells alien type-number - store-cell
    end M\ s390x %jump-label execute
    not-alien resolve-label
    base DST 1 cells alien type-number - store-cell
    displacement DST 3 cells alien type-number - store-cell
    temp base displacement AGRK temp temp byte-array-offset add-offset
    temp DST 4 cells alien type-number - store-cell end resolve-label ;
