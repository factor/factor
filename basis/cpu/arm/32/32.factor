! Copyright (C) 2020, 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data arrays assocs combinators compiler.cfg
compiler.cfg.builder.alien.boxing compiler.cfg.intrinsics compiler.cfg.comparisons compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stack-frame
compiler.codegen.gc-maps compiler.codegen.labels compiler.codegen.relocation
compiler.constants cpu.architecture cpu.arm cpu.arm.32.assembler
cpu.arm.64.abi cpu.arm.32.assembler.registers cpu.arm.32.compiler-assembler cpu.arm.32.abi generalizations generic kernel
layouts literals locals math math.bitwise memory namespaces sequences system ;
FROM: cpu.arm.32.assembler => B ;
IN: cpu.arm.32

M: arm.32 machine-registers
    { { int-regs ${ R0 R1 R2 R3 } }
      { float-regs ${ D0 D1 D2 D3 D4 D5 D6 D7 } } } ;
M: arm.32 ds-reg DS ;
M: arm.32 rs-reg RS ;
M: arm.32 frame-reg FP ;
M: arm.32 vm-stack-space 16 ;
M: arm.32 gc-root-offset n>> spill-offset 16 + 4 /i ;
! Code-block headers encode frame sizes in multiples of 16.
M: arm.32 stack-frame-size (stack-frame-size) 16 + 16 align ;

M: arm.32 %load-immediate LI ;
M: arm.32 %load-reference
    [ swap load-address rel-literal ] [ \ f type-number MOV ] if* ;

:: memory-offset ( base offset -- base operand )
    offset abs 4096 < [ base offset dup 0 < [ neg <-> ] [ <+> ] if ]
    [ temp offset LI base temp <+> ] if ;
:: %add-offset ( dst src offset -- )
    temp offset LI dst src temp ADD ;
: loc>operand ( loc -- base operand )
    [ ds-loc? DS RS ? ] [ n>> cells neg ] bi memory-offset ;
M: arm.32 %peek loc>operand LDR ;
M: arm.32 %replace loc>operand STR ;
M:: arm.32 %replace-imm ( value loc -- )
    temp value [ tag-fixnum ] [ \ f type-number ] if* LI
    temp loc %replace ;
M: arm.32 %clear [ 297 ] dip %replace-imm ;
M: arm.32 %inc
    [ ds-loc? DS RS ? dup ] [ n>> cells ] bi %add-offset ;

M: arm.32 %call call-address rel-word-pic ;
M: arm.32 %jump
    PIC-TAIL PC 4 ADD jump-address rel-word-pic-tail ;
M: arm.32 %jump-label 0 B rc-relative-arm-b label-fixup ;
M: arm.32 %return LR BX ;
M: arm.32 %prologue
    SP SP 8 SUB ${ FP LR } PUSH FP SP MOV
    16 - [ neg SP dup rot %add-offset ] unless-zero ;
M: arm.32 %epilogue
    16 - [ SP dup rot %add-offset ] unless-zero
    ${ FP LR } POP SP SP 8 ADD ;
M: arm.32 %safepoint SAFEPOINT SAFEPOINT 0 <+> STR ;

M: arm.32 %slot 2drop <+> LDR ;
M: arm.32 %slot-imm slot-offset memory-offset LDR ;
M: arm.32 %set-slot 2drop <+> STR ;
M: arm.32 %set-slot-imm slot-offset memory-offset STR ;
M: arm.32 %add S ADD ;
M: arm.32 %sub S SUB ;
M: arm.32 %mul MUL ;
M:: arm.32 %mul-imm ( dst src imm -- ) temp imm LI dst src temp MUL ;
M: arm.32 %and AND ;
M: arm.32 %or ORR ;
M: arm.32 %xor EOR ;
M:: arm.32 %add-imm ( dst src imm -- ) temp imm LI dst src temp S ADD ;
M:: arm.32 %sub-imm ( dst src imm -- ) temp imm LI dst src temp S SUB ;
M:: arm.32 %and-imm ( dst src imm -- ) temp imm LI dst src temp AND ;
M:: arm.32 %or-imm ( dst src imm -- ) temp imm LI dst src temp ORR ;
M:: arm.32 %xor-imm ( dst src imm -- ) temp imm LI dst src temp EOR ;
M: arm.32 %shl <LSL> MOV ;
M: arm.32 %shl-imm <LSL> MOV ;
M: arm.32 %shr <LSR> MOV ;
M: arm.32 %shr-imm dup zero? [ drop MOV ] [ <LSR> MOV ] if ;
M: arm.32 %sar <ASR> MOV ;
M: arm.32 %sar-imm dup zero? [ drop MOV ] [ <ASR> MOV ] if ;
M: arm.32 %not MVN ;
M: arm.32 %neg 0 RSB ;

