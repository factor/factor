! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types arrays assocs classes.algebra classes.struct combinators
compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.intrinsics
compiler.cfg.registers compiler.cfg.rpo compiler.cfg.utilities compiler.cfg.stack-frame compiler.codegen.gc-maps
compiler.codegen.labels compiler.codegen.relocation compiler.constants
cpu.architecture cpu.vax.abi cpu.vax.assembler cpu.vax.assembler.registers endian kernel layouts
locals make math math.bitwise math.order memory namespaces sequences
system vm ;
IN: cpu.vax

UNION: integer-rep int-rep tagged-rep ;

! Native callees preserve R2..R11 through their entry masks. Mapped native
! calls spill live R0/R1 values through the common clobber pipeline.
! R10:R11 contains IEEE bits, never native F/D floating operands.
M: vax.32 machine-registers
    { { int-regs { 0 1 2 3 } } { float-regs { 10 } } } ;
M: vax.32 frame-reg SP ;
M: vax.32 vm-stack-space 16 ;
M: vax.32 complex-addressing? f ;

:: FLD ( DST BASE offset -- ) BASE offset MEM DST R MOVQ ;
:: FSD ( SRC BASE offset -- ) SRC R BASE offset MEM MOVQ ;

M: vax.32 %load-immediate LI ;
M: vax.32 %prologue 4 - neg SP SP rot add-offset ;
M: vax.32 %epilogue 4 - SP SP rot add-offset ;
M: vax.32 %return RSB ;
M: vax.32 stack-frame-size (stack-frame-size) 16 + 16 align ;

M:: vax.32 %load-reference ( DST value -- )
    value [ literal-prefix value rc-absolute-cell rel-literal DST R % ]
    [ DST \ f type-number LI ] if ;
M: vax.32 %call 0 JSB rc-absolute-cell rel-word-pic ;
M: vax.32 %jump
    literal-prefix 7 rc-absolute-cell rel-here temp2 R %
    0 JMP rc-absolute-cell rel-word-pic-tail ;
: jump-label ( label -- ) 0 JMP rc-absolute-cell label-fixup ;
M: vax.32 %jump-label jump-label ;
M:: vax.32 %add ( DST SRC1 SRC2 -- ) SRC1 R SRC2 R DST R ADDL3 ;
M:: vax.32 %sub ( DST SRC1 SRC2 -- ) SRC2 R SRC1 R DST R SUBL3 ;
M:: vax.32 %mul ( DST SRC1 SRC2 -- ) SRC1 R SRC2 R DST R MULL3 ;
M:: vax.32 %or ( DST SRC1 SRC2 -- ) SRC1 R SRC2 R DST R BISL3 ;
M:: vax.32 %xor ( DST SRC1 SRC2 -- ) SRC1 R SRC2 R DST R XORL3 ;
M:: vax.32 %and ( DST SRC1 SRC2 -- )
    SRC2 R temp R MCOML temp R SRC1 R DST R BICL3 ;
M: vax.32 %add-imm add-offset ;
M: vax.32 %sub-imm neg add-offset ;
M:: vax.32 %mul-imm ( DST SRC value -- )
    value immediate-operand SRC R DST R MULL3 ;
M:: vax.32 %or-imm ( DST SRC value -- )
    value immediate-operand SRC R DST R BISL3 ;
M:: vax.32 %xor-imm ( DST SRC value -- )
    value immediate-operand SRC R DST R XORL3 ;
M:: vax.32 %and-imm ( DST SRC value -- )
    value bitnot 32 bits immediate-operand SRC R DST R BICL3 ;
M:: vax.32 %not ( DST SRC -- ) SRC R DST R MCOML ;
M:: vax.32 %neg ( DST SRC -- ) SRC R DST R MNEGL ;

: load-rep ( DST BASE offset rep -- )
    { { int-rep [ LW ] } { tagged-rep [ LW ] }
      { float-rep [ LW ] } { double-rep [ FLD ] } } case ;
: store-rep ( SRC BASE offset rep -- )
    { { int-rep [ SW ] } { tagged-rep [ SW ] }
      { float-rep [ SW ] } { double-rep [ FSD ] } } case ;
