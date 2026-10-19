! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs byte-arrays
classes.algebra combinators compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.intrinsics compiler.cfg.registers compiler.cfg.stack-frame
compiler.codegen.gc-maps compiler.codegen.labels compiler.codegen.relocation
compiler.constants cpu.architecture cpu.mips.assembler
cpu.mips.assembler.registers generalizations kernel layouts literals locals
math math.bitwise math.order memory namespaces sequences system words ;
QUALIFIED: alien.accessors
IN: cpu.mips

! The scoped target also lets a host compiler validate emission for both
! widths without replacing the running VM's global CPU or mips-cell size.
: mips-cpu ( -- cpu ) \ cpu get ;
: mips-soft-float-abi? ( -- ? )
    mips-cpu mips64? \ os get netbsd? and ;
: mips-cell ( -- n ) mips-cpu mips32? 4 8 ? ;
: mips-cells ( n -- n' ) mips-cell * ;
: mips-cell-bits ( -- n ) 8 mips-cells ;

! Only caller-saved registers are allocated. Fixed VM registers s0-s7,
! gp, fp, t8/t9 and the two integer temporaries are never virtual registers.
M: mips machine-registers
    { { int-regs ${ V0 V1 A0 A1 A2 A3 R10 R11 R12 R13 R14 } }
      { float-regs ${ F0 F2 F4 F6 F8 F10 F12 F14 F16 F18 } } } ;
M: mips frame-reg FP ;
M: mips gc-root-offset n>> spill-offset 16 + mips-cell /i ;
M: mips vm-stack-space 32 ;
: simm16? ( n -- ? ) dup 16 >signed = ;
: uimm16? ( n -- ? ) dup 16 bits = ;
HOOK: cell-load cpu ( dst base offset -- )
HOOK: cell-store cpu ( src base offset -- )
HOOK: cell-add cpu ( dst src1 src2 -- )
HOOK: cell-sub cpu ( dst src1 src2 -- )
HOOK: cell-addi cpu ( dst src offset -- )
HOOK: cell-shl cpu ( dst src count -- )
HOOK: cell-shr cpu ( dst src count -- )
HOOK: cell-sar cpu ( dst src count -- )
HOOK: cell-shli cpu ( dst src count -- )
HOOK: cell-shri cpu ( dst src count -- )
HOOK: cell-sari cpu ( dst src count -- )
HOOK: cell-mul cpu ( src1 src2 -- )
HOOK: unsigned-word-load cpu ( dst base offset -- )
M: mips32 unsigned-word-load LW ;
M: mips64 unsigned-word-load LWU ;
HOOK: cell-li cpu ( dst value -- )
M: mips32 cell-load LW ;
M: mips64 cell-load LD ;
M: mips32 cell-store SW ;
M: mips64 cell-store SD ;
M: mips32 cell-add ADDU ;
M: mips64 cell-add DADDU ;
M: mips32 cell-sub SUBU ;
M: mips64 cell-sub DSUBU ;
M: mips32 cell-addi ADDIU ;
M: mips64 cell-addi DADDIU ;
M: mips32 cell-shl SLLV ;
M: mips64 cell-shl DSLLV ;
M: mips32 cell-shr SRLV ;
M: mips64 cell-shr DSRLV ;
M: mips32 cell-sar SRAV ;
M: mips64 cell-sar DSRAV ;
M: mips32 cell-shli SLL ;
M: mips64 cell-shli dup 32 >= [ 32 - DSLL32 ] [ DSLL ] if ;
M: mips32 cell-shri SRL ;
M: mips64 cell-shri dup 32 >= [ 32 - DSRL32 ] [ DSRL ] if ;
M: mips32 cell-sari SRA ;
M: mips64 cell-sari dup 32 >= [ 32 - DSRA32 ] [ DSRA ] if ;
M: mips32 cell-mul MULT ;
M: mips64 cell-mul DMULT ;
M: mips32 cell-li LI32 ;
M: mips64 cell-li LI64 ;
! Relocatable addresses keep the fixed-size literal sequence. Ordinary
! signed immediates fit one instruction, including cheap rematerializations.
M:: mips %load-immediate ( DST value -- )
    value -32768 32767 between?
    [ DST ZERO value cell-addi ] [ DST value cell-li ] if ;
: load-address ( value dst -- value class ) 0 cell-li rc-native-0 ;
M: mips %load-reference
    [ swap load-address rel-literal ] [ \ f type-number cell-li ] if* ;
M:: mips %load-float ( DST value -- )
    temp 0 cell-li value alien.c-types:float <ref> rc-native-0 rel-binary-literal
    DST temp 0 LWC1 ;
M:: mips %load-double ( DST value -- )
    temp 0 cell-li value double <ref> rc-native-0 rel-binary-literal
    DST temp 0 LDC1 ;
:: add-offset ( DST SRC offset -- )
    offset simm16? [ DST SRC offset cell-addi ]
    [ temp offset cell-li DST SRC temp cell-add ] if ;
:: memory-offset ( base offset scratch -- base' offset' )
    offset simm16? [ base offset ]
    [ scratch offset cell-li scratch base scratch cell-add scratch 0 ] if ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> mips-cells neg ] bi temp memory-offset ;
