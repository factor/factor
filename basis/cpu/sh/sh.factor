! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs byte-arrays
classes.algebra classes.struct combinators fry compiler.cfg compiler.cfg.comparisons
compiler.cfg.instructions compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture cpu.sh.abi cpu.sh.assembler
cpu.sh.codegen generalizations kernel layouts literals locals math math.bitwise
math.order memory namespaces sequences system vm ;
IN: cpu.sh

! R0/R1 are integer scratches; R7 forms memory addresses. Native callee-saved
! R8..R15 carry the Factor stacks, VM, safepoint, PIC and frame pointers.
M: sh3 machine-registers { { int-regs { 2 3 4 5 6 } } { float-regs { } } } ;
M: sh4 machine-registers
    { { int-regs { 2 3 4 5 6 } } { float-regs { 2 4 6 8 10 } } } ;
M: sh frame-reg FP ;
M: sh4be.32 big-endian-cpu? t ;
M: sh3be.32 big-endian-cpu? t ;
M: sh vm-stack-space 32 ;
M: sh complex-addressing? f ;
M: sh gc-root-offset n>> spill-offset 16 + 4 /i ;
M: sh %load-immediate LI ;
M: sh %load-reference
    [ swap load-address rc-absolute-cell rel-literal ]
    [ \ f type-number LI ] if* ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> 4 * neg ] bi ;
M: sh %peek loc>address LW ;
M: sh %replace loc>address SW ;
M:: sh %replace-imm ( value loc -- )
    temp2 value [ tag-fixnum ] [ \ f type-number ] if* LI temp2 loc %replace ;
M: sh %clear [ 297 ] dip %replace-imm ;
M: sh %inc [ ds-loc? DS RS ? dup ] [ n>> 4 * ] bi add-offset ;
M: sh stack-frame-size (stack-frame-size) 16 + 16 align ;
M: sh %call CALL rc-absolute-cell rel-word-pic ;
M: sh %jump
    PIC-TAIL load-address 6 rc-absolute-cell rel-here
    JUMP rc-absolute-cell rel-word-pic-tail ;
: jump-label ( label -- ) JUMP rc-absolute-cell label-fixup ;
M: sh %jump-label jump-label ;
M: sh %return RETURN ;
! Far branches use a relocated literal jump. The short inverse branch skips
! the actual emitted jump length, including alignment and its delay slot.
:: branch-t ( label sense -- )
    compiled-offset 2 + 3 bitand zero? 0 2 ?
    call-literal-size + 2 + sense [ BF ] [ BT ] if label jump-label ;
:: compare-t ( src1 src2 cc -- sense )
    cc order-cc {
        { cc= [ src2 src1 CMP/EQ t ] }
        { cc/= [ src2 src1 CMP/EQ f ] }
        { cc< [ src1 src2 CMP/GT t ] }
        { cc<= [ src1 src2 CMP/GE t ] }
        { cc> [ src2 src1 CMP/GT t ] }
        { cc>= [ src2 src1 CMP/GE t ] }
    } case ;
:: boolean-result ( dst sense -- )
    <label> :> yes <label> :> end
    yes sense branch-t dst \ f type-number LI end jump-label
    yes resolve-label dst t %load-reference end resolve-label ;
M:: sh %compare ( dst src1 src2 cc scratch -- )
    src1 src2 cc compare-t dst swap boolean-result ;
M:: sh %compare-integer-imm ( dst src value cc scratch -- )
    temp2 value LI src temp2 cc compare-t dst swap boolean-result ;
M: sh %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: sh %compare-branch ( label src1 src2 cc -- )
    src1 src2 cc compare-t label swap branch-t ;
M:: sh %compare-integer-imm-branch ( label src value cc -- )
    temp2 value LI src temp2 cc compare-t label swap branch-t ;