:: copy-register ( DST SRC rep -- )
    DST SRC = [ ] [ rep double-rep =
        [ SRC R DST R MOVQ ] [ DST SRC MV ] if ] if ;
M:: vax.32 %copy ( DST SRC rep -- )
    DST SRC eq? [ ] [ DST spill-slot? [
        SRC spill-slot? [
            0 SP SRC n>> spill-offset rep load-rep
            0 SP DST n>> spill-offset rep store-rep
        ] [ SRC SP DST n>> spill-offset rep store-rep ] if
    ] [ SRC spill-slot? [ DST SP SRC n>> spill-offset rep load-rep ]
        [ DST SRC rep copy-register ] if ] if ] if ;
M: vax.32 %spill -rot %copy ;
M: vax.32 %reload swap %copy ;
M: vax.32 %vm-field [ VM ] dip LW ;
M: vax.32 %set-vm-field [ VM ] dip SW ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> 4 * neg ] bi ;
M: vax.32 %peek loc>address LW ;
M: vax.32 %replace loc>address SW ;
M: vax.32 %inc [ ds-loc? DS RS ? dup ] [ n>> 4 * ] bi add-offset ;
:: condition-code ( cc -- opcode )
    cc dup cc-o eq? [ drop 0x1d ] [ dup cc/o eq? [ drop 0x1c ] [ order-cc {
        { cc< [ 0x19 ] } { cc<= [ 0x15 ] } { cc> [ 0x14 ] }
        { cc>= [ 0x18 ] } { cc= [ 0x13 ] } { cc/= [ 0x12 ] }
        { t [ 0 ] } { f [ 1 ] }
    } case ] if ] if ;
:: branch ( label opcode -- )
    opcode { { 0 [ label jump-label ] } { 1 [ ] }
        [ 6 swap 1 bitxor branch-byte label jump-label ] } case ;
M:: vax.32 %compare-branch ( label SRC1 SRC2 cc -- )
    SRC1 R SRC2 R CMPL label cc condition-code branch ;
M:: vax.32 %compare-integer-imm-branch ( label SRC value cc -- )
    SRC R value immediate-operand CMPL label cc condition-code branch ;
M:: vax.32 %fixnum-add ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 %add label cc condition-code branch ;
M:: vax.32 %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 %sub label cc condition-code branch ;
M:: vax.32 %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 %mul label cc condition-code branch ;

M:: vax.32 %shl ( DST SRC count -- )
    <label> :> large <label> :> end
    count R 32 LITERAL CMPL large 0x1e branch
    count R SRC R DST R ASHL end jump-label
    large resolve-label DST 0 LI end resolve-label ;
M:: vax.32 %sar ( DST SRC count -- )
    <label> :> large <label> :> end
    count R 32 LITERAL CMPL large 0x1e branch
    count R temp R MNEGL temp R SRC R DST R ASHL end jump-label
    large resolve-label -31 IMM.B SRC R DST R ASHL end resolve-label ;
M:: vax.32 %shr ( DST SRC count -- )
    <label> :> large <label> :> end
    count R 32 LITERAL CMPL large 0x1e branch
    count R 32 LITERAL temp R SUBL3
    count R temp R SRC R DST R EXTZV end jump-label
    large resolve-label DST 0 LI end resolve-label ;

M:: vax.32 %shl-imm ( DST SRC count -- )
    count IMM.B SRC R DST R ASHL ;
M:: vax.32 %sar-imm ( DST SRC count -- )
    count neg IMM.B SRC R DST R ASHL ;
M:: vax.32 %shr-imm ( DST SRC count -- )
    count LITERAL 32 count - LITERAL SRC R DST R EXTZV ;

M:: vax.32 %replace-imm ( value loc -- )
    temp value [ tag-fixnum ] [ \ f type-number ] if* LI temp loc %replace ;
M: vax.32 %clear [ 297 ] dip %replace-imm ;
M: vax.32 gc-root-offset n>> spill-offset 4 + 4 /i ;
:: boolean-result ( DST cc -- )
    <label> :> end <label> :> false-label
    false-label cc negate-cc condition-code branch
    DST t %load-reference end jump-label
    false-label resolve-label DST \ f type-number LI end resolve-label ;
