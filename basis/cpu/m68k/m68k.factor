! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs byte-arrays classes.algebra
classes.struct combinators compiler.cfg compiler.cfg.builder.alien.boxing
compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.intrinsics
compiler.cfg.registers compiler.cfg.stack-frame compiler.codegen.gc-maps
compiler.codegen.labels compiler.codegen.relocation compiler.constants
cpu.architecture cpu.m68k.abi cpu.m68k.assembler generalizations kernel layouts
literals locals math math.bitwise math.order memory namespaces sequences system vm ;
IN: cpu.m68k

! D0..D7 use 0..7; A0..A7 use 8..15. A2/A3 are the Factor
! stacks, A4 the VM, A5 its context. A0/A1 and D4/D5 are scratch;
! D6 is the PIC tail address, and A7 is the hardware call stack.
CONSTANT: SP 15
CONSTANT: DS 10
CONSTANT: RS 11
CONSTANT: VM 12
CONSTANT: CTX 13
CONSTANT: temp 4
CONSTANT: temp2 5
CONSTANT: fp-temp 7
M: m68k.32 machine-registers
    { { int-regs { 0 1 2 3 7 } } { float-regs { 0 1 2 3 4 5 6 } } } ;
M: m68k.32 frame-reg SP ;
M: m68k.32 vm-stack-space 16 ;
M: m68k.32 complex-addressing? f ;

:: MV ( DST SRC -- )
    DST SRC = [ ] [
        DST 8 >= [ SRC 8 >= [ SRC 8 - DST 8 - MOVEAA.L ]
            [ SRC DST 8 - MOVEA.L ] if ]
        [ SRC 8 >= [ SRC 8 - DST MOVEAD.L ] [ SRC DST MOVE.L ] if ] if
    ] if ;
:: LI ( DST value -- )
    DST 8 >= [ value DST 8 - MOVEAI.L ] [
        value -128 127 between? [ value DST MOVEQ ] [ value DST MOVEI.L ] if
    ] if ;
:: add-offset ( DST SRC value -- )
    DST SRC MV DST 8 >= [ value DST 8 - ADDAI.L ] [ value DST ADDI.L ] if ;
:: address ( BASE offset -- an disp )
    BASE 8 >= [ BASE 8 - ] [ BASE 0 MOVEA.L 0 ] if :> an
    offset -32768 32767 between? [ an offset ] [
        an 0 MOVEAA.L offset 0 ADDAI.L 0 0
    ] if ;
:: LW ( DST BASE offset -- )
    BASE offset address :> ( an disp )
    DST 8 >= [ an disp DST 8 - LOADA.L ] [ an disp DST LOAD.L ] if ;
:: SW ( SRC BASE offset -- )
    BASE offset address :> ( an disp )
    SRC 8 >= [ SRC 8 - an disp STOREA.L ] [ SRC an disp STORE.L ] if ;
:: FLD ( DST BASE offset -- ) BASE offset address DST FLOAD.D ;
:: FLW ( DST BASE offset -- ) BASE offset address DST FLOAD.S ;
:: FSD ( SRC BASE offset -- ) SRC BASE offset address FSTORE.D ;
:: FSW ( SRC BASE offset -- ) SRC BASE offset address FSTORE.S ;
:: load-address ( DST -- )
    ! Relocation targets require a four-byte immediate even for initial zero.
    DST 8 >= [ 0 DST 8 - MOVEAI.L ] [ 0 DST MOVEI.L ] if ;
M: m68k.32 %load-immediate LI ;
M: m68k.32 %load-reference
    [ swap load-address rc-absolute-cell rel-literal ]
    [ \ f type-number LI ] if* ;
M:: m68k.32 %load-float ( DST value -- )
    8 load-address value alien.c-types:float <ref> rc-absolute-cell rel-binary-literal
    DST 8 0 FLW ;
M:: m68k.32 %load-double ( DST value -- )
    8 load-address value double <ref> rc-absolute-cell rel-binary-literal
    DST 8 0 FLD ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> cells neg ] bi ;
M: m68k.32 %peek loc>address LW ;
M: m68k.32 %replace loc>address SW ;
M:: m68k.32 %replace-imm ( value loc -- )
    temp value [ tag-fixnum ] [ \ f type-number ] if* LI temp loc %replace ;