M: sh %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;
M: sh %add [ ADD ] binary-op ;
M: sh %sub [ SUB ] binary-op ;
M: sh %and [ AND ] binary-op ;
M: sh %or [ OR ] binary-op ;
M: sh %xor [ XOR ] binary-op ;
M:: sh %mul ( dst src1 src2 -- ) src2 src1 MUL.L dst STS-MACL ;
M: sh %add-imm add-offset ;
M: sh %sub-imm neg add-offset ;
M: sh %and-imm [ %and ] immediate-op ;
M: sh %or-imm [ %or ] immediate-op ;
M: sh %xor-imm [ %xor ] immediate-op ;
M: sh %mul-imm [ %mul ] immediate-op ;
M: sh %shl f sh-shift ;
M:: sh %shr ( dst src count -- ) count temp2 NEG dst src temp2 f sh-shift ;
M:: sh %sar ( dst src count -- ) count temp2 NEG dst src temp2 t sh-shift ;
M: sh %shl-imm f sh-shift-immediate ;
M: sh %shr-imm neg f sh-shift-immediate ;
M: sh %sar-imm neg t sh-shift-immediate ;
M: sh %not swap NOT ;
M: sh %neg swap NEG ;
:: indexed-address ( base disp scale offset -- )
    temp2 disp scale f sh-shift-immediate
    base temp2 ADD temp temp2 offset add-offset ;
M:: sh %slot ( dst base disp scale tag -- )
    base disp scale tag neg indexed-address dst temp 0 LW ;
M: sh %slot-imm slot-offset LW ;
M:: sh %set-slot ( src base disp scale tag -- )
    base disp scale tag neg indexed-address src temp 0 SW ;
M: sh %set-slot-imm slot-offset SW ;
M:: sh %prologue ( size -- )
    SP SP -16 add-offset FP SP 0 SW temp STS-PR temp SP 4 SW FP SP MV
    SP SP size 16 - neg add-offset ;
M:: sh %epilogue ( size -- )
    ! Large callback frames must preserve the native result in R0/R1.
    size 16 - :> adjustment
    adjustment -128 127 between? [
        SP SP adjustment add-offset
    ] [ 7 adjustment LI 7 SP ADD ] if
    linked-epilog ;
M:: sh %save-context ( scratch1 scratch2 -- )
    scratch1 VM "ctx" vm offset-of LW
    FP scratch1 "callstack-top" context offset-of SW
    DS scratch1 "datastack" context offset-of SW
    RS scratch1 "retainstack" context offset-of SW ;
M: sh %vm-field [ VM ] dip LW ;
M: sh %set-vm-field [ VM ] dip SW ;
M: sh %unbox-alien alien-offset LW ;
M:: sh %alien-global ( dst symbol library -- )
    dst load-address symbol library rc-absolute-cell rel-dlsym ;
M:: sh %local-allot ( dst size alignment offset -- )
    dst SP offset local-allot-offset add-offset ;
: sh-gc-map-here ( gc-map -- )
    ! PR follows JSR's delay slot, before the inline pool-skipping branch.
    extra-offset get call-literal-size 3 2 * - - extra-offset
    [ gc-map-here ] with-variable ;
M: sh %call-gc \ minor-gc %call sh-gc-map-here ;
M: sh %safepoint SAFEPOINT SAFEPOINT 0 SW ;
M: sh fused-unboxing? t ;
M: sh immediate-arithmetic? dup 32 >signed = ;
M: sh immediate-bitwise? dup 32 bits = ;
M: sh immediate-store? drop f ;
M: sh enable-cpu-features ;

! Classic FSCHG is illegal with PR=1. Keep SZ=0 and move two single
! lanes instead. In little-endian memory the low word occupies the odd FR.
:: FMV ( dst src -- )
    dst src = [ ] [ src dst FMOV src 1 + dst 1 + FMOV ] if ;
:: FLD ( dst base offset -- )
    base offset address :> addr
    sh-big-endian? get 0 1 ? :> lane
    addr dst lane + FMOV.LOAD
    7 addr 4 add-offset 7 dst 1 lane - + FMOV.LOAD ;
