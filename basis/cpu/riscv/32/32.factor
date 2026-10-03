! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.arrays alien.c-types alien.data arrays assocs
byte-arrays classes.algebra classes.struct combinators compiler.cfg
compiler.cfg.builder.alien.boxing compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.riscv.32.abi cpu.riscv.32.assembler cpu.riscv.32.assembler.registers generalizations
kernel layouts literals locals math math.bitwise math.order memory namespaces
sequences system ;
IN: cpu.riscv.32

M: riscv.32 machine-registers
    {
        { int-regs ${ A0 A1 A2 A3 A4 A5 A6 A7 T4 T5 T6 } }
        { float-regs ${ F2 F3 F4 F5 F6 F7 F10 F11 F12 F13 F14 F15 F16 F17 F28 F29 F30 F31 } }
    } ;
M: riscv.32 frame-reg FP ;
M: riscv.32 gc-root-offset n>> spill-offset 16 + 4 /i ;
: simm12? ( n -- ? ) dup 12 >signed = ;
M: riscv.32 %load-immediate LI ;
M: riscv.32 %load-reference
    [ swap load-address rel-literal ] [ \ f type-number LI ] if* ;
M:: riscv.32 %load-float ( DST value -- )
    temp 0 AUIPC DST temp 0 FLW value alien.c-types:float <ref> rc-relative-riscv rel-binary-literal ;
M:: riscv.32 %load-double ( DST value -- )
    temp 0 AUIPC DST temp 0 FLD value double <ref> rc-relative-riscv rel-binary-literal ;

:: add-offset ( DST SRC offset -- )
    offset simm12? [ DST SRC offset ADDI ] [ temp offset LI DST SRC temp ADD ] if ;
:: memory-offset ( base offset scratch -- base' offset' )
    offset simm12? [ base offset ] [ scratch offset LI scratch base scratch ADD scratch 0 ] if ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> cells neg ] bi temp memory-offset ;
M: riscv.32 %peek loc>address LW ;
M: riscv.32 %replace loc>address SW ;
M:: riscv.32 %replace-imm ( src loc -- )
    temp2 src [ tag-fixnum ] [ \ f type-number ] if* LI temp2 loc %replace ;
M: riscv.32 %clear [ 297 ] dip %replace-imm ;
M: riscv.32 %inc [ ds-loc? DS RS ? dup ] [ n>> cells ] bi add-offset ;
M: riscv.32 stack-frame-size (stack-frame-size) 16 + 16 align ;
M: riscv.32 %call call-relative rel-word-pic ;
M: riscv.32 %jump
    PIC-TAIL 0 AUIPC PIC-TAIL PIC-TAIL 16 ADDI jump-relative rel-word-pic-tail ;
M: riscv.32 %jump-label jump-relative label-fixup ;
M: riscv.32 %return RET ;
M:: riscv.32 %dispatch ( SRC TEMP -- )
    temp 0 AUIPC temp temp 20 ADDI temp temp SRC ADD
    temp temp 0 LW temp JR ;

M: riscv.32 %slot 2drop [ temp ] 2dip ADD temp 0 LW ;
M: riscv.32 %slot-imm slot-offset temp memory-offset LW ;
M: riscv.32 %set-slot 2drop [ temp ] 2dip ADD temp 0 SW ;
M: riscv.32 %set-slot-imm slot-offset temp memory-offset SW ;
M: riscv.32 %add ADD ;
M: riscv.32 %add-imm add-offset ;
M: riscv.32 %sub SUB ;
M: riscv.32 %sub-imm neg add-offset ;
M: riscv.32 %mul MUL ;
M:: riscv.32 %mneg ( DST SRC1 SRC2 -- )
    DST SRC1 SRC2 MUL DST DST NEG ;
M:: riscv.32 %mul-imm ( DST SRC value -- ) temp value LI DST SRC temp MUL ;
M: riscv.32 %and AND ;
M: riscv.32 %and-imm ANDI ;
M: riscv.32 %or OR ;
M: riscv.32 %or-imm ORI ;
M: riscv.32 %xor XOR ;
M: riscv.32 %xor-imm XORI ;
M: riscv.32 %shl SLL ;
M: riscv.32 %shl-imm SLLI ;
M: riscv.32 %shr SRL ;
M: riscv.32 %shr-imm SRLI ;
M: riscv.32 %sar SRA ;
M: riscv.32 %sar-imm SRAI ;
M: riscv.32 %not NOT ;
M: riscv.32 %neg NEG ;
M:: riscv.32 %min ( DST SRC1 SRC2 -- )
    SRC1 SRC2 12 BLT DST SRC2 MV 8 J DST SRC1 MV ;