M: m68k.32 %clear [ 297 ] dip %replace-imm ;
M: m68k.32 %inc [ ds-loc? DS RS ? dup ] [ n>> cells ] bi add-offset ;
M: m68k.32 stack-frame-size (stack-frame-size) 16 + 16 align ;
M: m68k.32 gc-root-offset n>> spill-offset cell + cell /i ;
M: m68k.32 %call 0 JSR rc-absolute-cell rel-word-pic ;
M: m68k.32 %jump
    6 load-address 6 rc-absolute-cell rel-here
    0 JMP rc-absolute-cell rel-word-pic-tail ;
: jump-label ( label -- ) 0 JMP rc-absolute-cell label-fixup ;
M: m68k.32 %jump-label jump-label ;
M: m68k.32 %return RTS ;
:: branch ( label condition -- )
    condition {
        { 0 [ label jump-label ] } { 1 [ ] }
        [ 8 swap 1 bitxor Bcc label jump-label ]
    } case ;
:: condition-code ( cc -- n )
    cc dup cc-o eq? [ drop 9 ] [ dup cc/o eq? [ drop 8 ] [ order-cc {
        { cc< [ 13 ] } { cc<= [ 15 ] } { cc> [ 14 ] }
        { cc>= [ 12 ] } { cc= [ 7 ] } { cc/= [ 6 ] }
        { t [ 0 ] } { f [ 1 ] }
    } case ] if ] if ;
M:: m68k.32 %dispatch ( SRC TEMP -- )
    TEMP load-address 12 rc-absolute-cell rel-here
    SRC TEMP ADD.L TEMP TEMP 0 LW TEMP 0 MOVEA.L 0 JMPA ;
:: indexed-address ( BASE DISP scale offset -- )
    temp2 DISP MV scale [ 1 temp2 LSL.L ] times
    BASE 0 MOVEA.L temp2 0 ADDA.L offset 0 ADDAI.L ;
M:: m68k.32 %slot ( DST BASE DISP scale tag -- )
    BASE DISP scale tag neg indexed-address DST 8 0 LW ;
M: m68k.32 %slot-imm slot-offset LW ;
M:: m68k.32 %set-slot ( SRC BASE DISP scale tag -- )
    BASE DISP scale tag neg indexed-address SRC 8 0 SW ;
M: m68k.32 %set-slot-imm slot-offset SW ;

:: binary-op ( DST SRC1 SRC2 op -- )
    ! Preserve the second input when the allocator aliases it with dst.
    DST SRC2 = DST SRC1 = not and [ temp2 SRC2 MV temp2 ] [ SRC2 ] if :> rhs
    DST SRC1 MV rhs DST op call( src dst -- ) ; inline
M: m68k.32 %add [ ADD.L ] binary-op ;
M: m68k.32 %sub [ SUB.L ] binary-op ;
M: m68k.32 %mul [ MULS.L ] binary-op ;
M: m68k.32 %and [ AND.L ] binary-op ;
M: m68k.32 %or [ OR.L ] binary-op ;
M: m68k.32 %xor [ XOR.L ] binary-op ;
M: m68k.32 %shl [ LSLR.L ] binary-op ;
M: m68k.32 %shr [ LSRR.L ] binary-op ;
M: m68k.32 %sar [ ASRR.L ] binary-op ;
M: m68k.32 %add-imm add-offset ;
M: m68k.32 %sub-imm neg add-offset ;
:: immediate-op ( DST SRC value op -- )
    DST SRC MV value DST op call( value dst -- ) ; inline
M: m68k.32 %and-imm [ ANDI.L ] immediate-op ;
M: m68k.32 %or-imm [ ORI.L ] immediate-op ;
M: m68k.32 %xor-imm [ XORI.L ] immediate-op ;
M:: m68k.32 %mul-imm ( DST SRC value -- )
    temp value LI DST SRC temp %mul ;
:: shift-imm ( DST SRC count op -- )
    DST SRC MV count [ 1 DST op call( count dst -- ) ] times ; inline
M: m68k.32 %shl-imm [ LSL.L ] shift-imm ;
M: m68k.32 %shr-imm [ LSR.L ] shift-imm ;
M: m68k.32 %sar-imm [ ASR.L ] shift-imm ;
M: m68k.32 %not 2dup MV drop NOT.L ;
M: m68k.32 %neg 2dup MV drop NEG.L ;
M:: m68k.32 %min ( DST SRC1 SRC2 -- )
    <label> :> end <label> :> less
    SRC2 SRC1 CMP.L less 13 branch
    DST SRC2 MV end jump-label less resolve-label DST SRC1 MV end resolve-label ;
