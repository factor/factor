! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.arrays alien.c-types alien.data arrays assocs
byte-arrays classes.algebra classes.struct combinators compiler.cfg
compiler.cfg.builder.alien.boxing compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.alpha.64.abi cpu.alpha.64.assembler cpu.alpha.64.assembler.registers generalizations
kernel layouts literals locals math math.bitwise math.order memory namespaces
sequences system ;
IN: cpu.alpha.64
: SEQZ ( dst src -- ) ZERO CMPEQ ;
: SNEZ ( dst src -- ) over swap SEQZ dup 1 XORI ;
: FMOVE ( dst src -- ) dup CPYS ;
:: LB ( dst base offset -- ) dst base offset LDBU dst dst 56 SLLI dst dst 56 SRAI ;
:: LH ( dst base offset -- ) dst base offset LDWU dst dst 48 SLLI dst dst 48 SRAI ;
:: LWU ( dst base offset -- ) dst base offset LDL dst dst 15 ZAPNOTI ;

M: alpha.64 machine-registers
    {
        { int-regs ${ R16 R17 R18 R19 R20 R21 R22 R23 R4 R5 R6 R7 R8 } }
        { float-regs ${ F2 F3 F4 F5 F6 F7 F10 F11 F12 F13 F14 F15 F16 F17 F28 F29 F30 } }
    } ;
M: alpha.64 frame-reg FP ;
M: alpha.64 gc-root-offset n>> spill-offset 32 + 8 /i ;
: simm16? ( n -- ? ) dup 16 >signed = ;
M: alpha.64 %load-immediate LI ;
M: alpha.64 %load-reference
    [ swap load-address rel-literal ] [ \ f type-number LI ] if* ;
M:: alpha.64 %load-float ( DST value -- )
    value alien.c-types:float <ref> temp load-address rel-binary-literal DST temp 0 LDS ;
M:: alpha.64 %load-double ( DST value -- )
    value double <ref> temp load-address rel-binary-literal DST temp 0 LDT ;

:: add-offset ( DST SRC offset -- )
    offset simm16? [ DST SRC offset LDA ] [ temp offset LI DST SRC temp ADDQ ] if ;
:: memory-offset ( base offset scratch -- base' offset' )
    offset simm16? [ base offset ] [ scratch offset LI scratch base scratch ADDQ scratch 0 ] if ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> cells neg ] bi temp memory-offset ;
M: alpha.64 %peek loc>address LDQ ;
M: alpha.64 %replace loc>address STQ ;
M:: alpha.64 %replace-imm ( src loc -- )
    temp2 src [ tag-fixnum ] [ \ f type-number ] if* LI temp2 loc %replace ;
M: alpha.64 %clear [ 297 ] dip %replace-imm ;
M: alpha.64 %inc [ ds-loc? DS RS ? dup ] [ n>> cells ] bi add-offset ;
M: alpha.64 stack-frame-size (stack-frame-size) 32 + 16 align ;
M: alpha.64 %call PV load-address rel-word-pic PV JSR ;
M: alpha.64 %jump
    PIC-TAIL 0 BR PIC-TAIL PIC-TAIL 40 LDA PV load-address rel-word-pic-tail PV JMP ;
M: alpha.64 %jump-label ZERO 0 BR rc-native-0 label-fixup ;
M: alpha.64 %return RET ;
M:: alpha.64 %dispatch ( SRC TEMP -- )
    temp 0 BR temp temp 32 LDA temp temp SRC ADDQ
    temp temp temp3 literal-load temp JMP ;

M: alpha.64 %slot 2drop [ temp ] 2dip ADDQ temp 0 LDQ ;
M: alpha.64 %slot-imm slot-offset temp memory-offset LDQ ;
M: alpha.64 %set-slot 2drop [ temp ] 2dip ADDQ temp 0 STQ ;
M: alpha.64 %set-slot-imm slot-offset temp memory-offset STQ ;
M: alpha.64 %add ADDQ ;
M: alpha.64 %add-imm add-offset ;
M: alpha.64 %sub SUBQ ;
M: alpha.64 %sub-imm neg add-offset ;
M: alpha.64 %mul MULQ ;
M:: alpha.64 %mneg ( DST SRC1 SRC2 -- )
    DST SRC1 SRC2 MULQ DST DST NEG ;