M: arm.32 %add-float VADD ;
M: arm.32 %sub-float VSUB ;
M: arm.32 %mul-float VMUL ;
M: arm.32 %div-float VDIV ;
M: arm.32 %sqrt VSQRT ;
M: arm.32 %single>double-float >S VCVT-F64-F32 ;
M: arm.32 %double>single-float [ >S ] dip VCVT-F32-F64 ;
M:: arm.32 %integer>float ( dst src -- )
    S30 src VMOV-TO-S dst S30 VCVT-F64-S32 ;
M:: arm.32 %float>integer ( dst src -- )
    S30 src VCVT-S32-F64 dst S30 VMOV-FROM-S ;

:: fp-memory-offset ( base offset -- base' offset' )
    offset abs 1024 < offset 4 mod zero? and [ base offset ]
    [ temp base offset %add-offset temp 0 ] if ;
M:: arm.32 %load-double ( dst value -- )
    temp load-address value double <ref> swap rel-binary-literal dst temp 0 VLDR ;
M:: arm.32 %load-float ( dst value -- )
    temp load-address value alien.c-types:float <ref> swap rel-binary-literal dst >S temp 0 VLDR ;

:: %copy-integer ( dst src -- )
    dst spill-slot? [
        src SP dst n>> spill-offset memory-offset STR
    ] [ src spill-slot?
        [ dst SP src n>> spill-offset memory-offset LDR ]
        [ dst src MOV ] if
    ] if ;
:: %copy-float ( dst src rep -- )
    rep float-rep? :> single?
    dst spill-slot? [
        src single? [ >S ] [ >D ] if
        SP dst n>> spill-offset fp-memory-offset VSTR
    ] [ src spill-slot? [
        dst single? [ >S ] [ >D ] if
        SP src n>> spill-offset fp-memory-offset VLDR
    ] [
        single? [ dst >S src >S ] [ dst >D src >D ] if VMOV
    ] if ] if ;
M:: arm.32 %copy ( dst src rep -- )
    dst src = [ ] [ rep reg-class-of int-regs eq?
        [ dst src %copy-integer ] [ dst src rep %copy-float ] if
    ] if ;
M: arm.32 %spill -rot %copy ;
M: arm.32 %reload swap %copy ;

M: arm.32 immediate-arithmetic? drop t ;
M: arm.32 immediate-bitwise? drop t ;
M: arm.32 immediate-comparand? drop t ;
M: arm.32 immediate-store? drop f ;
M: arm.32 complex-addressing? f ;
M: arm.32 integer-float-needs-stack-frame? f ;
M: arm.32 fused-unboxing? f ;
M: arm.32 enable-cpu-features
    ! Vocab loading has a temporary namespace; later compilation needs these defaults.
    t emit-bytecode? set-global t have-BX? set-global t have-BLX? set-global
    enable-float-intrinsics enable-fsqrt enable-float-min/max
    enable-min/max enable-log2 enable-bit-count enable-bit-test ;

M: arm.32 %vm-field [ VM ] dip memory-offset LDR ;
M: arm.32 %set-vm-field [ VM ] dip memory-offset STR ;
M:: arm.32 %save-context ( scratch1 scratch2 -- )
    FP CTX context-callstack-top-offset memory-offset STR
    DS CTX context-datastack-offset memory-offset STR
    RS CTX context-retainstack-offset memory-offset STR ;
M:: arm.32 %local-allot ( dst size align offset -- )
    dst SP offset local-allot-offset %add-offset ;
M:: arm.32 %c-invoke ( symbols dll gc-map -- )
    IP load-address symbols dll rot rel-dlsym
    TRAMPOLINE BLX gc-map gc-map-here ;

