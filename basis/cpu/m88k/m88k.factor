! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data assocs combinators compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.intrinsics generalizations compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.m88k.assembler cpu.m88k.assembler.registers endian kernel layouts literals
locals math math.floats math.bitwise memory namespaces sequences system ;
IN: cpu.m88k

! 88100 FP operands share the integer file. Allocator banks must be disjoint.
M: m88k machine-registers
    { { int-regs ${ R2 R3 R4 R5 R6 R7 R8 R9 } }
      { float-regs ${ R10 R12 } } } ;
M: m88k frame-reg SP ;
M: m88k vm-stack-space 32 ;
M: m88k gc-root-offset n>> spill-offset 16 + 4 /i ;
: uimm16? ( n -- ? ) dup 16 bits = ;
: load-immediate ( dst value -- ) 32 bits LI32 ;
M: m88k %load-immediate load-immediate ;
: load-address ( value dst -- value class ) 0 LI32 rc-native-0 ;
M: m88k %load-reference
    [ swap load-address rel-literal ] [ \ f type-number load-immediate ] if* ;
:: add-offset ( DST SRC offset -- )
    offset uimm16? [ DST SRC offset ADDUI ] [
        offset neg uimm16? [ DST SRC offset neg SUBUI ]
        [ temp offset load-immediate DST SRC temp ADDU ] if
    ] if ;
:: memory-offset ( base offset -- base' offset' )
    offset uimm16? [ base offset ]
    [ temp base offset add-offset temp 0 ] if ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> 4 * neg ] bi memory-offset ;
M: m88k %peek loc>address LD ;
M: m88k %replace loc>address ST ;
M:: m88k %replace-imm ( src loc -- )
    temp2 src [ tag-fixnum ] [ \ f type-number ] if* load-immediate temp2 loc %replace ;
M: m88k %clear [ 297 ] dip %replace-imm ;
M: m88k %inc [ ds-loc? DS RS ? dup ] [ n>> 4 * ] bi add-offset ;
M: m88k stack-frame-size (stack-frame-size) 16 + 16 align ;
M: m88k %call IP load-address rel-word-pic IP JSR ;
M: m88k %jump
    PIC-TAIL 0 LI32 12 rc-native-0 rel-here
    IP load-address rel-word-pic-tail IP JMP ;
M: m88k %jump-label IP 0 LI32 rc-native-0 label-fixup IP JMP ;
M: m88k %return RET ;
M: m88k %slot 2drop [ temp ] 2dip ADDU temp 0 LD ;
M: m88k %slot-imm [ 4 * ] dip - memory-offset LD ;
M: m88k %set-slot 2drop [ temp ] 2dip ADDU temp 0 ST ;
M: m88k %set-slot-imm [ 4 * ] dip - memory-offset ST ;
M: m88k %add ADDU ;
M: m88k %add-imm add-offset ;
M: m88k %sub SUBU ;
M: m88k %sub-imm neg add-offset ;
M: m88k %and AND ;
M: m88k %or OR ;
M: m88k %xor XOR ;
M:: m88k %and-imm ( DST SRC value -- ) temp value load-immediate DST SRC temp AND ;
M:: m88k %or-imm ( DST SRC value -- ) temp value load-immediate DST SRC temp OR ;
M:: m88k %xor-imm ( DST SRC value -- ) temp value load-immediate DST SRC temp XOR ;
M:: m88k %not ( DST SRC -- ) temp -1 load-immediate DST SRC temp XOR ;
M:: m88k %neg ( DST SRC -- ) DST ZERO SRC SUBU ;
M: m88k %add-float FADD.D ;
M: m88k %sub-float FSUB.D ;
M: m88k %mul-float FMUL.D ;
M: m88k %div-float FDIV.D ;

! Previous SP and non-delayed link occupy the first two frame words.
M: m88k %prologue
    temp2 ZERO SP OR neg SP SP rot add-offset temp2 SP 0 ST RA SP 4 ST ;