:: FSD ( src base offset -- )
    base offset address :> addr
    sh-big-endian? get 0 1 ? :> lane
    src lane + addr FMOV.STORE
    7 addr 4 add-offset src 1 lane - + 7 FMOV.STORE ;
:: FLW ( dst base offset -- ) base offset address dst FMOV.LOAD ;
:: FSW ( src base offset -- ) base offset address :> addr src addr FMOV.STORE ;
M:: sh4 %load-float ( dst value -- )
    temp load-address value alien.c-types:float <ref> rc-absolute-cell rel-binary-literal
    dst temp 0 FLW ;
M:: sh4 %load-double ( dst value -- )
    temp load-address value double <ref> rc-absolute-cell rel-binary-literal
    dst temp 0 FLD ;
! FR12/FR14 are reserved native temporaries. Ordinary register values remain
! canonical IEEE data; FPUL transfers do not perform floating arithmetic.
! The adapter uses only R0/R1, preserving live native R2 and R4..R7 arguments.
:: sh-float-copy ( dst src rep -- )
    rep double-rep? [ dst src FMV ] [ src dst FMOV ] if ;
:: sh-read-float-word ( reg fp -- ) fp FLDS reg STS-FPUL ;
:: sh-write-float-word ( fp reg -- ) reg LDS-FPUL fp FSTS ;
:: sh-fraction-bits ( src double? -- )
    0 src sh-read-float-word
    1 double? 12 9 ? LI 1 0 SHLD
    double? [ 1 src 1 + sh-read-float-word 1 0 OR ] when ;
:: sh-nan-branch ( label src double? -- )
    ! Jump for a non-NaN, leaving the source's stored representation intact.
    0 src sh-read-float-word 1 0 MV
    0 double? -20 -23 ? LI 0 1 SHLD
    0 double? 0x7ff 0xff ? LI 0 1 AND 0 1 CMP/EQ label f branch-t
    src double? sh-fraction-bits 0 0 TST label t branch-t ;
:: sh-convert-nan ( dst src rep native? -- )
    <label> :> end rep double-rep? :> double?
    dst src rep sh-float-copy end dst double? sh-nan-branch
    0 dst sh-read-float-word 1 double? 0x80000 0x400000 ? LI
    1 0 XOR dst 0 sh-write-float-word
    dst double? sh-fraction-bits 0 0 TST end f branch-t
    native? [
        0 dst sh-read-float-word 1 double? 0x40000 0x200000 ? LI
        1 0 OR dst 0 sh-write-float-word
    ] [
        double? dst 1 + dst ? :> lane
        0 lane sh-read-float-word 1 1 LI 1 0 OR lane 0 sh-write-float-word
    ] if end resolve-label ;
:: float-op ( dst src1 src2 op -- )
    12 src1 double-rep t sh-convert-nan
    14 src2 double-rep t sh-convert-nan
    dst 12 FMV 14 dst op call( src dst -- )
    dst dst double-rep f sh-convert-nan ; inline
M: sh4 %add-float [ FADD ] float-op ;
M: sh4 %sub-float [ FSUB ] float-op ;
M: sh4 %mul-float [ FMUL ] float-op ;
M: sh4 %div-float [ FDIV ] float-op ;
:: sh-sqrt ( dst src -- )
    12 src double-rep t sh-convert-nan 12 FSQRT
    dst 12 double-rep f sh-convert-nan ;
M: sh4 %sqrt sh-sqrt ;
M:: sh4 %integer>float ( dst src -- ) src LDS-FPUL dst FLOAT ;
:: sh-float>integer ( dst src -- )
    12 src double-rep t sh-convert-nan 12 FTRC dst STS-FPUL ;