: arm-cc ( cc -- )
    order-cc {
        { cc< [ LT ] } { cc<= [ LE ] } { cc> [ GT ] }
        { cc>= [ GE ] } { cc= [ EQ ] } { cc/= [ NE ] }
    } case ;
:: branch-label ( label cc -- )
    cc arm-cc 0 B label rc-relative-arm-b label-fixup ;
:: %boolean ( dst cc -- )
    dst \ f type-number MOV
    cc arm-cc dst temp MOV ;
M:: arm.32 %compare ( dst src1 src2 cc scratch -- )
    temp load-address \ t swap rel-literal
    src1 src2 CMP dst cc %boolean ;
M:: arm.32 %compare-integer-imm ( dst src imm cc scratch -- )
    temp imm LI src temp CMP
    temp load-address \ t swap rel-literal dst cc %boolean ;
M:: arm.32 %compare-branch ( label src1 src2 cc -- )
    src1 src2 CMP label cc branch-label ;
M:: arm.32 %compare-integer-imm-branch ( label src imm cc -- )
    temp imm LI src temp CMP label cc branch-label ;
M:: arm.32 %allot ( dst size class scratch -- )
    dst VM vm-nursery-here-offset memory-offset LDR
    temp dst size data-alignment get align %add-offset
    temp VM vm-nursery-here-offset memory-offset STR
    temp class type-number tag-header LI
    temp dst 0 <+> STR dst dst class type-number ADD ;
M:: arm.32 %check-nursery-branch ( label size cc scratch1 scratch2 -- )
    scratch1 VM vm-nursery-here-offset memory-offset LDR
    scratch1 scratch1 size %add-offset
    scratch2 VM vm-nursery-end-offset memory-offset LDR
    scratch1 scratch2 CMP label cc branch-label ;
! The inline Factor call returns to its branch, before the target literal.
M: arm.32 %call-gc
    \ minor-gc %call
    extra-offset get 8 - extra-offset [ gc-map-here ] with-variable ;

M: arm.32 return-regs
    { { int-regs ${ R0 R1 } } { float-regs ${ S0 S1 S2 S3 } } } ;
M: arm.32 param-regs
    drop { { int-regs ${ R0 R1 R2 R3 } }
           { float-regs ${ S0 S1 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 S12 S13 S14 S15 } } } ;
M: arm.32 dummy-stack-params? f ;
M: arm.32 dummy-int-params? f ;
M: arm.32 dummy-fp-params? f ;
M: arm.32 float-right-align-on-stack? f ;
M: arm.32 struct-return-on-stack? f ;
M: arm.32 long-long-on-stack? f ;
M: arm.32 long-long-odd-register? f ;
M: arm.32 long-long-even-register? t ;
M: arm.32 value-struct? drop t ;
: arm-hfa-members ( type -- members/f )
    lookup-c-type homogeneous-aggregate-members dup [
        dup [ third dup float-rep? swap double-rep? or ] all?
        [ ] [ drop f ] if
    ] when ;
M: arm.32 return-struct-in-registers?
    arm32-base-aapcs? get [ heap-size 4 <= ]
    [ [ heap-size 4 <= ] [ arm-hfa-members >boolean ] bi or ] if ;