M:: riscv.32 %max ( DST SRC1 SRC2 -- )
    SRC2 SRC1 12 BLT DST SRC2 MV 8 J DST SRC1 MV ;

! Long conditional branches keep labels independent of the 4 KiB B range.
:: compare-bit ( DST SRC1 SRC2 cc -- )
    cc order-cc {
        { cc< [ DST SRC1 SRC2 SLT ] }
        { cc<= [ DST SRC2 SRC1 SLT DST DST 1 XORI ] }
        { cc> [ DST SRC2 SRC1 SLT ] }
        { cc>= [ DST SRC1 SRC2 SLT DST DST 1 XORI ] }
        { cc= [ DST SRC1 SRC2 XOR DST DST SEQZ ] }
        { cc/= [ DST SRC1 SRC2 XOR DST DST SNEZ ] }
        { t [ DST 1 LI ] }
        { f [ DST 0 LI ] }
    } case ;
:: boolean-result ( DST BIT -- )
    DST \ f type-number LI BIT ZERO 12 BEQ
    t DST load-address rel-literal ;
:: branch-bit ( label BIT -- )
    BIT ZERO 12 BEQ label %jump-label ;
M:: riscv.32 %compare ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc compare-bit DST TEMP boolean-result ;
M:: riscv.32 %compare-integer-imm ( DST SRC value cc TEMP -- )
    temp value LI DST SRC temp cc TEMP %compare ;
M: riscv.32 %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: riscv.32 %compare-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc compare-bit label temp2 branch-bit ;
M:: riscv.32 %compare-integer-imm-branch ( label SRC value cc -- )
    temp value LI label SRC temp cc %compare-branch ;
M: riscv.32 %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;

M:: riscv.32 %fixnum-add ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 XOR temp2 SRC1 MV DST SRC1 SRC2 ADD
    temp2 temp2 DST XOR temp temp NOT temp temp temp2 AND
    temp2 temp ZERO SLT
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;
M:: riscv.32 %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 XOR temp2 SRC1 MV DST SRC1 SRC2 SUB
    temp2 temp2 DST XOR temp temp temp2 AND temp2 temp ZERO SLT
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;
M:: riscv.32 %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 MULH DST SRC1 SRC2 MUL temp2 DST 31 SRAI
    temp2 temp temp2 XOR temp2 temp2 SNEZ
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;

M: riscv.32 %add-float FADD.D ;
M: riscv.32 %sub-float FSUB.D ;
M: riscv.32 %mul-float FMUL.D ;
M: riscv.32 %div-float FDIV.D ;
M: riscv.32 %min-float FMIN.D ;
M: riscv.32 %max-float FMAX.D ;
M: riscv.32 %sqrt FSQRT.D ;
M: riscv.32 %single>double-float FCVT.D.S ;
M: riscv.32 %double>single-float FCVT.S.D ;
M: riscv.32 %integer>float 7 FCVT.D.W ;
M: riscv.32 %float>integer 1 FCVT.W.D ;
M: riscv.32 %integer>scalar
    drop FMV.W.X ;
M: riscv.32 %scalar>integer
    drop FMV.X.W ;

:: float-bit ( DST SRC1 SRC2 cc -- )
    cc {
        { cc< [ DST SRC1 SRC2 FLT.D ] }
        { cc<= [ DST SRC1 SRC2 FLE.D ] }
        { cc> [ DST SRC2 SRC1 FLT.D ] }
        { cc>= [ DST SRC2 SRC1 FLE.D ] }
        { cc= [ DST SRC1 SRC2 FEQ.D ] }
        { cc<> [ temp SRC1 SRC1 FEQ.D temp2 SRC2 SRC2 FEQ.D
            DST SRC1 SRC2 FEQ.D DST DST 1 XORI temp temp temp2 AND DST DST temp AND ] }
        { cc<>= [ temp SRC1 SRC1 FEQ.D temp2 SRC2 SRC2 FEQ.D DST temp temp2 AND ] }
        { cc/< [ DST SRC1 SRC2 FLT.D DST DST 1 XORI ] }
        { cc/<= [ DST SRC1 SRC2 FLE.D DST DST 1 XORI ] }
        { cc/> [ DST SRC2 SRC1 FLT.D DST DST 1 XORI ] }
        { cc/>= [ DST SRC2 SRC1 FLE.D DST DST 1 XORI ] }
        { cc/= [ DST SRC1 SRC2 FEQ.D DST DST 1 XORI ] }
        { cc/<> [ temp SRC1 SRC1 FEQ.D temp2 SRC2 SRC2 FEQ.D
            DST SRC1 SRC2 FEQ.D temp temp temp2 AND temp temp 1 XORI DST DST temp OR ] }
        { cc/<>= [ temp SRC1 SRC1 FEQ.D temp2 SRC2 SRC2 FEQ.D DST temp temp2 AND DST DST 1 XORI ] }
    } case ;