M: mips %peek loc>address cell-load ;
M: mips %replace loc>address cell-store ;
M:: mips %replace-imm ( src loc -- )
    temp2 src [ tag-fixnum ] [ \ f type-number ] if* cell-li temp2 loc %replace ;
M: mips %clear [ 297 ] dip %replace-imm ;
M: mips %inc [ ds-loc? DS RS ? dup ] [ n>> mips-cells ] bi add-offset ;
M: mips stack-frame-size (stack-frame-size) 16 + 16 align ;
M: mips %call T9 load-address rel-word-pic T9 CALL ;
M: mips %jump
    PIC-TAIL 0 cell-li mips-cpu mips32? 16 36 ? rc-native-0 rel-here
    T9 load-address rel-word-pic-tail T9 JUMP ;
M: mips %jump-label T9 0 cell-li rc-native-0 label-fixup T9 JUMP ;
M: mips %return RET ;
M:: mips %dispatch ( SRC TEMP -- )
    <label> :> table
    temp 0 cell-li table rc-native-0 label-fixup
    temp temp SRC cell-add temp temp 0 cell-load temp JUMP
    mips-cell align-code table resolve-label ;
M: mips %slot 2drop [ temp ] 2dip cell-add temp 0 cell-load ;
M: mips %slot-imm slot-offset temp memory-offset cell-load ;
M: mips %set-slot 2drop [ temp ] 2dip cell-add temp 0 cell-store ;
M: mips %set-slot-imm slot-offset temp memory-offset cell-store ;
M: mips %add cell-add ;
M: mips %add-imm add-offset ;
M: mips %sub cell-sub ;
M: mips %sub-imm neg add-offset ;
M:: mips %mul ( DST SRC1 SRC2 -- ) SRC1 SRC2 cell-mul DST MFLO ;
M:: mips %mneg ( DST SRC1 SRC2 -- ) DST SRC1 SRC2 %mul DST DST %neg ;
M:: mips %mul-imm ( DST SRC value -- ) temp value cell-li DST SRC temp %mul ;
M: mips %and AND ;
M:: mips %and-imm ( DST SRC value -- )
    value uimm16? [ DST SRC value ANDI ] [ temp value cell-li DST SRC temp AND ] if ;
M: mips %or OR ;
M:: mips %or-imm ( DST SRC value -- )
    value uimm16? [ DST SRC value ORI ] [ temp value cell-li DST SRC temp OR ] if ;
M: mips %xor XOR ;
M:: mips %xor-imm ( DST SRC value -- )
    value uimm16? [ DST SRC value XORI ] [ temp value cell-li DST SRC temp XOR ] if ;
M: mips %shl cell-shl ;
M: mips %shl-imm cell-shli ;
M: mips %shr cell-shr ;
M: mips %shr-imm cell-shri ;
M: mips %sar cell-sar ;
M: mips %sar-imm cell-sari ;
M: mips %not NOT ;
M: mips32 %neg NEG ;
M: mips64 %neg DNEG ;
M:: mips %min ( DST SRC1 SRC2 -- )
    temp SRC1 SRC2 SLT temp2 SRC2 MOV temp2 SRC1 temp MOVN DST temp2 MOV ;