:: mark-hfa-reps ( reps -- reps' )
    reps [| rep i |
        rep f f rep rep-size 4array i zero? reps length 0 ? suffix
    ] map-index ;
:: mark-core-struct-reps ( reps align -- reps' )
    reps [| rep i |
        rep first rep second i zero? align 8 >= and
        rep first rep-size 4array i zero? reps length 0 ? suffix
    ] map-index ;
M: arm.32 flatten-struct-type
    dup c-type-align [
        arm32-base-aapcs? get [ call-next-method ] [
            dup arm-hfa-members
            [ nip [ third ] map mark-hfa-reps record-reg-reps ]
            [ call-next-method ] if*
        ] if
    ] dip
    over empty? [ drop ] [
        over first first reg-class-of int-regs eq?
        [ mark-core-struct-reps ] [ drop ] if
    ] if ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;
:: softfp-box-arguments ( src rep -- )
    D15 src rep M\ arm.32 %copy execute
    rep double-rep?
    [ R0 R1 D15 VMOV-DOUBLE-TO-CORE R2 VM MOV ]
    [ R0 D15 >S VMOV-FROM-S R1 VM MOV ] if ;
:: softfp-unbox-result ( dst rep -- )
    rep double-rep?
    [ D15 R0 R1 VMOV-CORE-TO-DOUBLE ]
    [ D15 >S R0 VMOV-TO-S ] if
    dst D15 rep M\ arm.32 %copy execute ;
M:: arm.32 %unbox ( dst src func rep -- )
    R0 src tagged-rep %copy R1 VM MOV func f f %c-invoke
    arm32-softfp? rep reg-class-of float-regs eq? and
    [ dst rep softfp-unbox-result ]
    [ dst rep return-reg rep %copy ] if ;
M:: arm.32 %box ( dst src func rep gc-map -- )
    rep reg-class-of int-regs eq?
    [ R0 src rep %copy R1 VM MOV ] [
        arm32-softfp? [ src rep softfp-box-arguments ]
        [ D0 src rep %copy R0 VM MOV ] if
    ] if
    func f gc-map %c-invoke dst R0 int-rep %copy ;
M:: arm.32 %unbox-long-long ( dst1 dst2 src func -- )
    R0 src tagged-rep %copy R1 VM MOV func f f %c-invoke
    R4 R0 MOV dst2 R1 int-rep %copy dst1 R4 int-rep %copy ;
M:: arm.32 %box-long-long ( dst src1 src2 func gc-map -- )
    R4 src1 int-rep %copy R1 src2 int-rep %copy R0 R4 MOV R2 VM MOV
    func f gc-map %c-invoke dst R0 int-rep %copy ;

: %store-reg-param ( vreg rep reg -- ) -rot M\ arm.32 %copy execute ;
: %load-reg-param ( vreg rep reg -- ) swap M\ arm.32 %copy execute ;
: temp-reg ( rep -- reg ) reg-class-of int-regs eq? R4 D15 ? ;
:: %store-stack-param ( vreg rep n size -- )
    rep temp-reg vreg rep M\ arm.32 %copy execute
    rep reg-class-of int-regs eq?
    [ rep temp-reg SP n memory-offset STR ]
    [ rep temp-reg rep float-rep? [ >S ] when SP n fp-memory-offset VSTR ] if ;
M: arm.32 %alien-assembly
    3nip swap {
        [ [ first3 %store-reg-param ] each ]
        [ [ first4 %store-stack-param ] each ]
        [ call( -- ) ]
        [ [ first3 %load-reg-param ] each ]
    } spread drop ;

! IP already holds the native target; compute the frame using R4 itself.
: native-call-frame ( stack-size -- )
    16 - R4 swap LI R4 SP R4 ADD ;

:: %c-invoke-tramp2 ( stack-size symbols dll gc-map -- )
    IP load-address symbols dll rot rel-dlsym
    stack-size native-call-frame
    LR load-address rel-trampoline2 LR BLX gc-map gc-map-here ;
M: arm.32 %alien-invoke
    reach [ '[ _ _ _ %c-invoke ] ]
    [ -roll '[ _ _ _ _ %c-invoke-tramp2 ] ] if-zero %alien-assembly ;

:: %invoke-indirect ( src stack-size gc-map -- )
    IP src int-rep %copy
    stack-size zero? [ TRAMPOLINE BLX ] [
        stack-size native-call-frame
        LR load-address rel-trampoline2 LR BLX
    ] if gc-map gc-map-here ;
M:: arm.32 %alien-indirect ( src
                            varargs? reg-inputs stack-inputs
                            reg-outputs dead-outputs
                            cleanup stack-size gc-map -- )
    varargs? reg-inputs stack-inputs reg-outputs dead-outputs
    cleanup stack-size [ src stack-size gc-map %invoke-indirect ]
    %alien-assembly ;

:: overflow-branch ( label cc -- )
    cc cc-o eq? [ VS ] [ VC ] if
    0 B label rc-relative-arm-b label-fixup ;
M:: arm.32 %fixnum-add ( label dst src1 src2 cc -- )
    dst src1 src2 S ADD label cc overflow-branch ;
M:: arm.32 %fixnum-sub ( label dst src1 src2 cc -- )
    dst src1 src2 S SUB label cc overflow-branch ;
M:: arm.32 %fixnum-mul ( label dst src1 src2 cc -- )
    dst temp src1 src2 SMULL
    temp dst 31 <ASR> CMP
    label cc cc-o eq? cc/= cc= ? branch-label ;
M:: arm.32 %mneg ( dst src1 src2 -- )
    dst src1 src2 MUL dst dst 0 RSB ;
M:: arm.32 %min ( dst src1 src2 -- )
    temp src2 MOV src1 src2 CMP dst src1 MOV GT dst temp MOV ;
M:: arm.32 %max ( dst src1 src2 -- )
    temp src2 MOV src1 src2 CMP dst src1 MOV LT dst temp MOV ;
M:: arm.32 %log2 ( dst src -- )
    dst src CLZ dst dst 31 RSB ;

:: load-tagged-immediate ( dst value -- )
    value fixnum? [ dst value tag-fixnum LI ] [
        value [ dst load-address value swap rel-literal ]
        [ dst \ f type-number MOV ] if
    ] if ;

M:: arm.32 %compare-imm ( dst src value cc scratch -- )
    temp value load-tagged-immediate
    src temp CMP temp load-address \ t swap rel-literal dst cc %boolean ;
M:: arm.32 %compare-imm-branch ( label src value cc -- )
    temp value load-tagged-immediate
    src temp CMP label cc branch-label ;

:: (%write-barrier) ( card scratch -- )
    temp card-mark MOV
    card card card-bits <LSR> MOV
    scratch VM vm-cards-offset-offset memory-offset LDR
    temp scratch card <+> STRB
    card card deck-bits card-bits - <LSR> MOV
    scratch VM vm-decks-offset-offset memory-offset LDR
    temp scratch card <+> STRB ;
M:: arm.32 %write-barrier ( src slot scale tag card scratch -- )
    card src slot ADD card scratch (%write-barrier) ;
M:: arm.32 %write-barrier-imm ( src slot tag card scratch -- )
    card src slot tag slot-offset %add-offset card scratch (%write-barrier) ;

:: %integer-load ( dst base offset type -- )
    type [ [ heap-size ] [ c-type-signed ] bi ] [ 4 f ] if* :> ( size signed? )
    size 4 = [ dst base offset memory-offset LDR ] [
        temp base offset %add-offset
        size 1 = [ signed? [ dst temp 0 <+> LDRSB ] [ dst temp 0 <+> LDRB ] if ]
        [ signed? [ dst temp 0 <+> LDRSH ] [ dst temp 0 <+> LDRH ] if ] if
    ] if ;
:: %integer-store ( src base offset type -- )
    type [ heap-size ] [ 4 ] if* :> size
    size 4 = [ src base offset memory-offset STR ] [
        temp base offset %add-offset
        size 1 = [ src temp 0 <+> STRB ] [ src temp 0 <+> STRH ] if
    ] if ;
M:: arm.32 %load-memory-imm ( dst base offset rep type -- )
    rep reg-class-of int-regs eq?
    [ dst base offset type %integer-load ]
    [ dst rep float-rep? [ >S ] when base offset fp-memory-offset VLDR ] if ;
M:: arm.32 %store-memory-imm ( src base offset rep type -- )
    rep reg-class-of int-regs eq?
    [ src base offset type %integer-store ]
    [ src rep float-rep? [ >S ] when base offset fp-memory-offset VSTR ] if ;
M:: arm.32 %load-memory ( dst base disp scale offset rep type -- )
    R4 base disp scale <LSL> ADD dst R4 offset rep type %load-memory-imm ;
M:: arm.32 %store-memory ( src base disp scale offset rep type -- )
    R4 base disp scale <LSL> ADD src R4 offset rep type %store-memory-imm ;
M:: arm.32 %convert-integer ( dst src type -- )
    32 type heap-size 8 * - :> shift
    shift zero? [ dst src MOV ] [
        dst src shift <LSL> MOV
        dst dst shift type c-type-signed [ <ASR> ] [ <LSR> ] if MOV
    ] if ;
M:: arm.32 %alien-global ( dst symbol library -- )
    dst load-address symbol library rot rel-dlsym ;
M: arm.32 %unbox-alien alien-offset memory-offset LDR ;
M:: arm.32 %dispatch ( src scratch -- )
    temp PC 4 ADD temp temp src <+> LDR temp BX ;

: float-cc ( cc -- )
    {
        { cc< [ CC ] } { cc<= [ LS ] }
        { cc> [ GT ] } { cc>= [ GE ] } { cc= [ EQ ] }
        { cc<>= [ VC ] } { cc/< [ CS ] } { cc/<= [ HI ] }
        { cc/> [ LE ] } { cc/>= [ LT ] } { cc/= [ NE ] }
        { cc/<>= [ VS ] }
    } case ;
:: condition-branch ( label condition -- )
    condition call( -- ) 0 B label rc-relative-arm-b label-fixup ;
:: (%compare-float) ( dst cc -- )
    cc {
        { cc<> [
            <label> :> end
            end [ EQ ] condition-branch end [ VS ] condition-branch
            dst temp MOV end resolve-label
        ] }
        { cc/<> [ EQ dst temp MOV VS dst temp MOV ] }
        [ float-cc dst temp MOV ]
    } case ;
:: prepare-float-compare ( dst -- )
    temp load-address \ t swap rel-literal dst \ f type-number MOV ;
M:: arm.32 %compare-float-ordered ( dst src1 src2 cc scratch -- )
    dst prepare-float-compare src1 src2 VCMPE PC VMRS dst cc (%compare-float) ;
M:: arm.32 %compare-float-unordered ( dst src1 src2 cc scratch -- )
    dst prepare-float-compare src1 src2 VCMP PC VMRS dst cc (%compare-float) ;
:: (%compare-float-branch) ( label cc -- )
    cc {
        { cc<> [
            <label> :> end
            end [ EQ ] condition-branch label [ VC ] condition-branch
            end resolve-label
        ] }
        { cc/<> [ label [ EQ ] condition-branch label [ VS ] condition-branch ] }
        [ float-cc 0 B label rc-relative-arm-b label-fixup ]
    } case ;
M:: arm.32 %compare-float-ordered-branch ( label src1 src2 cc -- )
    src1 src2 VCMPE PC VMRS label cc (%compare-float-branch) ;
M:: arm.32 %compare-float-unordered-branch ( label src1 src2 cc -- )
    src1 src2 VCMP PC VMRS label cc (%compare-float-branch) ;

! Match the native save area in bootstrap.assembler.arm.32.
CONSTANT: arm32-callback-save-size 112
:: %load-stack-param ( vreg rep n size -- )
    R4 CTX context-callstack-save-offset memory-offset LDR
    rep reg-class-of int-regs eq?
    [ R4 R4 n arm32-callback-save-size + f %integer-load ]
    [ D15 rep float-rep? [ >S ] when
      R4 n arm32-callback-save-size + fp-memory-offset VLDR ] if
    vreg rep temp-reg rep M\ arm.32 %copy execute ;
M: arm.32 %callback-inputs
    [ [ first3 %load-reg-param ] each ]
    [ [ first4 %load-stack-param ] each ] bi*
    R0 VM MOV R1 0 MOV "begin_callback" f f %c-invoke ;
M: arm.32 %callback-stack
    dup CTX context-callstack-save-offset memory-offset LDR
    dup arm32-callback-save-size ADD ;
M: arm.32 %callback-outputs
    R0 VM MOV "end_callback" f f %c-invoke
    [ first3 %store-reg-param ] each ;

M:: arm.32 %unbox-any-c-ptr ( dst src -- )
    <label> :> end
    dst 0 MOV src \ f type-number CMP end [ EQ ] condition-branch
    dst src tag-mask get AND dst alien type-number CMP
    dst src byte-array-offset %add-offset end [ NE ] condition-branch
    dst src alien-offset memory-offset LDR end resolve-label ;
: alien@ ( n -- offset ) bootstrap-cells alien type-number - ;
M:: arm.32 %box-alien ( dst src scratch -- )
    <label> :> end
    src 0 CMP dst \ f type-number MOV end [ EQ ] condition-branch
    dst 5 bootstrap-cells alien scratch %allot
    temp \ f type-number MOV
    temp dst 1 alien@ memory-offset STR
    temp dst 2 alien@ memory-offset STR
    src dst 3 alien@ memory-offset STR
    src dst 4 alien@ memory-offset STR end resolve-label ;
:: select-equal-float-sign ( dst negative? -- )
    dst D15 VCMP PC VMRS NE 2 B
    temp R4 D15 VMOV-DOUBLE-TO-CORE R4 0 CMP
    negative? [ 4 >CC ] [ PL ] if dst D15 VMOV ;
M:: arm.32 %min-float ( dst src1 src2 -- )
    D15 src2 VMOV src1 src2 VCMP PC VMRS dst src1 VMOV
    GT dst D15 VMOV
    src1 src1 VCMP PC VMRS VS dst D15 VMOV
    dst t select-equal-float-sign ;
M:: arm.32 %max-float ( dst src1 src2 -- )
    D15 src2 VMOV src1 src2 VCMP PC VMRS dst src1 VMOV
    CC dst D15 VMOV
    src1 src1 VCMP PC VMRS VS dst D15 VMOV
    dst f select-equal-float-sign ;
M:: arm.32 %bit-count ( dst src -- )
    temp src 1 <LSR> MOV R4 0x55555555 LI temp temp R4 AND
    dst src temp SUB
    R4 0x33333333 LI temp dst 2 <LSR> MOV
    dst dst R4 AND temp temp R4 AND dst dst temp ADD
    temp dst 4 <LSR> MOV dst dst temp ADD
    R4 0x0f0f0f0f LI dst dst R4 AND
    temp dst 8 <LSR> MOV dst dst temp ADD
    temp dst 16 <LSR> MOV dst dst temp ADD dst dst 63 AND ;
M: arm.32 %integer>scalar drop [ >S ] dip VMOV-TO-S ;
M: arm.32 %scalar>integer drop VMOV-FROM-S ;

M: arm.32 test-instruction? t ;
M:: arm.32 %test ( dst src1 src2 cc scratch -- )
    temp load-address \ t swap rel-literal src1 src2 TST dst cc %boolean ;
M:: arm.32 %test-imm ( dst src imm cc scratch -- )
    temp imm LI src temp TST temp load-address \ t swap rel-literal dst cc %boolean ;
M:: arm.32 %test-branch ( label src1 src2 cc -- )
    src1 src2 TST label cc branch-label ;
M:: arm.32 %test-imm-branch ( label src imm cc -- )
    temp imm LI src temp TST label cc branch-label ;
M:: arm.32 %bit-test ( dst src bit scratch -- )
    temp 1 MOV
    temp temp bit <LSL> MOV
    src temp TST temp load-address \ t swap rel-literal dst cc/= %boolean ;
: emit-arm-jump ( label -- ) 0 B rc-relative-arm-b label-fixup ;
M:: arm.32 %box-displaced-alien ( dst disp base scratch base-class -- )
    <label> :> end
    <label> :> not-f
    <label> :> not-alien
    dst base MOV disp 0 CMP end [ EQ ] condition-branch
    dst 5 bootstrap-cells alien scratch %allot
    temp \ f type-number MOV temp dst 2 alien@ memory-offset STR
    base \ f type-number CMP not-f [ NE ] condition-branch
    temp dst 1 alien@ memory-offset STR
    disp dst 3 alien@ memory-offset STR disp dst 4 alien@ memory-offset STR
    end emit-arm-jump not-f resolve-label
    temp base tag-mask get AND temp alien type-number CMP
    not-alien [ NE ] condition-branch
    temp base 1 alien@ memory-offset LDR temp dst 1 alien@ memory-offset STR
    temp base 2 alien@ memory-offset LDR temp dst 2 alien@ memory-offset STR
    temp base 3 alien@ memory-offset LDR temp temp disp ADD temp dst 3 alien@ memory-offset STR
    temp base 4 alien@ memory-offset LDR temp temp disp ADD temp dst 4 alien@ memory-offset STR
    end emit-arm-jump not-alien resolve-label
    base dst 1 alien@ memory-offset STR disp dst 3 alien@ memory-offset STR
    temp base disp ADD temp temp byte-array-offset ADD temp dst 4 alien@ memory-offset STR
    end resolve-label ;