M:: riscv.32 %compare-float-ordered ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc float-bit DST TEMP boolean-result ;
:: quiet-float-bit ( DST SRC1 SRC2 cc -- )
    <label> :> ordered <label> :> end
    temp SRC1 SRC1 FEQ.D temp2 SRC2 SRC2 FEQ.D temp temp temp2 AND
    ordered temp branch-bit
    DST cc { cc/< cc/<= cc/> cc/>= cc/= cc/<> cc/<>= } member? 1 0 ? LI
    end %jump-label
    ordered resolve-label DST SRC1 SRC2 cc float-bit end resolve-label ;
M:: riscv.32 %compare-float-unordered ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc quiet-float-bit DST TEMP boolean-result ;
M:: riscv.32 %compare-float-ordered-branch ( label SRC1 SRC2 cc -- )
    IP1 SRC1 SRC2 cc float-bit label IP1 branch-bit ;
M:: riscv.32 %compare-float-unordered-branch ( label SRC1 SRC2 cc -- )
    IP1 SRC1 SRC2 cc quiet-float-bit label IP1 branch-bit ;

UNION: integer-rep int-rep tagged-rep ;
: load-rep ( DST base offset rep -- )
    {
        { int-rep [ LW ] } { tagged-rep [ LW ] }
        { float-rep [ FLW ] } { double-rep [ FLD ] }
    } case ;
: store-rep ( SRC base offset rep -- )
    {
        { int-rep [ SW ] } { tagged-rep [ SW ] }
        { float-rep [ FSW ] } { double-rep [ FSD ] }
    } case ;
:: copy-register ( DST SRC rep -- )
    rep integer-rep? [ DST SRC MV ] [
        rep float-rep? [ DST SRC FMV.S ] [ DST SRC FMV.D ] if
    ] if ;
M:: riscv.32 %copy ( DST SRC rep -- )
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
M: riscv.32 %spill -rot %copy ;
M: riscv.32 %reload swap %copy ;

! Foreign integer accesses retain their declared width and signedness.
:: load-memory ( DST base offset rep c-type -- )
    base offset temp memory-offset :> ( BASE disp )
    c-type rep integer-rep? and [
        c-type heap-size c-type c-type-signed :> signed?
        { { 1 [ signed? [ DST BASE disp LB ] [ DST BASE disp LBU ] if ] }
          { 2 [ signed? [ DST BASE disp LH ] [ DST BASE disp LHU ] if ] }
          { 4 [ DST BASE disp LW ] }
          { 8 [ DST BASE disp LW ] } } case
    ] [ DST BASE disp rep load-rep ] if ;
:: store-memory ( SRC base offset rep c-type -- )
    base offset temp memory-offset :> ( BASE disp )
    c-type rep integer-rep? and [
        c-type heap-size { { 1 [ SRC BASE disp SB ] } { 2 [ SRC BASE disp SH ] }
          { 4 [ SRC BASE disp SW ] } { 8 [ SRC BASE disp SW ] } } case
    ] [ SRC BASE disp rep store-rep ] if ;
M: riscv.32 %load-memory-imm load-memory ;
M: riscv.32 %store-memory-imm store-memory ;
M:: riscv.32 %load-memory ( DST BASE DISP scale offset rep c-type -- )
    temp2 DISP scale SLLI temp2 BASE temp2 ADD DST temp2 offset rep c-type load-memory ;
M:: riscv.32 %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    temp2 DISP scale SLLI temp2 BASE temp2 ADD SRC temp2 offset rep c-type store-memory ;
M:: riscv.32 %convert-integer ( DST SRC c-type -- )
    32 c-type heap-size 8 * - :> count
    count zero? [ DST SRC MV ] [
        DST SRC count SLLI
        c-type c-type-signed [ DST DST count SRAI ] [ DST DST count SRLI ] if
    ] if ;