M:: vax.32 %compare ( DST SRC1 SRC2 cc TEMP -- )
    SRC1 R SRC2 R CMPL DST cc boolean-result ;
M:: vax.32 %compare-integer-imm ( DST SRC value cc TEMP -- )
    SRC R value immediate-operand CMPL DST cc boolean-result ;
M: vax.32 %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M: vax.32 %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;
M:: vax.32 %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset LW
    temp2 DST size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset SW
    temp class type-number tag-header LI temp DST 0 SW
    class type-number immediate-operand DST R DST R BISL3 ;
M: vax.32 %unbox-alien alien-offset LW ;
M:: vax.32 %alien-global ( DST symbol library -- )
    literal-prefix symbol library rc-absolute-cell rel-dlsym DST R % ;
M:: vax.32 %save-context ( TEMP1 TEMP2 -- )
    ! A native-call bridge supplies the synthetic return cell at SP-4.
    TEMP1 SP -4 add-offset
    TEMP1 CTX context-callstack-top-offset SW
    DS CTX context-datastack-offset SW
    RS CTX context-retainstack-offset SW ;

! Internal literal bytes are IEEE even on a compiler running on VAX.
! Alien <ref> would instead produce native F/D representation there.
: single-literal ( value -- bytes ) float>bits 4 >le ;
: double-literal ( value -- bytes ) double>bits 8 >le ;
M:: vax.32 %load-float ( DST value -- )
    literal-prefix value single-literal rc-absolute-cell rel-binary-literal
    temp R % DST temp 0 LW ;
M:: vax.32 %load-double ( DST value -- )
    literal-prefix value double-literal rc-absolute-cell rel-binary-literal
    temp R % DST temp 0 FLD ;

:: native-call-gate ( gc-map bytes quot: ( -- ) -- )
    bytes 4 align :> argument-bytes
    <label> :> continuation
    ! The anchor identifies the Factor continuation and its GC map. The
    ! native bridge returns through this word after code compaction repairs it.
    0 IMM.L PUSHL continuation rc-absolute-cell label-fixup
    SP CTX context-callstack-top-offset SW
    DS CTX context-datastack-offset SW
    RS CTX context-retainstack-offset SW
    temp SP 4 add-offset
    argument-bytes 4 /i <iota> <reversed>
    [ 4 * temp swap MEM PUSHL ] each
    argument-bytes 4 /i immediate-operand PUSHL
    quot call( -- )
    0 JSB "vax_native_call_bridge" f rc-absolute-cell rel-dlsym
    continuation resolve-label gc-map gc-map-here ;

:: native-call ( symbol library gc-map bytes -- )
    gc-map bytes [ literal-prefix symbol library rc-absolute-cell rel-dlsym temp2 R % ]
    native-call-gate ;

! Register destinations receive a complete longword, including sign extension.
M:: vax.32 %convert-integer ( DST SRC c-type -- )
    c-type heap-size {
        { 1 [ SRC R DST R c-type c-type-signed [ CVTBL ] [ MOVZBL ] if ] }
        { 2 [ SRC R DST R c-type c-type-signed [ CVTWL ] [ MOVZWL ] if ] }
        { 4 [ DST SRC MV ] }
    } case ;