M:: m68k.32 %max ( DST SRC1 SRC2 -- )
    <label> :> end <label> :> greater
    SRC2 SRC1 CMP.L greater 14 branch
    DST SRC2 MV end jump-label greater resolve-label DST SRC1 MV end resolve-label ;
M:: m68k.32 %fixnum-add ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 %add label cc condition-code branch ;
M:: m68k.32 %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 %sub label cc condition-code branch ;
M:: m68k.32 %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 %mul label cc condition-code branch ;
:: boolean-result ( DST cc -- )
    <label> :> end
    <label> :> false-label
    false-label cc negate-cc condition-code branch
    DST t %load-reference end jump-label
    false-label resolve-label DST \ f type-number LI end resolve-label ;
M:: m68k.32 %compare ( DST SRC1 SRC2 cc TEMP -- )
    SRC2 SRC1 CMP.L DST cc boolean-result ;
M:: m68k.32 %compare-integer-imm ( DST SRC value cc TEMP -- )
    value SRC CMPI.L DST cc boolean-result ;
M: m68k.32 %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: m68k.32 %compare-branch ( label SRC1 SRC2 cc -- )
    SRC2 SRC1 CMP.L label cc condition-code branch ;
M:: m68k.32 %compare-integer-imm-branch ( label SRC value cc -- )
    value SRC CMPI.L label cc condition-code branch ;
M: m68k.32 %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;

! The 68881 double precision mode rounds the mantissa but keeps the extended
! exponent range. A double store/reload also rounds overflow and underflow.
:: round-double ( reg -- )
    reg SP 0 FSD reg SP 0 FLD ;

:: float-op ( DST SRC1 SRC2 op -- )
    DST SRC2 = DST SRC1 = not and
    [ SRC2 fp-temp FMOVE.X fp-temp ] [ SRC2 ] if :> rhs
    SRC1 DST FMOVE.X rhs DST op call( src dst -- )
    DST round-double ; inline
M: m68k.32 %add-float [ FADD.X ] float-op ;
M: m68k.32 %sub-float [ FSUB.X ] float-op ;
:: exact-float-op ( DST SRC1 SRC2 symbol -- )
    ! The stateless native helper corrects 68881 subnormal double rounding.
    ! Store inputs before touching result registers, including aliased inputs.
    SRC1 SP 0 FSD SRC2 SP 8 FSD
    0 SP 16 SW 1 SP 20 SW
    0 SP 24 FSD 1 SP 32 FSD
    temp temp2 %save-context symbol f f %c-invoke
    temp GET-FPSR 0 fp-temp FMOVE.X
    0 SP 24 FLD 1 SP 32 FLD
    0 SP 16 LW 1 SP 20 LW
    fp-temp DST FMOVE.X temp SET-FPSR ;
M: m68k.32 %mul-float "m68k_float_multiply" exact-float-op ;
M: m68k.32 %div-float "m68k_float_divide" exact-float-op ;
M:: m68k.32 %sqrt ( DST SRC -- )
    SRC DST FSQRT.X DST round-double ;
M: m68k.32 %integer>float swap FMOVE.L ;
M:: m68k.32 %float>integer ( DST SRC -- )
    SRC fp-temp FINTRZ.X fp-temp DST FGET.L ;
M: m68k.32 %single>double-float swap FMOVE.X ;
M:: m68k.32 %double>single-float ( DST SRC -- )
    SRC SP 0 FSW DST SP 0 FLW ;
M: m68k.32 integer-float-needs-stack-frame? f ;
M: m68k.32 float-arithmetic-stack-space 48 ;

UNION: integer-rep int-rep tagged-rep ;
: load-rep ( DST BASE offset rep -- )
    { { int-rep [ LW ] } { tagged-rep [ LW ] }
      { float-rep [ FLW ] } { double-rep [ FLD ] } } case ;
: store-rep ( SRC BASE offset rep -- )
    { { int-rep [ SW ] } { tagged-rep [ SW ] }
      { float-rep [ FSW ] } { double-rep [ FSD ] } } case ;
:: copy-register ( DST SRC rep -- )
    rep integer-rep? [ DST SRC MV ] [ SRC DST FMOVE.X ] if ;
M:: m68k.32 %copy ( DST SRC rep -- )
    DST SRC eq? [ ] [
        DST spill-slot? [
            SRC spill-slot? [
                rep integer-rep? temp2 fp-temp ? :> scratch
                scratch SP SRC n>> spill-offset rep load-rep
                scratch SP DST n>> spill-offset rep store-rep
            ] [ SRC SP DST n>> spill-offset rep store-rep ] if
        ] [
            SRC spill-slot? [ DST SP SRC n>> spill-offset rep load-rep ]
            [ DST SRC rep copy-register ] if
        ] if
    ] if ;