M: sh4 %float>integer sh-float>integer ;
:: sh-single>double ( dst src -- )
    <label> :> finite <label> :> end
    14 src float-rep sh-float-copy finite 14 f sh-nan-branch
    0 14 sh-read-float-word 1 -3 LI 1 0 SHLD
    1 0xfffff LI 1 0 AND
    12 0 sh-write-float-word
    0 14 sh-read-float-word 1 0x80000000 LI 1 0 AND
    1 12 sh-read-float-word 1 0 OR
    1 0x7ff00000 LI 1 0 OR dst 0 sh-write-float-word
    0 14 sh-read-float-word 1 29 LI 1 0 SHLD
    dst 1 + 0 sh-write-float-word end jump-label
    finite resolve-label 14 FLDS dst FCNVSD end resolve-label ;
:: sh-double>single ( dst src -- )
    <label> :> finite <label> :> payload <label> :> end
    14 src FMV finite 14 t sh-nan-branch
    0 14 sh-read-float-word 1 3 LI 1 0 SHLD
    12 0 sh-write-float-word
    0 15 sh-read-float-word 1 -29 LI 1 0 SHLD
    1 12 sh-read-float-word 1 0 OR
    1 0x7fffff LI 1 0 AND
    12 0 sh-write-float-word
    0 0 TST payload f branch-t
    0 1 LI 12 0 sh-write-float-word payload resolve-label
    0 14 sh-read-float-word 1 0x80000000 LI 1 0 AND
    1 12 sh-read-float-word 1 0 OR
    1 0x7f800000 LI 1 0 OR dst 0 sh-write-float-word end jump-label
    finite resolve-label 14 FCNVDS dst FSTS end resolve-label ;
M: sh4 %single>double-float sh-single>double ;
M: sh4 %double>single-float sh-double>single ;
M:: sh4 %integer>scalar ( dst src rep -- ) src LDS-FPUL dst FSTS ;
M:: sh4 %scalar>integer ( dst src rep -- ) src FLDS dst STS-FPUL ;
M: sh integer-float-needs-stack-frame? f ;
UNION: integer-rep int-rep tagged-rep ;
: load-rep ( dst base offset rep -- )
    { { int-rep [ LW ] } { tagged-rep [ LW ] }
      { float-rep [ FLW ] } { double-rep [ FLD ] } } case ;
: store-rep ( src base offset rep -- )
    { { int-rep [ SW ] } { tagged-rep [ SW ] }
      { float-rep [ FSW ] } { double-rep [ FSD ] } } case ;
:: copy-register ( dst src rep -- )
    rep integer-rep? [ dst src MV ] [
        rep double-rep? [ dst src FMV ] [ src dst FMOV ] if
    ] if ;
M:: sh %copy ( dst src rep -- )
    dst rep abi-register :> dst
    src rep abi-register :> src
    dst src = [ ] [
        dst spill-slot? [
            src spill-slot? [
                rep integer-rep? temp2 0 ? :> scratch
                scratch SP src n>> spill-offset rep load-rep
                scratch SP dst n>> spill-offset rep store-rep
            ] [ src SP dst n>> spill-offset rep store-rep ] if
        ] [
            src spill-slot? [ dst SP src n>> spill-offset rep load-rep ]
            [ dst src rep copy-register ] if
        ] if
    ] if ;
M: sh %spill -rot %copy ;
M: sh %reload swap %copy ;
:: load-memory ( dst base offset rep c-type -- )
    c-type rep integer-rep? and [
        base offset address :> addr
        c-type heap-size {
            { 1 [ addr dst MOV.B c-type c-type-signed [ ] [ dst dst EXTU.B ] if ] }
            { 2 [ addr dst MOV.W c-type c-type-signed [ ] [ dst dst EXTU.W ] if ] }
            { 4 [ addr dst MOV.L ] }
        } case
    ] [
        dst base offset rep load-rep
        c-type rep { float-rep double-rep } member? and [
            dst dst rep f sh-convert-nan
        ] when
    ] if ;