M:: riscv.32 %alien-global ( DST symbol library -- ) symbol library DST load-address rel-dlsym ;
M: riscv.32 %vm-field [ VM ] dip temp memory-offset LW ;
M: riscv.32 %set-vm-field [ VM ] dip temp memory-offset SW ;
M: riscv.32 %unbox-alien alien-offset LW ;
M:: riscv.32 %unbox-any-c-ptr ( DST SRC -- )
    <label> :> end
    temp SRC \ f type-number XORI temp temp SEQZ
    DST ZERO MV end temp branch-bit
    temp SRC tag-mask get ANDI temp temp alien type-number XORI
    DST SRC byte-array-offset add-offset end temp branch-bit
    DST SRC alien-offset LW end resolve-label ;
M:: riscv.32 %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset LW
    temp2 DST size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset SW
    temp class type-number tag-header LI temp DST 0 SW
    DST DST class type-number ADDI ;
:: alien-store ( SRC DST n -- ) SRC DST n cells alien type-number - SW ;
M:: riscv.32 %box-alien ( DST SRC TEMP -- )
    <label> :> end
    DST \ f type-number LI temp SRC SEQZ end temp branch-bit
    DST 5 cells alien TEMP %allot temp \ f type-number LI
    temp DST 1 alien-store temp DST 2 alien-store
    SRC DST 3 alien-store SRC DST 4 alien-store end resolve-label ;
M:: riscv.32 %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    <label> :> end <label> :> not-f <label> :> not-alien
    DST BASE MV temp DISP SEQZ end temp branch-bit
    DST 5 cells alien TEMP %allot temp \ f type-number LI
    temp DST 2 alien-store
    temp BASE \ f type-number XORI not-f temp branch-bit
    temp \ f type-number LI temp DST 1 alien-store DISP DST 3 alien-store DISP DST 4 alien-store end %jump-label
    not-f resolve-label temp BASE tag-mask get ANDI temp temp alien type-number XORI
    not-alien temp branch-bit
    temp BASE 1 cells alien type-number - LW temp DST 1 alien-store
    temp BASE 2 cells alien type-number - LW temp DST 2 alien-store
    temp BASE 3 cells alien type-number - LW temp temp DISP ADD temp DST 3 alien-store
    temp BASE 4 cells alien type-number - LW temp temp DISP ADD temp DST 4 alien-store end %jump-label
    not-alien resolve-label BASE DST 1 alien-store DISP DST 3 alien-store
    temp BASE DISP ADD temp temp byte-array-offset add-offset temp DST 4 alien-store end resolve-label ;
:: write-barrier ( CARD TEMP -- )
    temp card-mark LI CARD CARD card-bits SRLI
    TEMP VM vm-cards-offset-offset LW TEMP TEMP CARD ADD temp TEMP 0 SB
    CARD CARD deck-bits card-bits - SRLI
    TEMP VM vm-decks-offset-offset LW TEMP TEMP CARD ADD temp TEMP 0 SB ;
M:: riscv.32 %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SRC SLOT ADD CARD TEMP write-barrier ;
M:: riscv.32 %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot tag slot-offset add-offset CARD TEMP write-barrier ;
M:: riscv.32 %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset LW TEMP1 TEMP1 size add-offset
    TEMP2 VM vm-nursery-end-offset LW
    temp TEMP2 TEMP1 SLTU cc cc<= eq? [ temp temp 1 XORI ] when label temp branch-bit ;
M: riscv.32 %call-gc \ minor-gc %call gc-map-here ;
M: riscv.32 %prologue
    SP SP -16 ADDI FP SP 0 SW RA SP 4 SW FP SP MV
    16 - neg SP SP rot add-offset ;
M: riscv.32 %epilogue
    16 - SP SP rot add-offset FP SP 0 LW RA SP 4 LW SP SP 16 ADDI ;
M: riscv.32 %safepoint SAFEPOINT SAFEPOINT 0 SW ;

M: riscv.32 return-regs
    { { int-regs ${ A0 A1 } } { float-regs ${ FA0 FA1 } } } ;
M: riscv.32 param-regs
    drop { { int-regs ${ A0 A1 A2 A3 A4 A5 A6 A7 } }
           { float-regs ${ FA0 FA1 FA2 FA3 FA4 FA5 FA6 FA7 } } } ;
M: riscv.32 dummy-stack-params? f ;
M: riscv.32 dummy-int-params? f ;
M: riscv.32 dummy-fp-params? f ;
M: riscv.32 long-long-on-stack? f ;
M: riscv.32 long-long-odd-register? f ;
M: riscv.32 float-right-align-on-stack? f ;
M: riscv.32 struct-return-on-stack? f ;
: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
: load-reg-param ( vreg rep reg -- ) swap %copy ;
: store-reg-param ( vreg rep reg -- ) -rot %copy ;
M:: riscv.32 %unbox ( DST SRC func rep -- )
    arg1 SRC tagged-rep %copy arg2 VM MV func f f %c-invoke
    DST rep rep return-reg load-reg-param ;