M: m68k.32 %spill -rot %copy ;
M: m68k.32 %reload swap %copy ;
M: m68k.32 %vm-field [ VM ] dip LW ;
M: m68k.32 %set-vm-field [ VM ] dip SW ;
M: m68k.32 %unbox-alien alien-offset LW ;
M:: m68k.32 %alien-global ( DST symbol library -- )
    DST load-address symbol library rc-absolute-cell rel-dlsym ;
M:: m68k.32 %allot ( DST size class TEMP -- )
    DST VM "nursery" vm offset-of LW
    temp2 DST size data-alignment get align add-offset
    temp2 VM "nursery" vm offset-of SW
    temp class type-number tag-header LI temp DST 0 SW
    class type-number DST ORI.L ;
M: m68k.32 %call-gc \ minor-gc %call gc-map-here ;
M: m68k.32 %prologue cell - neg SP SP rot add-offset ;
M: m68k.32 %epilogue cell - SP SP rot add-offset ;
M:: m68k.32 %save-context ( TEMP1 TEMP2 -- )
    TEMP1 SP -4 add-offset TEMP1 CTX "callstack-top" context offset-of SW
    DS CTX "datastack" context offset-of SW
    RS CTX "retainstack" context offset-of SW ;
M:: m68k.32 %c-invoke ( symbol dll gc-map -- )
    0 JSR symbol dll rc-absolute-cell rel-dlsym gc-map gc-map-here ;
M:: m68k.32 %local-allot ( DST size align offset -- )
    DST SP offset local-allot-offset add-offset ;
M: m68k.32 fused-unboxing? t ;
M: m68k.32 immediate-arithmetic? dup 32 >signed = ;
M: m68k.32 immediate-bitwise? dup 32 bits = ;
M: m68k.32 immediate-store? drop f ;

:: float-condition ( cc -- n )
    cc { { cc< [ 4 ] } { cc<= [ 5 ] } { cc> [ 2 ] } { cc>= [ 3 ] }
      { cc= [ 1 ] } { cc<> [ 6 ] } { cc<>= [ 7 ] }
      { cc/< [ 11 ] } { cc/<= [ 10 ] } { cc/> [ 13 ] } { cc/>= [ 12 ] }
      { cc/= [ 14 ] } { cc/<> [ 9 ] } { cc/<>= [ 8 ] } } case ;
:: float-branch ( label condition -- )
    8 condition 15 bitxor FBcc label jump-label ;
:: float-boolean ( DST condition -- )
    <label> :> false-label <label> :> end
    false-label condition 15 bitxor float-branch
    DST t %load-reference end jump-label
    false-label resolve-label DST \ f type-number LI end resolve-label ;
M:: m68k.32 %compare-float-unordered ( DST SRC1 SRC2 cc TEMP -- )
    SRC2 SRC1 FCMP.X DST cc float-condition float-boolean ;
M:: m68k.32 %compare-float-ordered ( DST SRC1 SRC2 cc TEMP -- )
    SRC2 SRC1 FCMP.X DST cc float-condition 16 bitor float-boolean ;
M:: m68k.32 %compare-float-unordered-branch ( label SRC1 SRC2 cc -- )
    SRC2 SRC1 FCMP.X label cc float-condition float-branch ;
M:: m68k.32 %compare-float-ordered-branch ( label SRC1 SRC2 cc -- )
    SRC2 SRC1 FCMP.X label cc float-condition 16 bitor float-branch ;

:: load-memory ( DST BASE offset rep c-type -- )
    c-type rep integer-rep? and [
        BASE offset address :> ( an disp )
        c-type heap-size {
            { 1 [ an disp DST LOAD.B c-type c-type-signed
                [ DST EXTB.L ] [ 255 DST ANDI.L ] if ] }
            { 2 [ an disp DST LOAD.W c-type c-type-signed
                [ DST EXT.L ] [ 65535 DST ANDI.L ] if ] }
            { 4 [ an disp DST LOAD.L ] }
        } case
    ] [ DST BASE offset rep load-rep ] if ;