M:: alpha.64 %mul-imm ( DST SRC value -- ) temp value LI DST SRC temp MULQ ;
M: alpha.64 %and AND ;
M: alpha.64 %and-imm ANDI ;
M: alpha.64 %or BIS ;
M: alpha.64 %or-imm BISI ;
M: alpha.64 %xor XOR ;
M: alpha.64 %xor-imm XORI ;
M: alpha.64 %shl SLL ;
M: alpha.64 %shl-imm SLLI ;
M: alpha.64 %shr SRL ;
M: alpha.64 %shr-imm SRLI ;
M: alpha.64 %sar SRA ;
M: alpha.64 %sar-imm SRAI ;
M: alpha.64 %not NOT ;
M: alpha.64 %neg NEG ;
! Long conditional branches keep labels independent of the 4 KiB B range.
:: compare-bit ( DST SRC1 SRC2 cc -- )
    cc order-cc {
        { cc< [ DST SRC1 SRC2 CMPLT ] }
        { cc<= [ DST SRC2 SRC1 CMPLT DST DST 1 XORI ] }
        { cc> [ DST SRC2 SRC1 CMPLT ] }
        { cc>= [ DST SRC1 SRC2 CMPLT DST DST 1 XORI ] }
        { cc= [ DST SRC1 SRC2 XOR DST DST SEQZ ] }
        { cc/= [ DST SRC1 SRC2 XOR DST DST SNEZ ] }
        { t [ DST 1 LI ] }
        { f [ DST 0 LI ] }
    } case ;
:: boolean-result ( DST BIT -- )
    DST \ f type-number LI BIT 32 BEQ
    t DST load-address rel-literal ;
:: branch-bit ( label BIT -- )
    BIT 4 BEQ label %jump-label ;
M:: alpha.64 %compare ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc compare-bit DST TEMP boolean-result ;
M:: alpha.64 %compare-integer-imm ( DST SRC value cc TEMP -- )
    temp value LI DST SRC temp cc TEMP %compare ;
M: alpha.64 %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: alpha.64 %compare-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc compare-bit label temp2 branch-bit ;
M:: alpha.64 %compare-integer-imm-branch ( label SRC value cc -- )
    temp value LI label SRC temp cc %compare-branch ;
M: alpha.64 %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;

M:: alpha.64 %fixnum-add ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 XOR temp2 SRC1 MV DST SRC1 SRC2 ADDQ
    temp2 temp2 DST XOR temp temp NOT temp temp temp2 AND
    temp2 temp ZERO CMPLT
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;
M:: alpha.64 %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 XOR temp2 SRC1 MV DST SRC1 SRC2 SUBQ
    temp2 temp2 DST XOR temp temp temp2 AND temp2 temp ZERO CMPLT
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;
M:: alpha.64 %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 UMULH temp2 SRC1 63 SRAI temp2 temp2 SRC2 AND
    temp temp temp2 SUBQ temp2 SRC2 63 SRAI temp2 temp2 SRC1 AND
    temp temp temp2 SUBQ DST SRC1 SRC2 MULQ temp2 DST 63 SRAI
    temp2 temp temp2 XOR temp2 temp2 SNEZ
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;

UNION: integer-rep int-rep tagged-rep ;
: load-rep ( DST base offset rep -- )
    {
        { int-rep [ LDQ ] } { tagged-rep [ LDQ ] }
        { float-rep [ LDS ] } { double-rep [ LDT ] }
    } case ;
: store-rep ( SRC base offset rep -- )
    {
        { int-rep [ STQ ] } { tagged-rep [ STQ ] }
        { float-rep [ STS ] } { double-rep [ STT ] }
    } case ;
:: copy-register ( DST SRC rep -- )
    rep integer-rep? [ DST SRC MV ] [
        rep float-rep? [ DST SRC FMOVE ] [ DST SRC FMOVE ] if
    ] if ;
M: alpha.64 %single>double-float CVTST ;
M: alpha.64 %double>single-float CVTTS ;