:: store-memory ( src base offset rep c-type -- )
    c-type rep integer-rep? and [
        base offset address :> addr src addr c-type heap-size {
            { 1 [ STORE.B ] } { 2 [ STORE.W ] } { 4 [ STORE.L ] }
        } case
    ] [
        c-type rep { float-rep double-rep } member? and [
            12 src rep t sh-convert-nan 12 base offset rep store-rep
        ] [ src base offset rep store-rep ] if
    ] if ;
M: sh %load-memory-imm load-memory ;
M: sh %store-memory-imm store-memory ;
M:: sh %load-memory ( dst base disp scale offset rep c-type -- )
    base disp scale offset indexed-address dst temp 0 rep c-type load-memory ;
M:: sh %store-memory ( src base disp scale offset rep c-type -- )
    c-type rep { float-rep double-rep } member? and [
        12 src rep t sh-convert-nan
        base disp scale offset indexed-address 12 temp 0 rep f store-memory
    ] [
        base disp scale offset indexed-address src temp 0 rep c-type store-memory
    ] if ;
M:: sh %convert-integer ( dst src c-type -- )
    dst src MV c-type heap-size {
        { 1 [ dst dst c-type c-type-signed [ EXTS.B ] [ EXTU.B ] if ] }
        { 2 [ dst dst c-type c-type-signed [ EXTS.W ] [ EXTU.W ] if ] }
        { 4 [ ] }
    } case ;
M:: sh %allot ( dst size class scratch -- )
    dst VM "nursery" vm offset-of LW
    temp2 dst size data-alignment get align add-offset
    temp2 VM "nursery" vm offset-of SW
    temp class type-number tag-header LI temp dst 0 SW
    dst dst class type-number %or-imm ;
M:: sh %check-nursery-branch ( label size cc scratch1 scratch2 -- )
    scratch1 VM "nursery" vm offset-of LW scratch1 scratch1 size add-offset
    scratch2 VM "nursery" vm offset-of 8 + LW
    scratch1 scratch2 CMP/HS label cc cc<= eq? branch-t ;
:: write-barrier ( card scratch -- )
    card card card-bits %shr-imm scratch load-address rc-absolute-cell rel-cards-offset
    temp2 card MV scratch temp2 ADD temp card-mark LI temp temp2 0 int-rep char store-memory
    card card deck-bits card-bits - %shr-imm
    scratch load-address rc-absolute-cell rel-decks-offset card scratch ADD
    temp card-mark LI temp scratch 0 int-rep char store-memory ;
M:: sh %write-barrier ( src slot scale tag card scratch -- )
    card slot scale %shl-imm card src card %add card card tag neg add-offset
    card scratch write-barrier ;
M:: sh %write-barrier-imm ( src slot tag card scratch -- )
    card src slot tag slot-offset add-offset card scratch write-barrier ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
! Native argument GPRs may already be live. FP spill loads therefore form
! their address in R0, instead of the general R7 memory scratch.
:: sh-fp-source ( dst src rep -- )
    src spill-slot? [
        0 SP src n>> spill-offset add-offset
        rep double-rep? [
            0 dst sh-big-endian? get 0 1 ? + FMOV.LOAD
            0 0 4 add-offset 0 dst sh-big-endian? get 1 0 ? + FMOV.LOAD
        ] [ 0 dst FMOV.LOAD ] if
    ] [ dst src rep %copy ] if ;
:: load-reg-param ( vreg rep reg -- )
    rep integer-rep? reg native-float-register? or [ vreg reg rep %copy ] [
        0 reg rep %copy 0 0 rep f sh-convert-nan vreg 0 rep %copy
    ] if ;
:: store-reg-param ( vreg rep reg -- )
    rep integer-rep? reg native-float-register? or [ reg vreg rep %copy ] [
        0 vreg rep sh-fp-source 0 0 rep t sh-convert-nan reg 0 rep %copy
    ] if ;