:: store-memory ( SRC BASE offset rep c-type -- )
    c-type rep integer-rep? and [
        BASE offset address :> ( an disp )
        SRC an disp c-type heap-size {
            { 1 [ STORE.B ] } { 2 [ STORE.W ] } { 4 [ STORE.L ] }
        } case
    ] [ SRC BASE offset rep store-rep ] if ;
M: m68k.32 %load-memory-imm load-memory ;
M: m68k.32 %store-memory-imm store-memory ;
M:: m68k.32 %load-memory ( DST BASE DISP scale offset rep c-type -- )
    BASE DISP scale offset indexed-address DST 8 0 rep c-type load-memory ;
M:: m68k.32 %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    BASE DISP scale offset indexed-address SRC 8 0 rep c-type store-memory ;
M:: m68k.32 %convert-integer ( DST SRC c-type -- )
    DST SRC MV c-type heap-size {
        { 1 [ c-type c-type-signed [ DST EXTB.L ] [ 255 DST ANDI.L ] if ] }
        { 2 [ c-type c-type-signed [ DST EXT.L ] [ 65535 DST ANDI.L ] if ] }
        { 4 [ ] }
    } case ;
M:: m68k.32 %unbox-any-c-ptr ( DST SRC -- )
    <label> :> false-label <label> :> array-label <label> :> end
    \ f type-number SRC CMPI.L false-label 7 branch
    temp SRC MV tag-mask get temp ANDI.L alien type-number temp CMPI.L
    array-label 6 branch DST SRC alien-offset LW end jump-label
    array-label resolve-label DST SRC byte-array-offset add-offset end jump-label
    false-label resolve-label DST 0 LI end resolve-label ;
:: alien-store ( SRC DST n -- ) SRC DST n cells alien type-number - SW ;
M:: m68k.32 %box-alien ( DST SRC TEMP -- )
    <label> :> false-label <label> :> end
    0 SRC CMPI.L false-label 7 branch
    DST 5 cells alien TEMP %allot temp \ f type-number LI
    temp DST 1 alien-store temp DST 2 alien-store
    SRC DST 3 alien-store SRC DST 4 alien-store end jump-label
    false-label resolve-label DST \ f type-number LI end resolve-label ;
M:: m68k.32 %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    <label> :> nonzero <label> :> not-f <label> :> not-alien <label> :> end
    0 DISP CMPI.L nonzero 6 branch DST BASE MV end jump-label
    nonzero resolve-label DST 5 cells alien TEMP %allot
    temp \ f type-number LI temp DST 2 alien-store
    \ f type-number BASE CMPI.L not-f 6 branch
    temp DST 1 alien-store DISP DST 3 alien-store DISP DST 4 alien-store end jump-label
    not-f resolve-label temp BASE MV tag-mask get temp ANDI.L
    alien type-number temp CMPI.L not-alien 6 branch
    temp BASE 1 cells alien type-number - LW temp DST 1 alien-store
    temp BASE 2 cells alien type-number - LW temp DST 2 alien-store
    temp BASE 3 cells alien type-number - LW DISP temp ADD.L temp DST 3 alien-store
    temp BASE 4 cells alien type-number - LW DISP temp ADD.L temp DST 4 alien-store end jump-label
    not-alien resolve-label BASE DST 1 alien-store DISP DST 3 alien-store
    temp BASE DISP %add temp temp byte-array-offset add-offset
    temp DST 4 alien-store end resolve-label ;
:: write-barrier ( CARD TEMP -- )
    CARD CARD card-bits %shr-imm TEMP load-address rc-absolute-cell rel-cards-offset
    TEMP CARD 0 0 indexed-address temp card-mark LI temp 0 0 STORE.B
    CARD CARD deck-bits card-bits - %shr-imm
    TEMP load-address rc-absolute-cell rel-decks-offset
    TEMP CARD 0 0 indexed-address temp card-mark LI temp 0 0 STORE.B ;
M:: m68k.32 %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SLOT scale %shl-imm CARD SRC CARD %add CARD CARD tag neg add-offset
    CARD TEMP write-barrier ;
M:: m68k.32 %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot tag slot-offset add-offset CARD TEMP write-barrier ;
M:: m68k.32 %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM "nursery" vm offset-of LW TEMP1 TEMP1 size add-offset
    TEMP2 VM "nursery" vm offset-of 2 cells + LW
    TEMP1 TEMP2 CMP.L label cc cc<= eq? [ 3 ] [ 2 ] if branch ;