M:: alpha.64 %copy ( DST SRC rep -- )
    DST SRC eq? [ ] [
        DST spill-slot? [
            SRC spill-slot? [
                rep integer-rep? temp2 fp-temp ? :> scratch
                scratch SP SRC n>> spill-offset temp memory-offset rep load-rep
                scratch SP DST n>> spill-offset temp memory-offset rep store-rep
            ] [ SRC SP DST n>> spill-offset temp memory-offset rep store-rep ] if
        ] [
            SRC spill-slot? [ DST SP SRC n>> spill-offset temp memory-offset rep load-rep ]
            [ DST SRC rep copy-register ] if
        ] if
    ] if ;
M: alpha.64 %spill -rot %copy ;
M: alpha.64 %reload swap %copy ;

! Foreign integer accesses retain their declared width and signedness.
:: load-memory ( DST base offset rep c-type -- )
    base offset temp memory-offset :> ( BASE disp )
    c-type rep integer-rep? and [
        c-type heap-size c-type c-type-signed :> signed?
        { { 1 [ signed? [ DST BASE disp LB ] [ DST BASE disp LDBU ] if ] }
          { 2 [ signed? [ DST BASE disp LH ] [ DST BASE disp LDWU ] if ] }
          { 4 [ signed? [ DST BASE disp LDL ] [ DST BASE disp LWU ] if ] }
          { 8 [ DST BASE disp LDQ ] } } case
    ] [ DST BASE disp rep load-rep ] if ;
:: store-memory ( SRC base offset rep c-type -- )
    base offset temp memory-offset :> ( BASE disp )
    c-type rep integer-rep? and [
        c-type heap-size { { 1 [ SRC BASE disp STB ] } { 2 [ SRC BASE disp STW ] }
          { 4 [ SRC BASE disp STL ] } { 8 [ SRC BASE disp STQ ] } } case
    ] [ SRC BASE disp rep store-rep ] if ;
M: alpha.64 %load-memory-imm load-memory ;
M: alpha.64 %store-memory-imm store-memory ;
M:: alpha.64 %load-memory ( DST BASE DISP scale offset rep c-type -- )
    temp2 DISP scale SLLI temp2 BASE temp2 ADDQ DST temp2 offset rep c-type load-memory ;
M:: alpha.64 %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    temp2 DISP scale SLLI temp2 BASE temp2 ADDQ SRC temp2 offset rep c-type store-memory ;
M:: alpha.64 %convert-integer ( DST SRC c-type -- )
    64 c-type heap-size 8 * - :> count
    count zero? [ DST SRC MV ] [
        DST SRC count SLLI
        c-type c-type-signed [ DST DST count SRAI ] [ DST DST count SRLI ] if
    ] if ;
M:: alpha.64 %alien-global ( DST symbol library -- ) symbol library DST load-address rel-dlsym ;
M: alpha.64 %vm-field [ VM ] dip temp memory-offset LDQ ;
M: alpha.64 %set-vm-field [ VM ] dip temp memory-offset STQ ;
M: alpha.64 %unbox-alien alien-offset LDQ ;
M:: alpha.64 %unbox-any-c-ptr ( DST SRC -- )
    <label> :> end
    temp SRC \ f type-number XORI temp temp SEQZ
    DST ZERO MV end temp branch-bit
    temp SRC tag-mask get ANDI temp temp alien type-number XORI
    DST SRC byte-array-offset add-offset end temp branch-bit
    DST SRC alien-offset LDQ end resolve-label ;
M:: alpha.64 %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset LDQ
    temp2 DST size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset STQ
    temp class type-number tag-header LI temp DST 0 STQ
    DST DST class type-number LDA ;
:: alien-store ( SRC DST n -- ) SRC DST n cells alien type-number - STQ ;
M:: alpha.64 %box-alien ( DST SRC TEMP -- )
    <label> :> end
    DST \ f type-number LI temp SRC SEQZ end temp branch-bit
    DST 5 cells alien TEMP %allot temp \ f type-number LI
    temp DST 1 alien-store temp DST 2 alien-store
    SRC DST 3 alien-store SRC DST 4 alien-store end resolve-label ;