:: store-native-stack-param ( vreg rep offset size native? -- )
    rep integer-rep? [ temp2 vreg rep %copy temp2 SP offset rep store-rep ] [
        0 vreg rep sh-fp-source native? [ ] [ 0 0 rep t sh-convert-nan ] if
        0 SP offset rep store-rep
    ] if ;
: store-stack-param ( vreg rep offset size -- ) f store-native-stack-param ;
:: store-stack-param-array ( param -- )
    param first4 param length 4 > [ 4 param nth ] [ f ] if store-native-stack-param ;
M:: sh %c-invoke ( symbol library gc-map -- )
    temp2 load-address symbol library rc-absolute-cell rel-dlsym
    CALL rc-absolute-cell rel-trampoline gc-map sh-gc-map-here ;
:: stack-call-gc-map ( gc-map size -- gc-map' )
    gc-map dup gc-map-needed? [
        [ clone [ size - ] change-n ] :> shift-slot
        clone [ shift-slot map ] change-gc-roots
        [ [ shift-slot bi@ ] assoc-map ] change-derived-roots
    ] when ;
:: c-invoke-stack ( size symbol library gc-map -- )
    3 SP size 16 - add-offset
    temp2 load-address symbol library rc-absolute-cell rel-dlsym
    CALL rc-absolute-cell rel-trampoline2 gc-map size stack-call-gc-map sh-gc-map-here ;
M: sh %alien-assembly
    3nip swap [ swap ] 2dip {
        [ [ store-stack-param-array ] each ]
        [ [ first3 store-reg-param ] each ]
        [ call( -- ) ]
        [ [ first3 load-reg-param ] each ]
    } spread drop ;
M: sh %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ] [ -roll '[ _ _ _ _ c-invoke-stack ] ]
    if-zero %alien-assembly ;
! Outgoing R4..R7 are already live here. Form a large spill address in
! the callee register itself, rather than the ordinary R7 address scratch.
:: load-indirect-callee ( src -- )
    src spill-slot? [
        temp2 SP src n>> spill-offset add-offset temp2 temp2 0 LW
    ] [ temp2 src int-rep %copy ] if ;
:: c-indirect ( size src gc-map -- )
    size zero? [
        src load-indirect-callee CALL rc-absolute-cell rel-trampoline
        gc-map sh-gc-map-here
    ] [
        3 SP size 16 - add-offset src load-indirect-callee
        CALL rc-absolute-cell rel-trampoline2 gc-map size stack-call-gc-map sh-gc-map-here
    ] if ;
M: sh %alien-indirect
    [ 8 nrot ] dip pick [ '[ 0 _ _ c-indirect ] ]
    [ -rot '[ _ _ _ c-indirect ] ] if-zero %alien-assembly ;
M:: sh %unbox ( dst src func rep -- )
    4 src tagged-rep %copy 5 VM MV func f f %c-invoke
    dst rep rep return-reg load-reg-param ;
M:: sh %box ( dst src func rep gc-map -- )
    rep integer-rep? [ 4 src rep %copy 5 VM MV ] [
        src rep 4 <abi-float-register> store-reg-param 4 VM MV
    ] if func f gc-map %c-invoke dst 0 tagged-rep %copy ;
M:: sh %unbox-long-long ( dst1 dst2 src func -- )
    4 src tagged-rep %copy 5 VM MV func f f %c-invoke
    ! Spilling the high word can use R0 to form a large stack address.
    PIC-TAIL 0 MV dst2 1 int-rep %copy dst1 PIC-TAIL int-rep %copy ;
M:: sh %box-long-long ( dst src1 src2 func gc-map -- )
    temp2 src1 int-rep %copy 5 src2 int-rep %copy 4 temp2 MV 6 VM MV
    func f gc-map %c-invoke dst 0 tagged-rep %copy ;
:: load-native-stack-param ( vreg rep offset size native? -- )
    temp CTX "callstack-save" context offset-of LW
    rep integer-rep? temp2 0 ? :> scratch
    scratch temp offset 112 + rep load-rep
    rep integer-rep? native? or [ ] [ scratch scratch rep f sh-convert-nan ] if
    vreg scratch rep %copy ;
: load-stack-param ( vreg rep offset size -- ) f load-native-stack-param ;
:: load-stack-param-array ( param -- )
    param first4 param length 4 > [ 4 param nth ] [ f ] if load-native-stack-param ;
:: load-callback-reg-param ( vreg rep reg -- )
    temp CTX "callstack-save" context offset-of LW
    rep integer-rep? [
        temp2 temp reg 2 = 0 reg 4 - 4 * 4 + ? LW
        vreg temp2 rep %copy
    ] [
        reg rep abi-register :> physical
        0 temp physical 4 - 4 * 20 + FLW
        rep double-rep? [ 1 temp physical 4 - 4 * 24 + FLW ] when
        reg native-float-register? [ ] [ 0 0 rep f sh-convert-nan ] if
        vreg 0 rep %copy
    ] if ;
M: sh %callback-inputs
    [ [ first3 load-callback-reg-param ] each ] [ [ load-stack-param-array ] each ] bi*
    4 VM MV 5 0 LI "begin_callback" f f %c-invoke ;
M: sh %callback-stack
    dup CTX "callstack-save" context offset-of LW dup 112 add-offset ;
M: sh %callback-outputs
    4 VM MV "end_callback" f f %c-invoke [ first3 store-reg-param ] each ;

M:: sh %dispatch ( src scratch -- )
    <label> :> table temp load-address table rc-absolute-cell label-fixup
    src temp ADD temp temp 0 LW temp JMP NOP
    cpu.sh.codegen:align-code table resolve-label ;
M:: sh %fixnum-add ( label dst src1 src2 cc -- )
    dst src1 src2 [ ADDV ] binary-op label cc cc-o eq? branch-t ;
M:: sh %fixnum-sub ( label dst src1 src2 cc -- )
    dst src1 src2 [ SUBV ] binary-op label cc cc-o eq? branch-t ;
:: multiply-t ( dst src1 src2 -- )
    src2 src1 DMULS.L dst STS-MACL 7 STS-MACH
    temp2 dst -31 t sh-shift-immediate 7 temp2 CMP/EQ ;
M:: sh %fixnum-mul ( label dst src1 src2 cc -- )
    dst src1 src2 multiply-t label cc cc/o eq? branch-t ;
M:: sh %unbox-any-c-ptr ( dst src -- )
    7 src MV <label> :> false-label <label> :> array-label <label> :> end
    temp \ f type-number LI temp 7 CMP/EQ false-label t branch-t
    temp2 7 MV temp tag-mask get LI temp temp2 AND
    temp alien type-number LI temp temp2 CMP/EQ array-label f branch-t
    dst 7 alien-offset LW end jump-label
    array-label resolve-label dst 7 byte-array-offset add-offset end jump-label
    false-label resolve-label dst 0 LI end resolve-label ;
:: alien-store ( src dst n -- ) src dst n 4 * alien type-number - SW ;
M:: sh %box-alien ( dst src scratch -- )
    scratch src MV <label> :> false-label <label> :> end
    temp 0 LI temp scratch CMP/EQ false-label t branch-t
    dst 20 alien scratch %allot temp \ f type-number LI
    temp dst 1 alien-store temp dst 2 alien-store
    scratch dst 3 alien-store scratch dst 4 alien-store end jump-label
    false-label resolve-label dst \ f type-number LI end resolve-label ;
M:: sh %box-displaced-alien ( dst disp base scratch base-class -- )
    PIC-TAIL base MV scratch disp MV
    <label> :> nonzero <label> :> not-f <label> :> not-alien <label> :> end
    temp 0 LI temp scratch CMP/EQ nonzero f branch-t
    dst PIC-TAIL MV end jump-label
    nonzero resolve-label dst 20 alien scratch %allot
    temp \ f type-number LI temp dst 2 alien-store
    temp PIC-TAIL CMP/EQ not-f f branch-t
    temp dst 1 alien-store scratch dst 3 alien-store scratch dst 4 alien-store end jump-label
    not-f resolve-label temp PIC-TAIL MV temp2 tag-mask get LI temp2 temp AND
    temp2 alien type-number LI temp2 temp CMP/EQ not-alien f branch-t
    temp PIC-TAIL 4 alien type-number - LW temp dst 1 alien-store
    temp PIC-TAIL 8 alien type-number - LW temp dst 2 alien-store
    temp PIC-TAIL 12 alien type-number - LW scratch temp ADD temp dst 3 alien-store
    temp PIC-TAIL 16 alien type-number - LW scratch temp ADD temp dst 4 alien-store end jump-label
    not-alien resolve-label PIC-TAIL dst 1 alien-store scratch dst 3 alien-store
    temp PIC-TAIL MV scratch temp ADD temp temp byte-array-offset add-offset
    temp dst 4 alien-store end resolve-label ;

:: ordered-float-bit ( dst src1 src2 cc -- )
    cc order-cc {
        { cc< [ src1 src2 FCMP/GT dst MOVT ] }
        { cc> [ src2 src1 FCMP/GT dst MOVT ] }
        { cc= [ src2 src1 FCMP/EQ dst MOVT ] }
        { cc/= [ src2 src1 FCMP/EQ dst MOVT dst dst 1 %xor-imm ] }
        { cc<= [ src1 src2 FCMP/GT dst MOVT
                  src2 src1 FCMP/EQ temp2 MOVT temp2 dst OR ] }
        { cc>= [ src2 src1 FCMP/GT dst MOVT
                  src2 src1 FCMP/EQ temp2 MOVT temp2 dst OR ] }
        { t [ dst 1 LI ] } { f [ dst 0 LI ] }
    } case ;
:: sh-raise-invalid ( -- )
    0 0 LI 0 LDS-FPUL 12 FLOAT 14 12 FMV 14 12 FDIV ;
:: sh-check-nan ( src seen ordered? -- )
    <label> :> end end src t sh-nan-branch
    seen 1 LI
    ordered? [ sh-raise-invalid ] [
        0 src sh-read-float-word 1 0x80000 LI 1 0 AND
        0 0 TST end f branch-t sh-raise-invalid
    ] if end resolve-label ;
:: sh-float-bit ( dst src1 src2 cc ordered? -- )
    <label> :> finite <label> :> end
    dst 0 LI src1 dst ordered? sh-check-nan src2 dst ordered? sh-check-nan
    0 0 LI 0 dst CMP/EQ finite t branch-t
    dst cc { cc/< cc/<= cc/> cc/>= cc/= cc/<> cc/<>= } member? 1 0 ? LI
    end jump-label finite resolve-label dst src1 src2 cc ordered-float-bit
    end resolve-label ;
: float-bit ( dst src1 src2 cc -- ) t sh-float-bit ;
:: sh-compare-float ( dst src1 src2 cc ordered? -- )
    7 src1 src2 cc ordered? sh-float-bit
    temp 0 LI temp 7 CMP/EQ dst f boolean-result ;
M:: sh4 %compare-float-ordered ( dst src1 src2 cc scratch -- )
    dst src1 src2 cc t sh-compare-float ;
M:: sh4 %compare-float-unordered ( dst src1 src2 cc scratch -- )
    dst src1 src2 cc f sh-compare-float ;
:: sh-compare-float-branch ( label src1 src2 cc ordered? -- )
    7 src1 src2 cc ordered? sh-float-bit temp 0 LI temp 7 CMP/EQ label f branch-t ;
M: sh4 %compare-float-ordered-branch t sh-compare-float-branch ;
M: sh4 %compare-float-unordered-branch f sh-compare-float-branch ;
M: sh4 enable-cpu-features
    ! Four-byte loads can exceed an SH fixnum and require primitive boxing.
    enable-float-intrinsics enable-fsqrt ;