! The VM boxing bridge accepts integer IEEE bits. Native float/double helpers
! are reserved for the boundary to foreign memory and foreign procedures.
: ieee-boxing-helper ( name -- name' )
    {
        { "to_float" [ "vax_to_ieee_float" ] }
        { "to_double" [ "vax_to_ieee_double" ] }
        { "from_float" [ "vax_from_ieee_float" ] }
        { "from_double" [ "vax_from_ieee_double" ] }
        [ ]
    } case ;

M:: vax.32 %unbox ( DST SRC func rep -- )
    temp SRC tagged-rep %copy temp SP 0 SW VM SP 4 SW
    func ieee-boxing-helper f f 8 native-call
    DST 0 rep %copy ;
M:: vax.32 %box ( DST SRC func rep gc-map -- )
    rep integer-rep? temp 10 ? :> scratch
    scratch SRC rep %copy scratch SP 0 rep store-rep
    VM SP rep rep-size SW
    func ieee-boxing-helper f gc-map rep rep-size 4 + native-call
    DST 0 tagged-rep %copy ;
M:: vax.32 %unbox-long-long ( DST1 DST2 SRC func -- )
    temp SRC tagged-rep %copy temp SP 0 SW VM SP 4 SW
    func f f 8 native-call
    temp 0 MV DST2 1 int-rep %copy DST1 temp int-rep %copy ;
M:: vax.32 %box-long-long ( DST SRC1 SRC2 func gc-map -- )
    temp SRC1 int-rep %copy temp SP 0 SW
    temp SRC2 int-rep %copy temp SP 4 SW VM SP 8 SW
    func f gc-map 12 native-call DST 0 tagged-rep %copy ;

! Preserve generic instructions on other CPUs. The VAX hidden native ABI
! participates in GC liveness before register allocation, including error paths.
GENERIC: lower-vax-native-insn ( insn -- )
M: insn lower-vax-native-insn , ;

:: emit-vax-helper ( dst src helper rep src-rep vm? -- )
    dst src helper rep src-rep vm? <gc-map> ##native-helper, ;

M:: ##unbox lower-vax-native-insn ( insn -- )
    insn dst>> insn src>> insn unboxer>> ieee-boxing-helper
    insn rep>> tagged-rep t emit-vax-helper ;

M:: ##single>double-float lower-vax-native-insn ( insn -- )
    insn dst>> insn src>> "vax_ieee_single_to_double"
    double-rep float-rep f emit-vax-helper ;
M:: ##double>single-float lower-vax-native-insn ( insn -- )
    insn dst>> insn src>> "vax_ieee_double_to_single"
    float-rep double-rep f emit-vax-helper ;

UNION: vax-load-memory-insn ##load-memory ##load-memory-imm ;
UNION: vax-store-memory-insn ##store-memory ##store-memory-imm ;

:: native-float-memory? ( insn -- ? )
    insn c-type>> insn rep>> { float-rep double-rep } member? and ;

M:: vax-load-memory-insn lower-vax-native-insn ( insn -- )
    insn native-float-memory? [
        insn rep>> :> rep
        rep next-vreg-rep :> bits
        insn clone bits >>dst f >>c-type ,
        insn dst>> bits rep float-rep =
        [ "vax_native_float_to_ieee" ] [ "vax_native_double_to_ieee" ] if
        rep rep t emit-vax-helper
    ] [ insn , ] if ;
M:: vax-store-memory-insn lower-vax-native-insn ( insn -- )
    insn native-float-memory? [
        insn rep>> :> rep
        rep next-vreg-rep :> bits
        bits insn src>> rep float-rep =
        [ "vax_ieee_float_to_native" ] [ "vax_ieee_double_to_native" ] if
        rep rep t emit-vax-helper
        insn clone bits >>src f >>c-type ,
    ] [ insn , ] if ;

M: vax.32 lower-native-helpers
    [ [ [ lower-vax-native-insn ] each ] V{ } make ] simple-optimization ;

M:: vax.32 %native-helper ( DST SRC helper rep src-rep vm? gc-map -- )
    src-rep integer-rep? temp 10 ? :> scratch
    scratch SRC src-rep %copy
    scratch SP 0 src-rep store-rep
    src-rep rep-size :> bytes
    vm? [ VM SP bytes SW ] when
    helper f gc-map bytes vm? [ 4 + ] when native-call
    DST 0 rep %copy ;

! These instructions move raw bits. Native F/D conversion lives in the
! separately mapped helper instruction, so addresses remain ordinary SSA uses.
:: raw-load-memory ( DST BASE offset rep c-type -- )
    rep integer-rep? [
        c-type [ c-type heap-size ] [ 4 ] if :> width
        c-type [ c-type c-type-signed ] [ t ] if :> signed?
        width {
            { 1 [ BASE offset MEM DST R signed? [ CVTBL ] [ MOVZBL ] if ] }
            { 2 [ BASE offset MEM DST R signed? [ CVTWL ] [ MOVZWL ] if ] }
            { 4 [ DST BASE offset LW ] }
        } case
    ] [ DST BASE offset rep load-rep ] if ;
:: raw-store-memory ( SRC BASE offset rep c-type -- )
    rep integer-rep? [
        c-type [ c-type heap-size ] [ 4 ] if {
            { 1 [ SRC R BASE offset MEM MOVB ] }
            { 2 [ SRC R BASE offset MEM MOVW ] }
            { 4 [ SRC BASE offset SW ] }
        } case
    ] [ SRC BASE offset rep store-rep ] if ;
M: vax.32 %load-memory-imm raw-load-memory ;
M: vax.32 %store-memory-imm raw-store-memory ;
M:: vax.32 %load-memory ( DST BASE DISP scale offset rep c-type -- )
    temp2 DISP scale %shl-imm temp2 BASE temp2 %add
    DST temp2 offset rep c-type raw-load-memory ;
M:: vax.32 %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    temp2 DISP scale %shl-imm temp2 BASE temp2 %add
    SRC temp2 offset rep c-type raw-store-memory ;

M:: ##unbox-long-long lower-vax-native-insn ( insn -- )
    insn dst1>> insn dst2>> insn src>> insn unboxer>>
    <gc-map> ##native-helper-long-long, ;
M:: vax.32 %native-helper-long-long ( DST1 DST2 SRC helper gc-map -- )
    temp SRC tagged-rep %copy temp SP 0 SW VM SP 4 SW
    helper f gc-map 8 native-call
    temp 0 MV DST2 1 int-rep %copy DST1 temp int-rep %copy ;

M:: vax.32 %local-allot ( DST size align offset -- )
    DST SP offset local-allot-offset add-offset ;
M: vax.32 %call-gc \ minor-gc %call gc-map-here ;
M: vax.32 %safepoint 0 ABS CLRL rc-absolute-cell rel-safepoint ;
M: vax.32 test-instruction? t ;

:: indexed-address ( BASE DISP scale tag -- )
    temp2 DISP scale %shl-imm temp2 BASE temp2 %add
    temp2 temp2 tag neg add-offset ;
M:: vax.32 %slot ( DST BASE DISP scale tag -- )
    BASE DISP scale tag indexed-address DST temp2 0 LW ;
M: vax.32 %slot-imm slot-offset LW ;
M:: vax.32 %set-slot ( SRC BASE DISP scale tag -- )
    BASE DISP scale tag indexed-address SRC temp2 0 SW ;
M: vax.32 %set-slot-imm slot-offset SW ;

M:: vax.32 %test ( DST SRC1 SRC2 cc TEMP -- )
    SRC1 R SRC2 R BITL DST cc boolean-result ;
M:: vax.32 %test-imm ( DST SRC value cc TEMP -- )
    value immediate-operand SRC R BITL DST cc boolean-result ;
M:: vax.32 %test-branch ( label SRC1 SRC2 cc -- )
    SRC1 R SRC2 R BITL label cc condition-code branch ;
M:: vax.32 %test-imm-branch ( label SRC value cc -- )
    value immediate-operand SRC R BITL label cc condition-code branch ;
:: integer-select ( DST SRC1 SRC2 cc -- )
    <label> :> first <label> :> end
    SRC1 R SRC2 R CMPL first cc condition-code branch
    DST SRC2 MV end jump-label
    first resolve-label DST SRC1 MV end resolve-label ;
M: vax.32 %min cc< integer-select ;
M: vax.32 %max cc> integer-select ;

:: write-barrier ( CARD TEMP -- )
    CARD CARD card-bits %shr-imm
    TEMP VM vm-cards-offset-offset LW TEMP TEMP CARD %add
    card-mark IMM.B TEMP INDIRECT MOVB
    CARD CARD deck-bits card-bits - %shr-imm
    TEMP VM vm-decks-offset-offset LW TEMP TEMP CARD %add
    card-mark IMM.B TEMP INDIRECT MOVB ;
M:: vax.32 %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SLOT scale %shl-imm CARD SRC CARD %add
    CARD CARD tag neg add-offset CARD TEMP write-barrier ;
M:: vax.32 %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot tag slot-offset add-offset CARD TEMP write-barrier ;
M:: vax.32 %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset LW TEMP1 TEMP1 size add-offset
    TEMP2 VM vm-nursery-end-offset LW
    TEMP1 R TEMP2 R CMPL
    label cc cc<= = [ 0x1b ] [ 0x1a ] if branch ;

M:: vax.32 %dispatch ( SRC TEMP -- )
    literal-prefix 10 rc-absolute-cell rel-here TEMP R %
    TEMP SRC TEMP %add TEMP TEMP 0 LW TEMP INDIRECT JMP* ;

! ABI F/D bit conversion is represented before/after the call, so error paths
! have independent maps and values live across either boundary are spilled.
:: boundary-input ( param -- param' )
    param second :> rep
    rep { float-rep double-rep } member? [
        rep next-vreg-rep :> bits
        bits param first rep float-rep =
        [ "vax_ieee_float_to_native" ] [ "vax_ieee_double_to_native" ] if
        rep rep t emit-vax-helper
        param rest bits prefix
    ] [ param ] if ;
:: boundary-output ( param -- param' )
    param second :> rep
    rep { float-rep double-rep } member?
    [ param rest rep next-vreg-rep prefix ] [ param ] if ;
:: boundary-output-helper ( old new -- )
    old second :> rep
    rep { float-rep double-rep } member? [
        old first new first rep float-rep =
        [ "vax_native_float_to_ieee" ] [ "vax_native_double_to_ieee" ] if
        rep rep t emit-vax-helper
    ] when ;
M:: alien-call-insn lower-vax-native-insn ( insn -- )
    insn reg-outputs>> :> old
    old [ boundary-output ] map :> converted
    insn clone
        [ [ boundary-input ] map ] change-reg-inputs
        [ [ boundary-input ] map ] change-stack-inputs
        converted >>reg-outputs ,
    old converted [ boundary-output-helper ] 2each ;
M:: ##callback-inputs lower-vax-native-insn ( insn -- )
    insn reg-outputs>> :> old-reg
    insn stack-outputs>> :> old-stack
    old-reg [ boundary-output ] map :> converted-reg
    old-stack [ boundary-output ] map :> converted-stack
    ##mapped-callback-inputs new
        converted-reg >>reg-outputs converted-stack >>stack-outputs
        <gc-map> >>gc-map ,
    old-reg converted-reg [ boundary-output-helper ] 2each
    old-stack converted-stack [ boundary-output-helper ] 2each ;
M: ##callback-outputs lower-vax-native-insn
    clone [ [ boundary-input ] map ] change-reg-inputs , ;

:: store-stack-param ( vreg rep offset size -- )
    rep integer-rep? temp 10 ? :> scratch
    scratch vreg rep %copy scratch SP offset rep store-rep ;
: store-reg-param ( vreg rep reg -- ) -rot %copy ;
: load-reg-param ( vreg rep reg -- ) swap %copy ;
:: alien-assembly ( reg-inputs stack-inputs reg-outputs quot -- )
    stack-inputs [ first4 store-stack-param ] each
    reg-inputs [ first3 store-reg-param ] each
    quot call( -- )
    reg-outputs [ first3 load-reg-param ] each ;
M:: vax.32 %alien-invoke ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size symbol dll gc-map -- )
    reg-inputs stack-inputs reg-outputs
    [ symbol dll gc-map stack-size native-call ] alien-assembly ;
M:: vax.32 %alien-indirect ( SRC varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size gc-map -- )
    ! R5 is outside the allocator bank and survives native-call's R4 argument
    ! copying. Marshal every stack source before taking the indirect target.
    stack-inputs [ first4 store-stack-param ] each
    temp2 SRC int-rep %copy
    reg-inputs [ first3 store-reg-param ] each
    gc-map stack-size [ ] native-call-gate
    reg-outputs [ first3 load-reg-param ] each ;
M:: vax.32 %alien-assembly ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    reg-inputs stack-inputs reg-outputs quot alien-assembly ;

! AP (R12) belongs to the native callback's entry frame and is restored by
! each nested CALLG/RET. The native gate snapshots hidden R1 separately.
:: load-callback-param ( vreg rep offset size -- )
    rep integer-rep? temp 10 ? :> scratch
    scratch 12 offset 4 + rep load-rep vreg scratch rep %copy ;
:: load-callback-reg-param ( vreg rep reg -- )
    reg 1 = [
        temp CTX context-callstack-save-offset LW
        temp temp 8 LW vreg temp rep %copy
    ] [ vreg rep reg load-reg-param ] if ;
M:: vax.32 %mapped-callback-inputs ( reg-outputs stack-outputs gc-map -- )
    reg-outputs [ first3 load-callback-reg-param ] each
    stack-outputs [ first4 load-callback-param ] each
    VM SP 0 SW temp 0 LI temp SP 4 SW "begin_callback" f gc-map 8 native-call ;
M:: vax.32 %callback-stack ( DST -- ) DST 12 4 add-offset ;
M:: vax.32 %callback-outputs ( reg-inputs -- )
    VM SP 0 SW "end_callback" f f 4 native-call
    reg-inputs [ first3 store-reg-param ] each ;

M: vax.32 fused-unboxing? t ;
M: vax.32 immediate-arithmetic? dup 32 >signed = ;
M: vax.32 immediate-bitwise? dup 32 >signed over = [ drop t ] [ dup 32 bits = ] if ;
M: vax.32 immediate-store? drop f ;
M: vax.32 integer-float-needs-stack-frame? t ;
! Other floating arithmetic stays on software IEEE boxed primitives.
M: vax.32 enable-cpu-features enable-alien-4-intrinsics enable-min/max enable-fsqrt ;

M:: vax.32 %unbox-any-c-ptr ( DST SRC -- )
    <label> :> false-label <label> :> array-label <label> :> end
    SRC R \ f type-number immediate-operand CMPL false-label 0x13 branch
    temp SRC tag-mask get %and-imm
    temp R alien type-number immediate-operand CMPL array-label 0x12 branch
    DST SRC alien-offset LW end jump-label
    array-label resolve-label DST SRC byte-array-offset add-offset end jump-label
    false-label resolve-label DST 0 LI end resolve-label ;
:: alien-store ( SRC DST n -- ) SRC DST n 4 * alien type-number - SW ;
! Local allot does not call C or collect. Snapshot inputs before its
! reserved R4/R5 scratch writes; R0/R1 are ordinary allocator homes.
M:: vax.32 %box-alien ( DST SRC TEMP -- )
    <label> :> false-label <label> :> end
    SRC R TSTL false-label 0x13 branch
    SRC R PUSHL
    DST 20 alien TEMP %allot
    temp SP 0 LW temp DST 3 alien-store temp DST 4 alien-store
    temp \ f type-number LI
    temp DST 1 alien-store temp DST 2 alien-store
    SP SP 4 add-offset end jump-label
    false-label resolve-label DST \ f type-number LI end resolve-label ;
M:: vax.32 %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    BASE R PUSHL DISP R PUSHL
    <label> :> end <label> :> not-f <label> :> not-alien
    temp2 SP 0 LW temp2 R TSTL
    <label> :> allocate
    allocate 0x12 branch DST SP 4 LW end jump-label
    allocate resolve-label DST 20 alien TEMP %allot
    temp \ f type-number LI temp DST 2 alien-store
    temp SP 4 LW
    temp R \ f type-number immediate-operand CMPL not-f 0x12 branch
    temp DST 1 alien-store
    temp2 SP 0 LW temp2 DST 3 alien-store temp2 DST 4 alien-store end jump-label
    not-f resolve-label temp2 temp tag-mask get %and-imm
    temp2 R alien type-number immediate-operand CMPL not-alien 0x12 branch
    temp2 temp 4 alien type-number - LW temp2 DST 1 alien-store
    temp2 temp 8 alien type-number - LW temp2 DST 2 alien-store
    temp2 temp 12 alien type-number - LW
    temp SP 0 LW temp2 temp2 temp %add temp2 DST 3 alien-store
    temp SP 4 LW temp2 temp 16 alien type-number - LW
    temp SP 0 LW temp2 temp2 temp %add temp2 DST 4 alien-store end jump-label
    not-alien resolve-label temp DST 1 alien-store
    temp2 SP 0 LW temp2 DST 3 alien-store
    temp temp temp2 %add temp temp byte-array-offset add-offset temp DST 4 alien-store
    end resolve-label SP SP 8 add-offset ;

! sqrt must remain IEEE even when native D cannot represent its operands.
M:: ##sqrt lower-vax-native-insn ( insn -- )
    insn dst>> insn src>> "vax_ieee_sqrt"
    double-rep double-rep f emit-vax-helper ;