M: m88k %epilogue drop RA SP 4 LD SP SP 0 LD ;
M: m88k %safepoint SAFEPOINT SAFEPOINT 0 ST ;
M: m88k %vm-field [ VM ] dip memory-offset LD ;
M: m88k %set-vm-field [ VM ] dip memory-offset ST ;
M:: m88k %save-context ( TEMP1 TEMP2 -- )
    SP CTX context-callstack-top-offset ST
    DS CTX context-datastack-offset ST RS CTX context-retainstack-offset ST ;
M: m88k complex-addressing? f ;
M: m88k integer-float-needs-stack-frame? t ;
M: m88k fused-unboxing? t ;
M: m88k immediate-arithmetic? abs uimm16? ;
M: m88k immediate-bitwise? drop f ;
M: m88k immediate-comparand? drop f ;
M: m88k immediate-store? drop f ;

SYMBOL: ffi-stack-adjust
: spill-address ( slot -- base offset )
    n>> spill-offset 16 + ffi-stack-adjust get 0 or + SP swap memory-offset ;
: next-register ( reg -- reg' ) n>> 1 + int-register boa ;
:: load-rep ( DST base offset rep -- )
    DST base offset LD
    rep double-rep eq? [ DST next-register base offset 4 + LD ] when ;
:: store-rep ( SRC base offset rep -- )
    SRC base offset ST
    rep double-rep eq? [ SRC next-register base offset 4 + ST ] when ;
M:: m88k %copy ( DST SRC rep -- )
    DST SRC eq? [ ] [
        DST spill-slot? [
            SRC spill-slot? [
                ! R20:R21 is a reserved pair; R19 computes large addresses.
                temp2 SRC spill-address rep load-rep
                temp2 DST spill-address rep store-rep
            ] [ SRC DST spill-address rep store-rep ] if
        ] [ SRC spill-slot? [ DST SRC spill-address rep load-rep ] [
            DST ZERO SRC OR
            rep double-rep eq? [ DST next-register ZERO SRC next-register OR ] when
        ] if ] if
    ] if ;
M: m88k %spill -rot %copy ;
M: m88k %reload swap %copy ;
M: m88k %call-gc \ minor-gc %call gc-map-here ;
M:: m88k %local-allot ( DST size align offset -- )
    DST SP offset local-allot-offset 16 + add-offset ;

M: m88k %mul MUL ;
M:: m88k %mul-imm ( DST SRC value -- ) temp value load-immediate DST SRC temp MUL ;
M:: m88k %mneg ( DST SRC1 SRC2 -- ) DST SRC1 SRC2 MUL DST ZERO DST SUBU ;
M: m88k %shl-imm MAKI ;
M: m88k %shr-imm EXTUI ;
M: m88k %sar-imm EXTI ;
:: shift-count ( count -- ) temp 31 load-immediate temp count temp AND ;
M:: m88k %shl ( DST SRC count -- ) count shift-count DST SRC temp MAK ;
M:: m88k %shr ( DST SRC count -- ) count shift-count DST SRC temp EXTU ;
M:: m88k %sar ( DST SRC count -- ) count shift-count DST SRC temp EXT ;

: compare-index ( cc -- bit )
    order-cc {
        { cc= [ 2 ] } { cc/= [ 3 ] }
        { cc> [ 4 ] } { cc<= [ 5 ] }
        { cc< [ 6 ] } { cc>= [ 7 ] }
    } case ;
:: compare-bit ( DST SRC1 SRC2 cc -- )
    cc order-cc :> ordered
    ordered { t f } member? [ DST ordered 1 0 ? load-immediate ] [
        ! Consume both inputs before writing an aliased result.
        temp2 SRC1 SRC2 CMP
        ordered compare-index temp2 16 BB1
        DST 0 load-immediate 12 BR DST 1 load-immediate
    ] if ;
:: boolean-result ( DST BIT -- )
    DST \ f type-number load-immediate
    0 BIT 12 BB0 t DST load-address rel-literal ;
:: branch-bit ( label BIT -- )
    0 BIT 16 BB0 label %jump-label ;
M:: m88k %compare ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc compare-bit DST TEMP boolean-result ;
M:: m88k %compare-integer-imm ( DST SRC value cc TEMP -- )
    temp value load-immediate DST SRC temp cc TEMP %compare ;
M: m88k %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: m88k %compare-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc compare-bit label temp2 branch-bit ;
M:: m88k %compare-integer-imm-branch ( label SRC value cc -- )
    temp value load-immediate label SRC temp cc %compare-branch ;
M: m88k %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;

M:: m88k %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset LD
    temp2 DST size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset ST
    temp class type-number tag-header load-immediate temp DST 0 ST
    DST DST class type-number add-offset ;
:: write-barrier ( CARD TEMP -- )
    temp card-mark load-immediate CARD CARD card-bits EXTUI
    TEMP VM vm-cards-offset-offset LD TEMP TEMP CARD ADDU temp TEMP 0 STB
    CARD CARD deck-bits card-bits - EXTUI
    TEMP VM vm-decks-offset-offset LD TEMP TEMP CARD ADDU temp TEMP 0 STB ;
M:: m88k %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SRC SLOT ADDU CARD TEMP write-barrier ;
M:: m88k %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot 4 * tag - add-offset CARD TEMP write-barrier ;
M:: m88k %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset LD TEMP1 TEMP1 size add-offset
    TEMP2 VM vm-nursery-end-offset LD temp2 TEMP1 TEMP2 CMP
    cc cc<= eq? 9 8 ? temp2 16 BB0 label %jump-label ;
M:: m88k %dispatch ( SRC TEMP -- )
    <label> :> table
    temp 0 LI32 table rc-native-0 label-fixup
    temp temp SRC ADDU temp temp 0 LD temp JMP
    4 align-code table resolve-label ;

UNION: integer-rep int-rep tagged-rep ;

:: foreign-address ( base offset -- base' offset' )
    PIC-TAIL ZERO base OR offset uimm16? offset 7 + uimm16? and
    [ PIC-TAIL offset ] [ PIC-TAIL PIC-TAIL offset add-offset PIC-TAIL 0 ] if ;
ERROR: unsupported-m88k-memory-width width ;
: check-memory-width ( width -- n )
    dup { 1 2 4 } member? [ unsupported-m88k-memory-width ] unless ;
:: unsigned-load ( DST BASE disp width -- )
    DST BASE disp LDBU
    width 1 - [| i |
        DST DST 8 MAKI temp BASE disp i + 1 + LDBU DST DST temp OR
    ] each-integer ;
:: byte-store ( SRC BASE disp width -- )
    width [| i |
        temp SRC width i - 1 - 8 * EXTUI temp BASE disp i + STB
    ] each-integer ;
:: load-memory ( DST base offset rep c-type -- )
    base offset foreign-address :> ( BASE disp )
    rep integer-rep? [
        c-type [ c-type heap-size ] [ 4 ] if check-memory-width :> width
        DST BASE disp width unsigned-load
        c-type [ c-type c-type-signed ] [ t ] if width 4 < and [
            DST DST 32 width 8 * - MAKI DST DST 32 width 8 * - EXTI
        ] when
    ] [
        DST BASE disp 4 unsigned-load
        rep double-rep eq? [ DST next-register BASE disp 4 + 4 unsigned-load ] when
    ] if ;
:: store-memory ( SRC base offset rep c-type -- )
    base offset foreign-address :> ( BASE disp )
    rep integer-rep? [
        SRC BASE disp c-type [ c-type heap-size ] [ 4 ] if check-memory-width byte-store
    ] [
        SRC BASE disp 4 byte-store
        rep double-rep eq? [ SRC next-register BASE disp 4 + 4 byte-store ] when
    ] if ;
M: m88k %load-memory-imm load-memory ;
M: m88k %store-memory-imm store-memory ;
M:: m88k %load-memory ( DST BASE DISP scale offset rep c-type -- )
    temp2 DISP scale MAKI temp2 BASE temp2 ADDU DST temp2 offset rep c-type load-memory ;
M:: m88k %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    temp2 DISP scale MAKI temp2 BASE temp2 ADDU SRC temp2 offset rep c-type store-memory ;
M:: m88k %convert-integer ( DST SRC c-type -- )
    32 c-type heap-size 8 * - :> count
    count zero? [ DST ZERO SRC OR ] [
        DST SRC count MAKI
        c-type c-type-signed [ DST DST count EXTI ] [ DST DST count EXTUI ] if
    ] if ;
M:: m88k %alien-global ( DST symbol library -- ) symbol library DST load-address rel-dlsym ;
M: m88k %integer>scalar drop ZERO swap OR ;
M: m88k %scalar>integer drop ZERO swap OR ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
: load-reg-param ( vreg rep reg -- ) swap %copy ;
: store-reg-param ( vreg rep reg -- ) -rot %copy ;
! The VM resolves a frame's incoming PC against predecessor-SP spills.
! This applies uniformly to ordinary callees, native bridges and signals.
M:: m88k %c-invoke ( symbol dll gc-map -- )
    symbol dll IP load-address rel-dlsym TRAMPOLINE JSR gc-map gc-map-here ;
M:: m88k %unbox ( DST SRC func rep -- )
    R2 SRC tagged-rep %copy R3 ZERO VM OR func f f %c-invoke
    DST rep rep return-reg load-reg-param ;
M:: m88k %box ( DST SRC func rep gc-map -- )
    R2 SRC rep %copy rep double-rep? R4 R3 ? ZERO VM OR
    func f gc-map %c-invoke DST int-rep R2 load-reg-param ;
M:: m88k %unbox-long-long ( DST1 DST2 SRC func -- )
    R2 SRC tagged-rep %copy R3 ZERO VM OR func f f %c-invoke
    temp2 ZERO R2 OR IP ZERO R3 OR
    DST1 temp2 int-rep %copy DST2 IP int-rep %copy ;
M:: m88k %box-long-long ( DST SRC1 SRC2 func gc-map -- )
    temp2 SRC1 int-rep %copy IP SRC2 int-rep %copy
    R2 ZERO temp2 OR R3 ZERO IP OR R4 ZERO VM OR
    func f gc-map %c-invoke DST R2 int-rep %copy ;
M: m88k %integer>float FLT.D ;
M: m88k %float>integer TRNC.D ;
M:: m88k %load-float ( DST value -- )
    temp 0 LI32 value float>bits 4 >be rc-native-0 rel-binary-literal
    DST temp 0 LD ;
M:: m88k %load-double ( DST value -- )
    temp 0 LI32 value double>bits 8 >be rc-native-0 rel-binary-literal
    DST temp 0 LD DST next-register temp 4 LD ;

: float-index ( cc -- bit invert? )
    {
        { cc< [ 6 f ] } { cc<= [ 5 f ] } { cc= [ 2 f ] }
        { cc> [ 4 f ] } { cc>= [ 7 f ] } { cc<> [ 3 f ] }
        { cc<>= [ 1 f ] } { cc/< [ 6 t ] } { cc/<= [ 5 t ] }
        { cc/= [ 2 t ] } { cc/> [ 4 t ] } { cc/>= [ 7 t ] }
        { cc/<> [ 3 t ] } { cc/<>= [ 0 f ] }
    } case ;
:: float-bit ( DST SRC1 SRC2 cc -- )
    cc float-index :> ( bit invert? )
    temp2 SRC1 SRC2 FCMP.D DST temp2 bit EXTUI
    temp 1 load-immediate DST DST temp AND
    invert? [ DST DST temp XOR ] when ;
M:: m88k %compare-float-ordered ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc float-bit DST TEMP boolean-result ;
M:: m88k %compare-float-ordered-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc float-bit label temp2 branch-bit ;

M: m88k %compare-float-unordered %compare-float-ordered ;
M: m88k %compare-float-unordered-branch %compare-float-ordered-branch ;

:: c-invoke-stack ( size symbol dll gc-map -- )
    NATIVE-STACK SP size 16 align add-offset
    symbol dll IP load-address rel-dlsym TRAMPOLINE2 JSR
    gc-map gc-map-here ;
M: m88k %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ] [ -roll '[ _ _ _ _ c-invoke-stack ] ]
    if-zero %alien-assembly ;
:: store-stack-param ( vreg rep offset size -- )
    temp2 vreg rep %copy temp2 SP offset rep f store-memory ;
M:: m88k %alien-assembly ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-size zero? 0 stack-size 16 align 16 + ? :> allocation
    SP SP allocation neg add-offset
    allocation ffi-stack-adjust [
        stack-inputs [ first4 store-stack-param ] each
        reg-inputs [ first3 store-reg-param ] each
        quot call( -- )
    ] with-variable
    SP SP allocation add-offset
    reg-outputs [ first3 load-reg-param ] each ;
: ?spill-slot ( src -- reg )
    dup spill-slot? [ IP swap int-rep %copy IP ] when ;
:: c-indirect-stack ( size src gc-map -- )
    NATIVE-STACK SP size 16 align add-offset
    IP src ?spill-slot int-rep %copy TRAMPOLINE2 JSR
    gc-map gc-map-here ;
M: m88k %alien-indirect
    [ 8 nrot ] dip pick [ '[
        IP _ ?spill-slot int-rep %copy TRAMPOLINE JSR _ gc-map-here
    ] ] [ -rot '[ _ _ _ c-indirect-stack ] ] if-zero %alien-assembly ;

! The native callback stub saves128 bytes; incoming stack arguments start
! immediately above that frame. Register snapshots occupy its last32 bytes.
:: load-stack-param ( vreg rep offset size -- )
    temp2 CTX context-callstack-save-offset LD
    temp2 temp2 offset 128 + rep f load-memory
    vreg temp2 rep %copy ;
M: m88k %callback-inputs
    [ [ first3 load-reg-param ] each ] [ [ first4 load-stack-param ] each ] bi*
    R2 ZERO VM OR R3 ZERO ZERO OR "begin_callback" f f %c-invoke ;
M: m88k %callback-stack
    dup CTX context-callstack-save-offset LD dup 128 ADDUI ;
M: m88k %callback-outputs
    R2 ZERO VM OR "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;

:: add-overflow ( DST SRC1 SRC2 -- )
    temp SRC1 SRC2 XOR temp2 ZERO SRC1 OR DST SRC1 SRC2 ADDU
    temp2 temp2 DST XOR IP -1 load-immediate temp temp IP XOR
    temp temp temp2 AND temp2 temp 31 EXTI ;
:: sub-overflow ( DST SRC1 SRC2 -- )
    temp SRC1 SRC2 XOR temp2 ZERO SRC1 OR DST SRC1 SRC2 SUBU
    temp2 temp2 DST XOR temp temp temp2 AND temp2 temp 31 EXTI ;
:: overflow-branch ( label cc -- )
    cc cc/o eq? [ temp -1 load-immediate temp2 temp2 temp XOR ] when
    label temp2 branch-bit ;
M:: m88k %fixnum-add ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 add-overflow label cc overflow-branch ;
M:: m88k %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 sub-overflow label cc overflow-branch ;

! Exact 32x32 product from unsigned16-bit limbs. Intermediates u and v
! fit32 bits; subtracting signed corrections yields the signed high word.
! R30 is free in Factor, whose frame pointer is R31; native entry saves it.
:: mul-overflow ( DST SRC1 SRC2 -- )
    temp ZERO SRC1 OR temp2 ZERO SRC2 OR
    IP temp 16 0 EXTUW PIC-TAIL temp2 16 0 EXTUW
    NATIVE-STACK IP PIC-TAIL MUL
    R30 temp 16 EXTUI R30 R30 PIC-TAIL MUL
    PIC-TAIL NATIVE-STACK 16 EXTUI R30 R30 PIC-TAIL ADDU
    PIC-TAIL temp2 16 EXTUI IP IP PIC-TAIL MUL
    PIC-TAIL R30 16 0 EXTUW IP IP PIC-TAIL ADDU
    PIC-TAIL temp 16 EXTUI DST temp2 16 EXTUI DST DST PIC-TAIL MUL
    PIC-TAIL R30 16 EXTUI DST DST PIC-TAIL ADDU
    PIC-TAIL IP 16 EXTUI DST DST PIC-TAIL ADDU
    PIC-TAIL temp 31 EXTI PIC-TAIL PIC-TAIL temp2 AND DST DST PIC-TAIL SUBU
    PIC-TAIL temp2 31 EXTI PIC-TAIL PIC-TAIL temp AND DST DST PIC-TAIL SUBU
    IP IP 16 MAKI NATIVE-STACK NATIVE-STACK 16 0 EXTUW
    NATIVE-STACK IP NATIVE-STACK OR
    PIC-TAIL NATIVE-STACK 31 EXTI temp2 DST PIC-TAIL XOR
    DST ZERO NATIVE-STACK OR temp2 temp2 ZERO CMP temp2 temp2 1 3 EXTUW ;
M:: m88k %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 mul-overflow label cc overflow-branch ;

M: m88k %unbox-alien alien-offset memory-offset LD ;
M:: m88k %unbox-any-c-ptr ( DST SRC -- )
    IP ZERO SRC OR <label> :> end
    temp \ f type-number load-immediate temp2 IP temp cc= compare-bit
    DST 0 load-immediate end temp2 branch-bit
    temp tag-mask get load-immediate temp IP temp AND
    temp2 alien type-number load-immediate temp temp temp2 XOR
    temp2 temp ZERO cc/= compare-bit
    DST IP byte-array-offset add-offset end temp2 branch-bit
    DST IP alien-offset memory-offset LD end resolve-label ;
:: alien-store ( SRC DST n -- ) SRC DST n 4 * alien type-number - memory-offset ST ;
M:: m88k %box-alien ( DST SRC TEMP -- )
    IP ZERO SRC OR <label> :> end
    temp2 IP ZERO cc= compare-bit
    DST \ f type-number load-immediate end temp2 branch-bit
    DST 20 alien TEMP %allot temp2 \ f type-number load-immediate
    temp2 DST 1 alien-store temp2 DST 2 alien-store
    IP DST 3 alien-store IP DST 4 alien-store end resolve-label ;
:: select-integer ( DST SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 CMP cc compare-index temp2 12 BB1
    DST ZERO SRC2 OR 8 BR DST ZERO SRC1 OR ;
M:: m88k %min ( DST SRC1 SRC2 -- ) DST SRC1 SRC2 cc< select-integer ;
M:: m88k %max ( DST SRC1 SRC2 -- ) DST SRC1 SRC2 cc> select-integer ;
M:: m88k %single>double-float ( DST SRC -- )
    temp 0x3f800000 load-immediate DST SRC temp FMUL.DSS ;
M:: m88k %double>single-float ( DST SRC -- )
    temp 0x3f800000 load-immediate DST SRC temp FMUL.SDS ;
M: m88k enable-cpu-features enable-alien-4-intrinsics enable-float-intrinsics ;
M:: m88k %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    NATIVE-STACK BASE int-rep %copy PIC-TAIL DISP int-rep %copy
    <label> :> end <label> :> not-f <label> :> not-alien
    DST ZERO NATIVE-STACK OR temp2 PIC-TAIL ZERO cc= compare-bit end temp2 branch-bit
    DST 20 alien TEMP %allot temp2 \ f type-number load-immediate temp2 DST 2 alien-store
    temp \ f type-number load-immediate temp2 NATIVE-STACK temp cc/= compare-bit not-f temp2 branch-bit
    temp2 \ f type-number load-immediate temp2 DST 1 alien-store
    PIC-TAIL DST 3 alien-store PIC-TAIL DST 4 alien-store end %jump-label
    not-f resolve-label temp tag-mask get load-immediate temp NATIVE-STACK temp AND
    temp2 alien type-number load-immediate temp temp temp2 XOR
    temp2 temp ZERO cc/= compare-bit not-alien temp2 branch-bit
    temp2 NATIVE-STACK 4 alien type-number - memory-offset LD temp2 DST 1 alien-store
    temp2 NATIVE-STACK 8 alien type-number - memory-offset LD temp2 DST 2 alien-store
    temp2 NATIVE-STACK 12 alien type-number - memory-offset LD temp2 temp2 PIC-TAIL ADDU temp2 DST 3 alien-store
    temp2 NATIVE-STACK 16 alien type-number - memory-offset LD temp2 temp2 PIC-TAIL ADDU temp2 DST 4 alien-store end %jump-label
    not-alien resolve-label NATIVE-STACK DST 1 alien-store PIC-TAIL DST 3 alien-store
    temp2 NATIVE-STACK PIC-TAIL ADDU temp2 temp2 byte-array-offset add-offset temp2 DST 4 alien-store end resolve-label ;