M:: mips %max ( DST SRC1 SRC2 -- )
    temp SRC1 SRC2 SLT temp2 SRC1 MOV temp2 SRC2 temp MOVN DST temp2 MOV ;
:: set-zero-bit ( DST SRC -- ) DST SRC 1 SLTIU ;
:: set-nonzero-bit ( DST SRC -- ) DST ZERO SRC SLTU ;
! Fixed literal jumps keep conditional labels independent of branch range.
:: compare-bit ( DST SRC1 SRC2 cc -- )
    cc order-cc {
        { cc< [ DST SRC1 SRC2 SLT ] }
        { cc<= [ DST SRC2 SRC1 SLT DST DST 1 XORI ] }
        { cc> [ DST SRC2 SRC1 SLT ] }
        { cc>= [ DST SRC1 SRC2 SLT DST DST 1 XORI ] }
        { cc= [ DST SRC1 SRC2 XOR DST DST set-zero-bit ] }
        { cc/= [ DST SRC1 SRC2 XOR DST DST set-nonzero-bit ] }
        { t [ DST 1 cell-li ] }
        { f [ DST 0 cell-li ] }
    } case ;
:: boolean-result ( DST BIT -- )
    DST \ f type-number cell-li
    BIT ZERO mips-cpu mips32? 12 32 ? BEQ NOP
    t DST load-address rel-literal ;
:: branch-bit ( label BIT -- )
    BIT ZERO mips-cpu mips32? 20 40 ? BEQ NOP label %jump-label ;
M:: mips %compare ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc compare-bit DST TEMP boolean-result ;
M:: mips %compare-integer-imm ( DST SRC value cc TEMP -- )
    temp value cell-li DST SRC temp cc TEMP %compare ;
M: mips %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: mips %compare-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc compare-bit label temp2 branch-bit ;
M:: mips %compare-integer-imm-branch ( label SRC value cc -- )
    temp value cell-li label SRC temp cc %compare-branch ;
M: mips %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;

M:: mips %fixnum-add ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 XOR temp2 SRC1 MOV DST SRC1 SRC2 cell-add
    temp2 temp2 DST XOR temp temp NOT temp temp temp2 AND
    temp2 temp ZERO SLT
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;
M:: mips %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 XOR temp2 SRC1 MOV DST SRC1 SRC2 cell-sub
    temp2 temp2 DST XOR temp temp temp2 AND temp2 temp ZERO SLT
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;
M:: mips %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    SRC1 SRC2 cell-mul temp MFHI DST MFLO
    temp2 DST mips-cell-bits 1 - cell-sari temp2 temp temp2 XOR
    temp2 temp2 set-nonzero-bit
    cc cc/o eq? [ temp2 temp2 1 XORI ] when label temp2 branch-bit ;
M: mips %add-float ADD.D ;
M: mips %sub-float SUB.D ;
M: mips %mul-float MUL.D ;
M: mips %div-float DIV.D ;
M: mips %sqrt SQRT.D ;
M: mips %single>double-float CVT.D.S ;
M: mips %double>single-float CVT.S.D ;
M:: mips32 %integer>float ( DST SRC -- ) SRC DST MTC1 DST DST CVT.D.W ;
M:: mips64 %integer>float ( DST SRC -- ) SRC DST DMTC1 DST DST CVT.D.L ;
M:: mips32 %float>integer ( DST SRC -- ) F30 SRC TRUNC.W.D DST F30 MFC1 ;
M:: mips64 %float>integer ( DST SRC -- ) F30 SRC TRUNC.L.D DST F30 DMFC1 ;

! COP1's condition bit is copied to a GPR with a short branch whose
! explicit delay slot cannot change the condition or either source.
:: fp-condition-bit ( DST inverse? -- )
    DST ZERO 0 ORI
    8 inverse? [ BC1T ] [ BC1F ] if NOP
    DST ZERO 1 ORI ;