M:: alpha.64 %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    <label> :> end <label> :> not-f <label> :> not-alien
    DST BASE MV temp DISP SEQZ end temp branch-bit
    DST 5 cells alien TEMP %allot temp \ f type-number LI
    temp DST 2 alien-store
    temp BASE \ f type-number XORI not-f temp branch-bit
    temp \ f type-number LI temp DST 1 alien-store
    DISP DST 3 alien-store DISP DST 4 alien-store end %jump-label
    not-f resolve-label temp BASE tag-mask get ANDI temp temp alien type-number XORI
    not-alien temp branch-bit
    temp BASE 1 cells alien type-number - LDQ temp DST 1 alien-store
    temp BASE 2 cells alien type-number - LDQ temp DST 2 alien-store
    temp BASE 3 cells alien type-number - LDQ temp temp DISP ADDQ temp DST 3 alien-store
    temp BASE 4 cells alien type-number - LDQ temp temp DISP ADDQ temp DST 4 alien-store end %jump-label
    not-alien resolve-label BASE DST 1 alien-store DISP DST 3 alien-store
    temp BASE DISP ADDQ temp temp byte-array-offset add-offset temp DST 4 alien-store end resolve-label ;
:: write-barrier ( CARD TEMP -- )
    temp card-mark LI CARD CARD card-bits SRLI
    TEMP VM vm-cards-offset-offset LDQ TEMP TEMP CARD ADDQ temp TEMP 0 STB
    CARD CARD deck-bits card-bits - SRLI
    TEMP VM vm-decks-offset-offset LDQ TEMP TEMP CARD ADDQ temp TEMP 0 STB ;
M:: alpha.64 %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SRC SLOT ADDQ CARD TEMP write-barrier ;
M:: alpha.64 %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot tag slot-offset add-offset CARD TEMP write-barrier ;
M:: alpha.64 %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset LDQ TEMP1 TEMP1 size add-offset
    TEMP2 VM vm-nursery-end-offset LDQ
    temp TEMP2 TEMP1 CMPULT cc cc<= eq? [ temp temp 1 XORI ] when label temp branch-bit ;
M: alpha.64 %call-gc \ minor-gc %call gc-map-here ;
M: alpha.64 %prologue
    SP SP -32 LDA FP SP 0 STQ RA SP 8 STQ GP SP 16 STQ FP SP MV
    32 - neg SP SP rot add-offset ;
M: alpha.64 %epilogue
    32 - SP SP rot add-offset FP SP 0 LDQ RA SP 8 LDQ GP SP 16 LDQ SP SP 32 LDA ;
M: alpha.64 %safepoint SAFEPOINT SAFEPOINT 0 STQ ;

M: alpha.64 return-regs
    { { int-regs ${ RETURN } } { float-regs ${ F0 F1 } } } ;
M: alpha.64 param-regs
    drop { { int-regs ${ R16 R17 R18 R19 R20 R21 } }
           { float-regs ${ F16 F17 F18 F19 F20 F21 } } } ;
M: alpha.64 dummy-stack-params? f ;
M: alpha.64 dummy-int-params? t ;
M: alpha.64 dummy-fp-params? t ;
M: alpha.64 long-long-on-stack? f ;
M: alpha.64 long-long-odd-register? f ;
M: alpha.64 float-right-align-on-stack? f ;
M: alpha.64 struct-return-on-stack? f ;
: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
: load-reg-param ( vreg rep reg -- ) swap %copy ;
: store-reg-param ( vreg rep reg -- ) -rot %copy ;
M:: alpha.64 %unbox ( DST SRC func rep -- )
    arg1 SRC tagged-rep %copy arg2 VM MV func f f %c-invoke
    DST rep rep return-reg load-reg-param ;
M:: alpha.64 %box ( DST SRC func rep gc-map -- )
    rep reg-class-of f param-regs at first SRC rep %copy
    arg2 VM MV func f gc-map %c-invoke
    DST int-rep int-rep return-reg load-reg-param ;
M:: alpha.64 %local-allot ( DST size align offset -- ) DST SP offset local-allot-offset add-offset ;
M:: alpha.64 %save-context ( TEMP1 TEMP2 -- )
    FP CTX context-callstack-top-offset STQ DS CTX context-datastack-offset STQ RS CTX context-retainstack-offset STQ ;