M: m68k.32 %safepoint 0 CLR-ABS.L rc-absolute-cell rel-safepoint ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
: load-reg-param ( vreg rep reg -- ) swap %copy ;
: store-reg-param ( vreg rep reg -- ) -rot %copy ;
:: store-stack-param ( vreg rep offset size -- )
    rep integer-rep? temp fp-temp ? :> scratch
    scratch vreg rep %copy scratch SP offset rep store-rep ;
M:: m68k.32 %unbox ( DST SRC func rep -- )
    temp SRC tagged-rep %copy temp SP 0 SW VM SP 4 SW
    func f f %c-invoke DST rep rep return-reg load-reg-param ;
M:: m68k.32 %box ( DST SRC func rep gc-map -- )
    SRC rep 0 rep rep-size store-stack-param
    VM SP rep rep-size SW func f gc-map %c-invoke DST 0 tagged-rep %copy ;
M:: m68k.32 %unbox-long-long ( DST1 DST2 SRC func -- )
    temp SRC tagged-rep %copy temp SP 0 SW VM SP 4 SW
    func f f %c-invoke temp 0 MV DST2 1 int-rep %copy DST1 temp int-rep %copy ;
M:: m68k.32 %box-long-long ( DST SRC1 SRC2 func gc-map -- )
    SRC1 int-rep 0 4 store-stack-param SRC2 int-rep 4 4 store-stack-param
    VM SP 8 SW func f gc-map %c-invoke DST 0 tagged-rep %copy ;
M: m68k.32 %alien-assembly
    3nip swap {
        [ [ first3 store-reg-param ] each ]
        [ [ first4 store-stack-param ] each ]
        [ call( -- ) ]
        [ [ first3 load-reg-param ] each ]
    } spread drop ;
M: m68k.32 %alien-invoke '[ _ _ _ %c-invoke ] %alien-assembly ;
M:: m68k.32 %alien-indirect ( SRC varargs? reg-inputs stack-inputs
                            reg-outputs dead-outputs cleanup stack-size gc-map -- )
    varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size [
        8 SRC int-rep %copy 0 JSRA gc-map gc-map-here
    ] %alien-assembly ;
:: load-stack-param ( vreg rep offset size -- )
    rep integer-rep? temp fp-temp ? :> scratch
    scratch 14 offset 4 + rep load-rep vreg scratch rep %copy ;
:: load-callback-reg-param ( vreg rep reg -- )
    ! The entry stub snapshots hidden result pointers before new_context,
    ! whose native call is allowed to clobber A0/A1.
    reg 8 = reg 9 = or [
        temp 14 reg 9 = -4 -8 ? LW vreg temp rep %copy
    ] [ vreg rep reg load-reg-param ] if ;
M: m68k.32 %callback-inputs
    [ [ first3 load-callback-reg-param ] each ] [ [ first4 load-stack-param ] each ] bi*
    VM SP 0 SW temp 0 LI temp SP 4 SW "begin_callback" f f %c-invoke ;
M: m68k.32 %callback-stack 14 4 add-offset ;
M: m68k.32 %callback-outputs
    VM SP 0 SW "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;

M:: m68k.32 %bit-count ( DST SRC -- )
    ! Parallel population count over one complete 32-bit cell.
    DST SRC MV temp DST MV 1 temp LSR.L 0x55555555 temp ANDI.L temp DST SUB.L
    temp DST MV 2 temp LSR.L 0x33333333 temp ANDI.L
    0x33333333 DST ANDI.L temp DST ADD.L
    temp DST MV 4 temp LSR.L temp DST ADD.L 0x0f0f0f0f DST ANDI.L
    temp DST MV 8 temp LSR.L temp DST ADD.L
    temp DST MV 8 temp LSR.L 8 temp LSR.L temp DST ADD.L
    63 DST ANDI.L ;
M:: m68k.32 %min-float ( DST SRC1 SRC2 -- )
    <label> :> first <label> :> end
    SRC2 SRC1 FCMP.X first 20 float-branch
    SRC2 DST FMOVE.X end jump-label first resolve-label
    SRC1 DST FMOVE.X end resolve-label ;
M:: m68k.32 %max-float ( DST SRC1 SRC2 -- )
    <label> :> first <label> :> end
    SRC2 SRC1 FCMP.X first 18 float-branch
    SRC2 DST FMOVE.X end jump-label first resolve-label
    SRC1 DST FMOVE.X end resolve-label ;

M: m68k.32 enable-cpu-features
    enable-float-intrinsics enable-fsqrt enable-min/max
    enable-float-min/max enable-bit-count ;