:: ordered-float-bit ( DST SRC1 SRC2 cc -- )
    cc {
        { cc< [ SRC1 SRC2 C.LT.D DST f fp-condition-bit ] }
        { cc<= [ SRC1 SRC2 C.LE.D DST f fp-condition-bit ] }
        { cc> [ SRC2 SRC1 C.LT.D DST f fp-condition-bit ] }
        { cc>= [ SRC2 SRC1 C.LE.D DST f fp-condition-bit ] }
        { cc= [ SRC1 SRC2 C.EQ.D DST f fp-condition-bit ] }
        { cc<> [ SRC1 SRC2 C.EQ.D DST t fp-condition-bit ] }
        { cc<>= [ DST 1 cell-li ] }
        { cc/< [ SRC1 SRC2 C.LT.D DST t fp-condition-bit ] }
        { cc/<= [ SRC1 SRC2 C.LE.D DST t fp-condition-bit ] }
        { cc/> [ SRC2 SRC1 C.LT.D DST t fp-condition-bit ] }
        { cc/>= [ SRC2 SRC1 C.LE.D DST t fp-condition-bit ] }
        { cc/= [ SRC1 SRC2 C.EQ.D DST t fp-condition-bit ] }
        { cc/<> [ SRC1 SRC2 C.EQ.D DST f fp-condition-bit ] }
        { cc/<>= [ DST 0 cell-li ] }
    } case ;
:: float-bit ( DST SRC1 SRC2 cc -- )
    <label> :> ordered <label> :> end
    SRC1 SRC2 C.UN.D DST t fp-condition-bit ordered DST branch-bit
    DST cc { cc/< cc/<= cc/> cc/>= cc/= cc/<> cc/<>= } member? 1 0 ? cell-li
    end %jump-label
    ordered resolve-label DST SRC1 SRC2 cc ordered-float-bit end resolve-label ;
M:: mips %compare-float-ordered ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc float-bit DST TEMP boolean-result ;
M: mips %compare-float-unordered %compare-float-ordered ;
M:: mips %compare-float-ordered-branch ( label SRC1 SRC2 cc -- )
    IP1 SRC1 SRC2 cc float-bit label IP1 branch-bit ;
M: mips %compare-float-unordered-branch %compare-float-ordered-branch ;

UNION: integer-rep int-rep tagged-rep ;
: load-rep ( DST base offset rep -- )
    {
        { int-rep [ cell-load ] } { tagged-rep [ cell-load ] }
        { float-rep [ LWC1 ] } { double-rep [ LDC1 ] }
    } case ;
: store-rep ( SRC base offset rep -- )
    {
        { int-rep [ cell-store ] } { tagged-rep [ cell-store ] }
        { float-rep [ SWC1 ] } { double-rep [ SDC1 ] }
    } case ;
:: copy-register ( DST SRC rep -- )
    rep integer-rep? [ DST SRC MOV ] [
        rep float-rep? [ DST SRC MOV.S ] [ DST SRC MOV.D ] if
    ] if ;
M:: mips %copy ( DST SRC rep -- )
    DST SRC eq? [ ] [
        DST spill-slot? [
            SRC spill-slot? [
                rep integer-rep? temp2 F30 ? :> scratch
                scratch SP SRC n>> spill-offset temp memory-offset rep load-rep
                scratch SP DST n>> spill-offset temp memory-offset rep store-rep
            ] [ SRC SP DST n>> spill-offset temp memory-offset rep store-rep ] if
        ] [
            SRC spill-slot? [ DST SP SRC n>> spill-offset temp memory-offset rep load-rep ]
            [ DST SRC rep copy-register ] if
        ] if
    ] if ;
M: mips %spill -rot %copy ;
M: mips %reload swap %copy ;

! Foreign pointers and packed struct fields can have byte alignment.
! Merge pairs avoid alignment traps without changing aligned VM object loads.
:: word-load ( DST BASE offset -- )
    mips-big-endian? get [
        DST BASE offset LWL DST BASE offset 3 + LWR
    ] [ DST BASE offset 3 + LWL DST BASE offset LWR ] if ;
:: word-store ( SRC BASE offset -- )
    mips-big-endian? get [
        SRC BASE offset SWL SRC BASE offset 3 + SWR
    ] [ SRC BASE offset 3 + SWL SRC BASE offset SWR ] if ;