M:: alpha.64 %c-invoke ( symbol dll gc-map -- )
    symbol dll PV load-address rel-dlsym TRAMPOLINE JSR gc-map gc-map-here ;
:: stack-call-gc-map ( gc-map size -- gc-map' )
    ! Trampoline2 links its frame above the outgoing arguments, size bytes
    ! above the frame used by trampoline1. Keep spill addresses unchanged.
    gc-map dup gc-map-needed? [
        [ clone [ size - ] change-n ] :> shift-slot
        clone
        [ shift-slot map ] change-gc-roots
        [ [ shift-slot bi@ ] assoc-map ] change-derived-roots
    ] when ;
:: c-invoke-stack ( size symbol dll gc-map -- )
    symbol dll PV load-address rel-dlsym temp2 load-address rel-trampoline2
    temp3 SP size 32 - add-offset temp2 JSR gc-map size stack-call-gc-map gc-map-here ;
M: alpha.64 %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ] [ -roll '[ _ _ _ _ c-invoke-stack ] ]
    if-zero %alien-assembly ;
: ?spill-slot ( obj -- reg )
    dup spill-slot? [ n>> spill-offset SP swap temp memory-offset temp2 -rot LDQ temp2 ] when ;
:: c-indirect-stack ( size src gc-map -- )
    PV src ?spill-slot MV temp2 load-address rel-trampoline2
    temp3 SP size 32 - add-offset temp2 JSR gc-map size stack-call-gc-map gc-map-here ;
M: alpha.64 %alien-indirect
    [ 8 nrot ] dip pick [ '[
        PV _ ?spill-slot MV TRAMPOLINE JSR _ gc-map-here
    ] ] [ -rot '[ _ _ _ c-indirect-stack ] ] if-zero %alien-assembly ;
:: store-stack-param ( vreg rep offset size -- )
    rep integer-rep? temp2 fp-temp ? :> scratch
    scratch vreg rep %copy
    scratch SP offset rep f store-memory ;
M: alpha.64 %alien-assembly
    3nip swap {
        [ [ first3 store-reg-param ] each ]
        [ [ first4 store-stack-param ] each ]
        [ call( -- ) ]
        [ [ first3 load-reg-param ] each ]
    } spread drop ;
:: load-stack-param ( vreg rep offset size -- )
    temp2 CTX context-callstack-save-offset LDQ
    vreg spill-slot? [
        rep integer-rep? PV fp-temp ? :> scratch
        scratch temp2 offset 272 + rep f load-memory
        vreg scratch rep %copy
    ] [ vreg temp2 offset 272 + rep f load-memory ] if ;
:: load-callback-param ( vreg rep reg -- )
    temp2 CTX context-callstack-save-offset LDQ
    reg n>> 16 - 8 * rep integer-rep? 144 192 ? + :> offset
    rep integer-rep? rep double-rep ? :> saved-rep
    vreg spill-slot? [
        rep integer-rep? PV fp-temp ? :> scratch
        scratch temp2 offset saved-rep f load-memory vreg scratch rep %copy
    ] [ vreg temp2 offset saved-rep f load-memory ] if ;
M: alpha.64 %callback-inputs
    [ [ first3 load-callback-param ] each ] [ [ first4 load-stack-param ] each ] bi*
    arg1 VM MV arg2 ZERO MV "begin_callback" f f %c-invoke ;
M: alpha.64 %callback-stack
    dup CTX context-callstack-save-offset LDQ dup 272 LDA ;
M: alpha.64 %callback-outputs
    arg1 VM MV "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;
M: alpha.64 enable-cpu-features enable-alien-4-intrinsics ;
M: alpha.64 complex-addressing? f ;
M: alpha.64 integer-float-needs-stack-frame? f ;
M: alpha.64 fused-unboxing? t ;
M: alpha.64 immediate-arithmetic? simm16? ;
M: alpha.64 immediate-bitwise? dup 0 >= swap 255 <= and ;
M: alpha.64 immediate-comparand?
    dup fixnum? [ simm16? ] [ not ] if ;
M: alpha.64 immediate-store? drop f ;