M:: riscv.32 %box ( DST SRC func rep gc-map -- )
    rep reg-class-of f param-regs at first SRC rep %copy
    rep int-rep? arg2 arg1 ? VM MV func f gc-map %c-invoke
    DST int-rep int-rep return-reg load-reg-param ;
M:: riscv.32 %unbox-long-long ( DST1 DST2 SRC func -- )
    arg1 SRC tagged-rep %copy arg2 VM MV func f f %c-invoke
    temp2 arg1 MV DST2 arg2 int-rep %copy DST1 temp2 int-rep %copy ;
M:: riscv.32 %box-long-long ( DST SRC1 SRC2 func gc-map -- )
    temp2 SRC1 int-rep %copy arg2 SRC2 int-rep %copy arg1 temp2 MV
    arg3 VM MV func f gc-map %c-invoke DST arg1 tagged-rep %copy ;
M:: riscv.32 %local-allot ( DST size align offset -- ) DST SP offset local-allot-offset add-offset ;
M:: riscv.32 %save-context ( TEMP1 TEMP2 -- )
    FP CTX context-callstack-top-offset SW DS CTX context-datastack-offset SW RS CTX context-retainstack-offset SW ;
M:: riscv.32 %c-invoke ( symbol dll gc-map -- )
    symbol dll IP0 load-address rel-dlsym RA TRAMPOLINE 0 JALR gc-map gc-map-here ;
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
    IP1 SP size 16 - add-offset symbol dll IP0 load-address rel-dlsym
    RA TRAMPOLINE2 0 JALR gc-map size stack-call-gc-map gc-map-here ;
M: riscv.32 %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ] [ -roll '[ _ _ _ _ c-invoke-stack ] ]
    if-zero %alien-assembly ;
: ?spill-slot ( obj -- reg )
    dup spill-slot? [ n>> spill-offset SP swap temp memory-offset temp2 -rot LW temp2 ] when ;
:: c-indirect-stack ( size src gc-map -- )
    IP1 SP size 16 - add-offset IP0 src ?spill-slot MV
    RA TRAMPOLINE2 0 JALR gc-map size stack-call-gc-map gc-map-here ;
M: riscv.32 %alien-indirect
    [ 8 nrot ] dip pick [ '[
        IP0 _ ?spill-slot MV RA TRAMPOLINE 0 JALR _ gc-map-here
    ] ] [ -rot '[ _ _ _ c-indirect-stack ] ] if-zero %alien-assembly ;
:: store-stack-param ( vreg rep offset size -- )
    rep integer-rep? temp2 fp-temp ? :> scratch
    scratch vreg rep %copy
    scratch SP offset rep f store-memory ;
M: riscv.32 %alien-assembly
    3nip swap {
        [ [ first3 store-reg-param ] each ]
        [ [ first4 store-stack-param ] each ]
        [ call( -- ) ]
        [ [ first3 load-reg-param ] each ]
    } spread drop ;
:: load-stack-param ( vreg rep offset size -- )
    temp2 CTX context-callstack-save-offset LW
    vreg spill-slot? [
        rep integer-rep? IP0 fp-temp ? :> scratch
        scratch temp2 offset 64 + rep f load-memory
        vreg scratch rep %copy
    ] [ vreg temp2 offset 64 + rep f load-memory ] if ;
M: riscv.32 %callback-inputs
    [ [ first3 load-reg-param ] each ] [ [ first4 load-stack-param ] each ] bi*
    arg1 VM MV arg2 ZERO MV "begin_callback" f f %c-invoke ;
M: riscv.32 %callback-stack
    dup CTX context-callstack-save-offset LW dup 96 ADDI ;
M: riscv.32 %callback-outputs
    arg1 VM MV "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;
M: riscv.32 enable-cpu-features
    enable-float-intrinsics enable-fsqrt
    enable-float-min/max enable-min/max ;
M: riscv.32 complex-addressing? f ;
M: riscv.32 integer-float-needs-stack-frame? f ;
M: riscv.32 fused-unboxing? t ;
M: riscv.32 immediate-arithmetic? simm12? ;
M: riscv.32 immediate-bitwise? simm12? ;
M: riscv.32 immediate-comparand? dup fixnum? [ simm12? ] [ not ] if ;
M: riscv.32 immediate-store? drop f ;