:: quad-load ( DST BASE offset -- )
    mips-big-endian? get [
        DST BASE offset LDL DST BASE offset 7 + LDR
    ] [ DST BASE offset 7 + LDL DST BASE offset LDR ] if ;
:: quad-store ( SRC BASE offset -- )
    mips-big-endian? get [
        SRC BASE offset SDL SRC BASE offset 7 + SDR
    ] [ SRC BASE offset 7 + SDL SRC BASE offset SDR ] if ;
HOOK: foreign-cell-load cpu ( dst base offset -- )
HOOK: foreign-cell-store cpu ( src base offset -- )
M: mips32 foreign-cell-load word-load ;
M: mips64 foreign-cell-load quad-load ;
M: mips32 foreign-cell-store word-store ;
M: mips64 foreign-cell-store quad-store ;
: next-fp ( reg -- reg' ) n>> 1 + fp-register boa ;
HOOK: foreign-double-load cpu ( dst base offset -- )
HOOK: foreign-double-store cpu ( src base offset -- )
M:: mips32 foreign-double-load ( DST BASE offset -- )
    ! Even paired FPRs hold the low word in BOTH native byte orders.
    IP0 BASE offset word-load
    IP0 mips-big-endian? get [ DST next-fp ] [ DST ] if MTC1
    IP0 BASE offset 4 + word-load
    IP0 mips-big-endian? get [ DST ] [ DST next-fp ] if MTC1 ;
M:: mips64 foreign-double-load ( DST BASE offset -- )
    IP0 BASE offset quad-load IP0 DST DMTC1 ;
M:: mips32 foreign-double-store ( SRC BASE offset -- )
    IP0 mips-big-endian? get [ SRC next-fp ] [ SRC ] if MFC1
    IP0 BASE offset word-store
    IP0 mips-big-endian? get [ SRC ] [ SRC next-fp ] if MFC1
    IP0 BASE offset 4 + word-store ;
M:: mips64 foreign-double-store ( SRC BASE offset -- )
    IP0 SRC DMFC1 IP0 BASE offset quad-store ;
:: foreign-address ( BASE offset -- base' offset' )
    IP1 BASE MOV
    offset simm16? offset 7 + simm16? and [ IP1 offset ] [
        temp1 offset cell-li IP1 IP1 temp1 cell-add IP1 0
    ] if ;
:: half-load ( DST BASE offset signed? -- )
    DST BASE offset LBU temp1 BASE offset 1 + LBU
    mips-big-endian? get [ DST DST 8 cell-shli ] [ temp1 temp1 8 cell-shli ] if
    DST DST temp1 OR
    signed? [ DST DST mips-cell-bits 16 - cell-shli
        DST DST mips-cell-bits 16 - cell-sari ] when ;
:: half-store ( SRC BASE offset -- )
    temp1 SRC 8 cell-shri
    mips-big-endian? get [
        temp1 BASE offset SB SRC BASE offset 1 + SB
    ] [ SRC BASE offset SB temp1 BASE offset 1 + SB ] if ;
:: load-memory ( DST base offset rep c-type -- )
    base offset foreign-address :> ( BASE disp )
    rep integer-rep? [
        c-type [ c-type heap-size ] [ mips-cell ] if :> width
        c-type [ c-type c-type-signed ] [ t ] if :> signed?
        width {
            { 1 [ signed? [ IP0 BASE disp LB ] [ IP0 BASE disp LBU ] if ] }
            { 2 [ IP0 BASE disp signed? half-load ] }
            { 4 [ IP0 BASE disp word-load
                signed? not mips-cpu mips64? and [
                    IP0 IP0 32 cell-shli IP0 IP0 32 cell-shri
                ] when ] }
            { 8 [ IP0 BASE disp quad-load ] }
        } case DST IP0 MOV
    ] [
        rep float-rep? [ IP0 BASE disp word-load IP0 DST MTC1 ]
        [ DST BASE disp foreign-double-load ] if
    ] if ;
:: store-memory ( SRC base offset rep c-type -- )
    base offset foreign-address :> ( BASE disp )
    rep integer-rep? [
        IP0 SRC MOV c-type [ c-type heap-size ] [ mips-cell ] if {
            { 1 [ IP0 BASE disp SB ] }
            { 2 [ IP0 BASE disp half-store ] }
            { 4 [ IP0 BASE disp word-store ] }
            { 8 [ IP0 BASE disp quad-store ] }
        } case
    ] [
        rep float-rep? [ IP0 SRC MFC1 IP0 BASE disp word-store ]
        [ SRC BASE disp foreign-double-store ] if
    ] if ;
M: mips %load-memory-imm load-memory ;
M: mips %store-memory-imm store-memory ;
M:: mips %load-memory ( DST BASE DISP scale offset rep c-type -- )
    temp2 DISP scale cell-shli temp2 BASE temp2 cell-add DST temp2 offset rep c-type load-memory ;
M:: mips %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    temp2 DISP scale cell-shli temp2 BASE temp2 cell-add SRC temp2 offset rep c-type store-memory ;
M:: mips %convert-integer ( DST SRC c-type -- )
    mips-cell-bits c-type heap-size 8 * - :> count
    count zero? [ DST SRC MOV ] [
        DST SRC count cell-shli
        c-type c-type-signed [ DST DST count cell-sari ] [ DST DST count cell-shri ] if
    ] if ;
M:: mips %alien-global ( DST symbol library -- ) symbol library DST load-address rel-dlsym ;
M: mips %vm-field [ VM ] dip temp memory-offset cell-load ;
M: mips %set-vm-field [ VM ] dip temp memory-offset cell-store ;
M: mips %unbox-alien alien-offset cell-load ;
M:: mips %unbox-any-c-ptr ( DST SRC -- )
    IP1 SRC MOV
    <label> :> end
    temp IP1 \ f type-number XORI temp temp set-zero-bit
    DST ZERO MOV end temp branch-bit
    temp IP1 tag-mask get ANDI temp temp alien type-number XORI
    DST IP1 byte-array-offset add-offset end temp branch-bit
    DST IP1 alien-offset cell-load end resolve-label ;
M:: mips %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset cell-load
    temp2 DST size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset cell-store
    temp class type-number tag-header cell-li temp DST 0 cell-store
    DST DST class type-number cell-addi ;
:: alien-store ( SRC DST n -- ) SRC DST n mips-cells alien type-number - cell-store ;
M:: mips %box-alien ( DST SRC TEMP -- )
    IP1 SRC MOV
    <label> :> end
    DST \ f type-number cell-li temp IP1 set-zero-bit end temp branch-bit
    DST 5 mips-cells alien TEMP %allot temp \ f type-number cell-li
    temp DST 1 alien-store temp DST 2 alien-store
    IP1 DST 3 alien-store IP1 DST 4 alien-store end resolve-label ;
M:: mips %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    IP1 BASE MOV temp1 DISP MOV
    <label> :> end <label> :> not-f <label> :> not-alien
    DST IP1 MOV temp temp1 set-zero-bit end temp branch-bit
    DST 5 mips-cells alien TEMP %allot temp \ f type-number cell-li
    temp DST 2 alien-store
    temp IP1 \ f type-number XORI not-f temp branch-bit
    temp \ f type-number cell-li temp DST 1 alien-store
    temp1 DST 3 alien-store temp1 DST 4 alien-store end %jump-label
    not-f resolve-label temp IP1 tag-mask get ANDI temp temp alien type-number XORI
    not-alien temp branch-bit
    temp IP1 1 mips-cells alien type-number - cell-load temp DST 1 alien-store
    temp IP1 2 mips-cells alien type-number - cell-load temp DST 2 alien-store
    temp IP1 3 mips-cells alien type-number - cell-load temp temp temp1 cell-add temp DST 3 alien-store
    temp IP1 4 mips-cells alien type-number - cell-load temp temp temp1 cell-add temp DST 4 alien-store end %jump-label
    not-alien resolve-label IP1 DST 1 alien-store temp1 DST 3 alien-store
    temp IP1 temp1 cell-add temp temp byte-array-offset add-offset temp DST 4 alien-store end resolve-label ;
:: write-barrier ( CARD TEMP -- )
    temp card-mark cell-li CARD CARD card-bits cell-shri
    TEMP VM vm-cards-offset-offset cell-load TEMP TEMP CARD cell-add temp TEMP 0 SB
    CARD CARD deck-bits card-bits - cell-shri
    TEMP VM vm-decks-offset-offset cell-load TEMP TEMP CARD cell-add temp TEMP 0 SB ;
M:: mips %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SRC SLOT cell-add CARD TEMP write-barrier ;
M:: mips %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot tag slot-offset add-offset CARD TEMP write-barrier ;
M:: mips %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset cell-load TEMP1 TEMP1 size add-offset
    TEMP2 VM vm-nursery-end-offset cell-load
    temp TEMP2 TEMP1 SLTU cc cc<= eq? [ temp temp 1 XORI ] when label temp branch-bit ;
M: mips %call-gc \ minor-gc %call gc-map-here ;
M: mips %prologue
    SP SP -16 cell-addi FP SP 0 cell-store RA SP mips-cell cell-store FP SP MOV
    16 - neg SP SP rot add-offset ;
M: mips %epilogue
    16 - SP SP rot add-offset FP SP 0 cell-load RA SP mips-cell cell-load SP SP 16 cell-addi ;
M: mips %safepoint SAFEPOINT SAFEPOINT 0 cell-store ;

M: mips enable-cpu-features
    mips-cpu mips64? [ enable-alien-4-intrinsics ] [
        ! Four-byte loads can exceed the O32 fixnum range and must box.
        ! Remove properties too when refreshing an older saved image.
        ! Existing inlined callers still require ordinary recompilation.
        { alien.accessors:alien-signed-4 alien.accessors:alien-unsigned-4
          alien.accessors:set-alien-signed-4 alien.accessors:set-alien-unsigned-4 }
        [ "intrinsic" remove-word-prop ] each
    ] if
    enable-float-intrinsics enable-fsqrt enable-min/max ;
M: mips complex-addressing? f ;
M: mips integer-float-needs-stack-frame? f ;
M: mips fused-unboxing? t ;
M: mips immediate-arithmetic? simm16? ;
M: mips immediate-bitwise? uimm16? ;
M: mips immediate-comparand? dup fixnum? [ simm16? ] [ not ] if ;
M: mips immediate-store? drop f ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
:: load-reg-param ( vreg rep reg -- )
    mips-soft-float-abi? rep { float-rep double-rep } member? and
    [ vreg reg rep %integer>scalar ] [ vreg reg rep %copy ] if ;
:: store-reg-param ( vreg rep reg -- )
    mips-soft-float-abi? rep { float-rep double-rep } member? and
    [ reg vreg rep %scalar>integer ] [ reg vreg rep %copy ] if ;
M:: mips %unbox ( DST SRC func rep -- )
    arg1 SRC tagged-rep %copy arg2 VM MOV func f f %c-invoke
    DST rep rep return-reg load-reg-param ;
M:: mips %box ( DST SRC func rep gc-map -- )
    mips-soft-float-abi? rep { float-rep double-rep } member? and
    [ A0 SRC rep %scalar>integer ]
    [ rep reg-class-of f param-regs at first SRC rep %copy ] if
    rep double-rep? mips-cpu mips32? and A2 A1 ? VM MOV func f gc-map %c-invoke
    DST int-rep int-rep return-reg load-reg-param ;
M:: mips %local-allot ( DST size align offset -- ) DST SP offset local-allot-offset add-offset ;
M:: mips %save-context ( TEMP1 TEMP2 -- )
    FP CTX context-callstack-top-offset cell-store DS CTX context-datastack-offset cell-store RS CTX context-retainstack-offset cell-store ;
M:: mips %c-invoke ( symbol dll gc-map -- )
    symbol dll IP0 load-address rel-dlsym TRAMPOLINE CALL gc-map gc-map-here ;
:: stack-call-gc-map ( gc-map size -- gc-map' )
    ! Trampoline2 links its frame above the outgoing arguments, size - 16 bytes
    ! above the frame used by trampoline1. Both ordinary Factor calls and
    ! trampoline1 place the frame pointer 16 bytes below caller SP.
    gc-map dup gc-map-needed? [
        [ clone [ size 16 - - ] change-n ] :> shift-slot
        clone
        [ shift-slot map ] change-gc-roots
        [ [ shift-slot bi@ ] assoc-map ] change-derived-roots
    ] when ;
:: c-invoke-stack ( size symbol dll gc-map -- )
    IP1 size 32 - cell-li IP1 SP IP1 cell-add symbol dll IP0 load-address rel-dlsym
    TRAMPOLINE2 CALL gc-map size stack-call-gc-map gc-map-here ;
M: mips %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ] [ -roll '[ _ _ _ _ c-invoke-stack ] ]
    if-zero %alien-assembly ;
: ?spill-slot ( obj -- reg )
    dup spill-slot? [ n>> spill-offset SP swap temp1 memory-offset IP0 -rot cell-load IP0 ] when ;
:: c-indirect-stack ( size src gc-map -- )
    IP1 size 32 - cell-li IP1 SP IP1 cell-add IP0 src ?spill-slot MOV
    TRAMPOLINE2 CALL gc-map size stack-call-gc-map gc-map-here ;
M: mips %alien-indirect
    [ 8 nrot ] dip pick [ '[
        IP0 _ ?spill-slot MOV TRAMPOLINE CALL _ gc-map-here
    ] ] [ -rot '[ _ _ _ c-indirect-stack ] ] if-zero %alien-assembly ;
:: store-stack-param ( vreg rep offset size -- )
    rep integer-rep? temp2 F30 ? :> scratch
    scratch vreg rep %copy
    scratch SP offset rep f store-memory ;
: soft-float-stack-argument? ( argument -- ? )
    dup length 5 = [ last float-rep eq? ] [ drop f ] if ;
:: store-stack-argument ( argument -- )
    argument soft-float-stack-argument? [
        argument first4 :> ( vreg rep offset size )
        temp2 vreg rep %copy temp2 SP offset int-rep uint store-memory
    ] [ argument first4 store-stack-param ] if ;
M: mips %alien-assembly
    3nip swap [ swap ] 2dip {
        [ [ store-stack-argument ] each ]
        [ [ first3 store-reg-param ] each ]
        [ call( -- ) ]
        [ [ first3 load-reg-param ] each ]
    } spread drop ;
:: load-stack-param ( vreg rep offset size -- )
    temp2 CTX context-callstack-save-offset cell-load
    vreg spill-slot? [
        rep integer-rep? IP0 F30 ? :> scratch
        scratch temp2 offset mips-cpu mips32? 112 224 ? + rep f load-memory
        vreg scratch rep %copy
    ] [ vreg temp2 offset mips-cpu mips32? 112 224 ? + rep f load-memory ] if ;
:: load-stack-argument ( argument -- )
    argument soft-float-stack-argument? [
        argument first4 :> ( vreg rep offset size )
        temp2 CTX context-callstack-save-offset cell-load
        IP0 temp2 offset 224 + int-rep uint load-memory
        vreg IP0 rep %copy
    ] [ argument first4 load-stack-param ] if ;
M: mips %callback-inputs
    [ [ first3 load-reg-param ] each ] [ [ load-stack-argument ] each ] bi*
    arg1 VM MOV arg2 ZERO MOV "begin_callback" f f %c-invoke ;
M: mips %callback-stack
    dup CTX context-callstack-save-offset cell-load dup mips-cpu mips32? 112 160 ? cell-addi ;
M: mips %callback-outputs
    arg1 VM MOV "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;

M: mips32 %integer>scalar drop swap MTC1 ;
M: mips32 %scalar>integer drop MFC1 ;
M: mips64 %integer>scalar
    { { float-rep [ swap MTC1 ] } { double-rep [ swap DMTC1 ] } } case ;
M: mips64 %scalar>integer
    { { float-rep [ MFC1 ] } { double-rep [ DMFC1 ] } } case ;
M:: mips32 %unbox-long-long ( DST1 DST2 SRC func -- )
    A0 SRC tagged-rep %copy A1 VM MOV func f f %c-invoke
    DST1 V0 int-rep %copy DST2 V1 int-rep %copy ;
M:: mips32 %box-long-long ( DST SRC1 SRC2 func gc-map -- )
    A0 SRC1 int-rep %copy A1 SRC2 int-rep %copy A2 VM MOV
    func f gc-map %c-invoke DST V0 int-rep %copy ;
