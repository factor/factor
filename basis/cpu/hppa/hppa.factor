! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.accessors alien.c-types byte-arrays combinators compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.intrinsics compiler.cfg.registers compiler.cfg.stack-frame compiler.codegen.gc-maps
compiler.codegen.labels compiler.codegen.relocation compiler.constants
cpu.architecture cpu.hppa.assembler cpu.hppa.assembler.registers kernel
layouts literals locals math math.floats math.bitwise math.order memory namespaces sequences system words ;
IN: cpu.hppa

! Native r30 grows upward. Factor frames use the independent downward r18.
! Keep native DP/GP and every persistent VM register out of allocation.
M: hppa machine-registers
    { { int-regs ${ R23 R24 R25 R26 R28 R29 } }
      { float-regs ${ F8 F9 F10 F11 } } } ;
M: hppa frame-reg FP ;
M: hppa vm-stack-space 32 ;
M: hppa gc-root-offset n>> spill-offset 16 + 4 /i ;
: simm14? ( n -- ? ) dup 14 >signed = ;
M: hppa %load-immediate LI ;
: load-address ( value dst -- value class ) 0 LI rc-native-0 ;
M: hppa %load-reference
    [ swap load-address rel-literal ] [ \ f type-number LI ] if* ;
:: add-offset ( DST SRC offset -- )
    offset simm14? [ DST SRC offset LDO ]
    [ temp offset LI DST SRC temp ADD ] if ;
:: memory-offset ( base offset -- base' offset' )
    offset simm14? [ base offset ]
    [ temp offset LI temp base temp ADD temp 0 ] if ;
: loc>address ( loc -- base offset )
    [ ds-loc? DS RS ? ] [ n>> 4 * neg ] bi memory-offset ;
M: hppa %peek loc>address LDW ;
M: hppa %replace loc>address STW ;
M:: hppa %replace-imm ( src loc -- )
    temp2 src [ tag-fixnum ] [ \ f type-number ] if* LI temp2 loc %replace ;
M: hppa %clear [ 297 ] dip %replace-imm ;
M: hppa %inc [ ds-loc? DS RS ? dup ] [ n>> 4 * ] bi add-offset ;
M: hppa stack-frame-size (stack-frame-size) 16 + 16 align ;
M: hppa %call IP0 load-address rel-word-pic IP0 CALL ;
M: hppa %jump
    PIC-TAIL 0 LI 16 rc-native-0 rel-here
    IP0 load-address rel-word-pic-tail IP0 JUMP ;
M: hppa %jump-label IP0 0 LI rc-native-0 label-fixup IP0 JUMP ;
M: hppa %return RET ;
M: hppa %slot 2drop [ temp ] 2dip ADD temp 0 LDW ;
M: hppa %slot-imm [ 4 * ] dip - memory-offset LDW ;
M: hppa %set-slot 2drop [ temp ] 2dip ADD temp 0 STW ;
M: hppa %set-slot-imm [ 4 * ] dip - memory-offset STW ;
M: hppa %add ADD ;
M: hppa %add-imm add-offset ;
M: hppa %sub SUB ;
M: hppa %sub-imm neg add-offset ;
M: hppa %and AND ;
M: hppa %or OR ;
M: hppa %xor XOR ;
M:: hppa %and-imm ( DST SRC value -- ) temp value LI DST SRC temp AND ;
M:: hppa %or-imm ( DST SRC value -- ) temp value LI DST SRC temp OR ;
M:: hppa %xor-imm ( DST SRC value -- ) temp value LI DST SRC temp XOR ;
M:: hppa %not ( DST SRC -- ) temp -1 LI DST SRC temp XOR ;
M:: hppa %neg ( DST SRC -- ) DST ZERO SRC SUB ;
M: hppa %shl-imm SLLI ;
M: hppa %shr-imm SRLI ;
M: hppa %sar-imm SRAI ;

! Header words are previous frame and return address, matching the VM walker.
M: hppa %prologue
    temp2 SP COPY neg SP SP rot add-offset temp2 SP 0 STW RA SP 4 STW ;
M: hppa %epilogue
    drop RA SP 4 LDW SP SP 0 LDW ;
M: hppa %safepoint SAFEPOINT SAFEPOINT 0 STW ;
M: hppa %vm-field [ VM ] dip memory-offset LDW ;
M: hppa %set-vm-field [ VM ] dip memory-offset STW ;
M:: hppa %save-context ( TEMP1 TEMP2 -- )
    SP CTX context-callstack-top-offset STW
    DS CTX context-datastack-offset STW RS CTX context-retainstack-offset STW ;
M: hppa complex-addressing? f ;
M: hppa integer-float-needs-stack-frame? t ;
M: hppa fused-unboxing? t ;
M: hppa immediate-arithmetic? simm14? ;
! The immediate forms materialize a full cell with LI before the register op.
M: hppa immediate-bitwise? -0x80000000 0xffffffff between? ;
M: hppa immediate-comparand? dup fixnum? [ simm14? ] [ not ] if ;
M: hppa immediate-store? drop f ;

:: compare-branch ( SRC1 SRC2 cc distance -- )
    cc order-cc {
        { cc< [ SRC1 SRC2 distance BLT ] }
        { cc<= [ SRC2 SRC1 distance BGE ] }
        { cc> [ SRC2 SRC1 distance BLT ] }
        { cc>= [ SRC1 SRC2 distance BGE ] }
        { cc= [ SRC1 SRC2 distance BEQ ] }
        { cc/= [ SRC1 SRC2 distance BNE ] }
        { t [ distance cpu.hppa.assembler:B ] }
        { f [ NOP ] }
    } case NOP ;
:: compare-bit ( DST SRC1 SRC2 cc -- )
    ! Read both inputs before writing DST, which may alias either input.
    SRC1 SRC2 cc 20 compare-branch
    DST 0 LDI 12 cpu.hppa.assembler:B NOP DST 1 LDI ;
:: boolean-result ( DST BIT -- )
    DST \ f type-number LI BIT ZERO 16 BEQ NOP
    t DST load-address rel-literal ;
:: branch-bit ( label BIT -- )
    BIT ZERO 24 BEQ NOP label %jump-label ;
M:: hppa %compare ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc compare-bit DST TEMP boolean-result ;
M:: hppa %compare-integer-imm ( DST SRC value cc TEMP -- )
    temp value LI DST SRC temp cc TEMP %compare ;
M: hppa %compare-imm
    [ [ tag-fixnum ] [ \ f type-number ] if* ] 2dip %compare-integer-imm ;
M:: hppa %compare-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc compare-bit label temp2 branch-bit ;

! Register data stays in Factor's canonical IEEE encoding. Convert only when
! executing native FP instructions; raw bit copies and spills stay unchanged.
! r6 holds callback sret and is deliberately not used by this adapter.
:: convert-nan ( DST SRC rep native? -- )
    <label> :> end <label> :> payload-present
    rep double-rep eq? :> double?
    double? [ SRC NATIVE-SP -16 FSTD ] [ SRC NATIVE-SP -16 FSTW ] if
    temp1 NATIVE-SP -16 LDW
    temp2 temp1 double? 20 23 ? SRLI
    temp double? 0x7ff 0xff ? LI temp2 temp2 temp AND
    end temp2 temp cc/= %compare-branch
    temp double? 0xfffff 0x7fffff ? LI temp2 temp1 temp AND
    double? [ temp NATIVE-SP -12 LDW temp2 temp2 temp OR ] when
    end temp2 ZERO cc= %compare-branch
    temp double? 0x80000 0x400000 ? LI temp1 temp1 temp XOR
    temp double? 0xfffff 0x7fffff ? LI temp2 temp1 temp AND
    double? [ temp NATIVE-SP -12 LDW temp2 temp2 temp OR ] when
    payload-present temp2 ZERO cc/= %compare-branch
    native? [
        temp double? 0x40000 0x200000 ? LI temp1 temp1 temp OR
    ] [
        double? [ temp 1 LDI temp NATIVE-SP -12 STW ]
        [ temp 1 LDI temp1 temp1 temp OR ] if
    ] if
    payload-present resolve-label temp1 NATIVE-SP -16 STW
    end resolve-label
    double? [ DST NATIVE-SP -16 FLDD ] [ DST NATIVE-SP -16 FLDW ] if ;

:: native-float-inputs ( SRC1 SRC2 -- )
    fp-temp SRC1 double-rep t convert-nan
    fp-temp2 SRC2 double-rep t convert-nan ;
M:: hppa %add-float ( DST SRC1 SRC2 -- )
    SRC1 SRC2 native-float-inputs DST fp-temp fp-temp2 FADD.D
    DST DST double-rep f convert-nan ;
M:: hppa %sub-float ( DST SRC1 SRC2 -- )
    SRC1 SRC2 native-float-inputs DST fp-temp fp-temp2 FSUB.D
    DST DST double-rep f convert-nan ;
M:: hppa %mul-float ( DST SRC1 SRC2 -- )
    SRC1 SRC2 native-float-inputs DST fp-temp fp-temp2 FMUL.D
    DST DST double-rep f convert-nan ;
M:: hppa %div-float ( DST SRC1 SRC2 -- )
    SRC1 SRC2 native-float-inputs DST fp-temp fp-temp2 FDIV.D
    DST DST double-rep f convert-nan ;
M:: hppa %compare-integer-imm-branch ( label SRC value cc -- )
    temp value LI label SRC temp cc %compare-branch ;
M: hppa %compare-imm-branch
    [ [ tag-fixnum ] [ \ f type-number ] if* ] dip %compare-integer-imm-branch ;

: spill-address ( slot -- base offset ) n>> spill-offset 16 + SP swap memory-offset ;
:: load-rep ( DST base offset rep -- )
    rep { { int-rep [ DST base offset LDW ] }
        { tagged-rep [ DST base offset LDW ] }
        { float-rep [ temp base offset add-offset DST temp 0 FLDW ] }
        { double-rep [ temp base offset add-offset DST temp 0 FLDD ] } } case ;
:: store-rep ( SRC base offset rep -- )
    rep { { int-rep [ SRC base offset STW ] }
        { tagged-rep [ SRC base offset STW ] }
        { float-rep [ temp base offset add-offset SRC temp 0 FSTW ] }
        { double-rep [ temp base offset add-offset SRC temp 0 FSTD ] } } case ;
M:: hppa %copy ( DST SRC rep -- )
    DST SRC eq? [ ] [
        DST spill-slot? [
            SRC spill-slot? [
                rep reg-class-of int-regs eq? temp2 fp-temp ? :> scratch
                scratch SRC spill-address rep load-rep
                scratch DST spill-address rep store-rep
            ] [ SRC DST spill-address rep store-rep ] if
        ] [ SRC spill-slot? [ DST SRC spill-address rep load-rep ] [
            rep reg-class-of int-regs eq? [ DST SRC COPY ] [ DST SRC FCOPY.D ] if
        ] if ] if
    ] if ;
M: hppa %spill -rot %copy ;
M: hppa %reload swap %copy ;

M:: hppa %shl ( DST SRC count -- )
    temp 31 LDI temp temp count SUB temp MTSAR DST SRC 32 ZVDEP ;
M:: hppa %shr ( DST SRC count -- )
    temp 31 LDI temp temp count SUB temp MTSAR DST SRC 32 VEXTRU ;
M:: hppa %sar ( DST SRC count -- )
    temp 31 LDI temp temp count SUB temp MTSAR DST SRC 32 VEXTRS ;
M:: hppa %dispatch ( SRC TEMP -- )
    <label> :> table
    temp 0 LI table rc-native-0 label-fixup
    temp temp SRC ADD temp temp 0 LDW temp JUMP
    4 align-code table resolve-label ;
M:: hppa %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset LDW
    temp2 DST size data-alignment get align add-offset
    temp2 VM vm-nursery-here-offset STW
    temp class type-number tag-header LI temp DST 0 STW
    DST DST class type-number add-offset ;
:: write-barrier ( CARD TEMP -- )
    temp card-mark LI CARD CARD card-bits SRLI
    TEMP VM vm-cards-offset-offset LDW TEMP TEMP CARD ADD temp TEMP 0 STB
    CARD CARD deck-bits card-bits - SRLI
    TEMP VM vm-decks-offset-offset LDW TEMP TEMP CARD ADD temp TEMP 0 STB ;
M:: hppa %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SRC SLOT ADD CARD TEMP write-barrier ;
M:: hppa %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot 4 * tag - add-offset CARD TEMP write-barrier ;
M:: hppa %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset LDW TEMP1 TEMP1 size add-offset
    TEMP2 VM vm-nursery-end-offset LDW
    TEMP2 TEMP1 20 BLTU NOP
    temp2 cc cc<= eq? 1 0 ? LDI 12 cpu.hppa.assembler:B NOP
    temp2 cc cc<= eq? 0 1 ? LDI label temp2 branch-bit ;
M: hppa %call-gc \ minor-gc %call gc-map-here ;
M:: hppa %local-allot ( DST size align offset -- )
    DST SP offset local-allot-offset 16 + add-offset ;

! Native calls cross the plabel-aware GNU gate; r30 remains native throughout.
M:: hppa %c-invoke ( symbol dll gc-map -- )
    symbol dll IP0 load-address rel-dlsym TRAMPOLINE CALL gc-map gc-map-here ;
M:: hppa %alien-global ( DST symbol library -- )
    symbol library DST load-address rel-dlsym ;
M:: hppa %unbox ( DST SRC func rep -- )
    ! Foreign c-types with a custom C unboxer return native FP encodings.
    ! Ordinary float representation conversion uses raw c-type-f memory.
    arg1 SRC tagged-rep %copy arg2 VM COPY func f f %c-invoke
    rep reg-class-of float-regs eq? [ F4 F4 rep f convert-nan ] when
    DST rep reg-class-of int-regs eq? RETURN F4 ? rep %copy ;
M:: hppa %box ( DST SRC func rep gc-map -- )
    ! Custom foreign C boxers consume native FP encodings.
    rep reg-class-of int-regs eq? [
        arg1 SRC rep %copy arg2 VM COPY
    ] [
        fp-temp SRC rep t convert-nan
        rep double-rep eq? [ F5 fp-temp rep %copy arg3 VM COPY ]
        [ F4 fp-temp rep %copy arg2 VM COPY ] if
    ] if
    func f gc-map %c-invoke DST RETURN tagged-rep %copy ;
M:: hppa %unbox-long-long ( DST1 DST2 SRC func -- )
    arg1 SRC tagged-rep %copy arg2 VM COPY func f f %c-invoke
    temp2 R29 COPY IP1 R28 COPY
    DST1 temp2 int-rep %copy DST2 IP1 int-rep %copy ;
M:: hppa %box-long-long ( DST SRC1 SRC2 func gc-map -- )
    IP1 SRC1 int-rep %copy temp2 SRC2 int-rep %copy
    arg1 IP1 COPY arg2 temp2 COPY arg3 VM COPY
    func f gc-map %c-invoke DST RETURN tagged-rep %copy ;
M:: hppa %integer>scalar ( DST SRC rep -- )
    SRC NATIVE-SP -16 STW DST NATIVE-SP -16 FLDW ;
M:: hppa %scalar>integer ( DST SRC rep -- )
    SRC NATIVE-SP -16 FSTW DST NATIVE-SP -16 LDW ;
M:: hppa %integer>float ( DST SRC -- )
    SRC NATIVE-SP -16 STW fp-temp NATIVE-SP -16 FLDW DST fp-temp FCNV-I32.D ;
M:: hppa %float>integer ( DST SRC -- )
    fp-temp SRC double-rep t convert-nan
    fp-temp fp-temp FCNV-D.I32 fp-temp NATIVE-SP -16 FSTW DST NATIVE-SP -16 LDW ;
M:: hppa %single>double-float ( DST SRC -- )
    <label> :> finite <label> :> end
    SRC NATIVE-SP -16 FSTW temp1 NATIVE-SP -16 LDW
    temp2 temp1 23 SRLI temp 0xff LI temp2 temp2 temp AND
    finite temp2 temp cc/= %compare-branch
    temp 0x7fffff LI temp2 temp1 temp AND
    finite temp2 ZERO cc= %compare-branch
    temp temp1 29 SLLI temp NATIVE-SP -12 STW
    temp2 temp1 3 SRLI temp 0xfffff LI temp2 temp2 temp AND
    temp 0x80000000 LI temp1 temp1 temp AND temp1 temp1 temp2 OR
    temp 0x7ff00000 LI temp1 temp1 temp OR temp1 NATIVE-SP -16 STW
    DST NATIVE-SP -16 FLDD end %jump-label
    finite resolve-label DST SRC FCNV-S.D end resolve-label ;
M:: hppa %double>single-float ( DST SRC -- )
    <label> :> finite <label> :> end <label> :> payload-present
    SRC NATIVE-SP -16 FSTD temp1 NATIVE-SP -16 LDW
    temp2 temp1 20 SRLI temp 0x7ff LI temp2 temp2 temp AND
    finite temp2 temp cc/= %compare-branch
    temp 0xfffff LI temp2 temp1 temp AND
    temp NATIVE-SP -12 LDW temp2 temp2 temp OR
    finite temp2 ZERO cc= %compare-branch
    temp 0xfffff LI temp1 temp1 temp AND temp1 temp1 3 SLLI
    temp NATIVE-SP -12 LDW temp temp 29 SRLI temp1 temp1 temp OR
    temp2 NATIVE-SP -16 LDW temp 0x80000000 LI temp2 temp2 temp AND
    temp1 temp1 temp2 OR temp 0x7f800000 LI temp1 temp1 temp OR
    temp 0x7fffff LI temp2 temp1 temp AND
    payload-present temp2 ZERO cc/= %compare-branch
    temp 1 LDI temp1 temp1 temp OR
    payload-present resolve-label temp1 NATIVE-SP -16 STW
    DST NATIVE-SP -16 FLDW end %jump-label
    finite resolve-label DST SRC FCNV-D.S end resolve-label ;

:: multiply-pair ( SRC1 SRC2 -- )
    SRC1 NATIVE-SP -16 STW SRC2 NATIVE-SP -12 STW
    fp-temp NATIVE-SP -16 FLDW fp-temp2 NATIVE-SP -12 FLDW
    fp-temp fp-temp fp-temp2 XMPYU ;
M:: hppa %mul ( DST SRC1 SRC2 -- )
    SRC1 SRC2 multiply-pair fp-temp NATIVE-SP -16 FSTW.R
    DST NATIVE-SP -16 LDW ;
M:: hppa %mul-imm ( DST SRC value -- )
    temp value LI DST SRC temp %mul ;
M:: hppa %mneg ( DST SRC1 SRC2 -- )
    DST SRC1 SRC2 %mul DST DST %neg ;
M: hppa enable-cpu-features
    ! Four-byte loads exceed the PA32 fixnum range and must box.
    ! Remove saved-image properties too; inlined callers need recompilation.
    { alien-signed-4 alien-unsigned-4 set-alien-signed-4 set-alien-unsigned-4 }
    [ "intrinsic" remove-word-prop ] each
    enable-float-intrinsics enable-min/max ;

:: float-compare ( lhs rhs condition quiet? -- )
    lhs rhs native-float-inputs
    fp-temp fp-temp2 condition quiet? [ 30 bitand ] when FCMP.D ;

:: float-bit-mode ( DST SRC1 SRC2 cc quiet? -- )
    ! Complement predicates include unordered results where required.
    ! FTEST nullifies the following branch when its condition is true.
    cc {
        { cc< [ SRC1 SRC2 23 quiet? float-compare ] }
        { cc<= [ SRC1 SRC2 19 quiet? float-compare ] }
        { cc> [ SRC2 SRC1 23 quiet? float-compare ] }
        { cc>= [ SRC2 SRC1 19 quiet? float-compare ] }
        { cc= [ SRC1 SRC2 26 quiet? float-compare ] }
        { cc<> [ SRC1 SRC2 6 quiet? float-compare ] }
        { cc<>= [ SRC1 SRC2 2 quiet? float-compare ] }
        { cc/< [ SRC1 SRC2 8 quiet? float-compare ] }
        { cc/<= [ SRC1 SRC2 12 quiet? float-compare ] }
        { cc/> [ SRC2 SRC1 8 quiet? float-compare ] }
        { cc/>= [ SRC2 SRC1 12 quiet? float-compare ] }
        { cc/= [ SRC1 SRC2 4 quiet? float-compare ] }
        { cc/<> [ SRC1 SRC2 24 quiet? float-compare ] }
        { cc/<>= [ SRC1 SRC2 28 quiet? float-compare ] }
    } case
    FTEST 12 cpu.hppa.assembler:B DST 1 LDI DST 0 LDI ;
: float-bit ( DST SRC1 SRC2 cc -- ) f float-bit-mode ;
M:: hppa %compare-float-ordered ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc f float-bit-mode DST TEMP boolean-result ;
M:: hppa %compare-float-unordered ( DST SRC1 SRC2 cc TEMP -- )
    TEMP SRC1 SRC2 cc t float-bit-mode DST TEMP boolean-result ;
M:: hppa %compare-float-ordered-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc f float-bit-mode label temp2 branch-bit ;
M:: hppa %compare-float-unordered-branch ( label SRC1 SRC2 cc -- )
    temp2 SRC1 SRC2 cc t float-bit-mode label temp2 branch-bit ;

:: add-overflow ( DST SRC1 SRC2 -- )
    temp SRC1 SRC2 XOR temp2 SRC1 COPY DST SRC1 SRC2 ADD
    temp2 temp2 DST XOR IP0 -1 LDI temp temp IP0 XOR
    temp temp temp2 AND temp2 temp 31 SRAI ;
:: sub-overflow ( DST SRC1 SRC2 -- )
    temp SRC1 SRC2 XOR temp2 SRC1 COPY DST SRC1 SRC2 SUB
    temp2 temp2 DST XOR temp temp temp2 AND temp2 temp 31 SRAI ;
:: overflow-branch ( label cc -- )
    cc cc/o eq? [ temp -1 LDI temp2 temp2 temp XOR ] when
    label temp2 branch-bit ;
M:: hppa %fixnum-add ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 add-overflow label cc overflow-branch ;
M:: hppa %fixnum-sub ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 sub-overflow label cc overflow-branch ;

:: mul-overflow ( DST SRC1 SRC2 -- )
    IP1 SRC1 COPY temp1 SRC2 COPY IP1 temp1 multiply-pair
    fp-temp NATIVE-SP -16 FSTW temp NATIVE-SP -16 LDW
    temp2 IP1 31 SRAI temp2 temp2 temp1 AND temp temp temp2 SUB
    temp2 temp1 31 SRAI temp2 temp2 IP1 AND temp temp temp2 SUB
    fp-temp NATIVE-SP -16 FSTW.R DST NATIVE-SP -16 LDW
    temp2 DST 31 SRAI temp temp temp2 XOR
    temp2 temp ZERO cc/= compare-bit temp2 ZERO temp2 SUB ;
M:: hppa %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    DST SRC1 SRC2 mul-overflow label cc overflow-branch ;

! Build constants from IEEE bits, so host byte order cannot leak into literals.
M:: hppa %load-float ( DST value -- )
    temp value float>bits LI temp NATIVE-SP -16 STW DST NATIVE-SP -16 FLDW ;
M:: hppa %load-double ( DST value -- )
    value double>bits :> ieee-bits
    temp ieee-bits -32 shift LI temp NATIVE-SP -16 STW
    temp ieee-bits 32 bits LI temp NATIVE-SP -12 STW DST NATIVE-SP -16 FLDD ;
M:: hppa %min ( DST SRC1 SRC2 -- )
    SRC1 SRC2 cc< 20 compare-branch DST SRC2 COPY
    12 cpu.hppa.assembler:B NOP DST SRC1 COPY ;
M:: hppa %max ( DST SRC1 SRC2 -- )
    SRC1 SRC2 cc> 20 compare-branch DST SRC2 COPY
    12 cpu.hppa.assembler:B NOP DST SRC1 COPY ;

ERROR: unsupported-hppa-memory-width width ;
: check-memory-width ( width -- )
    dup { 1 2 4 } member? [ drop ] [ unsupported-hppa-memory-width ] if ;

! Foreign fields may be unaligned. Assemble bytes in target big-endian order.
:: foreign-address ( BASE offset -- ) IP1 BASE COPY IP1 IP1 offset add-offset ;
:: integer-load ( DST BASE offset width signed? -- )
    width check-memory-width DST 0 LDI width <iota> [| i |
        DST DST 8 SLLI temp1 BASE offset i + LDB DST DST temp1 OR
    ] each
    signed? width 4 < and [
        32 width 8 * - :> count DST DST count SLLI DST DST count SRAI
    ] when ;
:: integer-store ( SRC BASE offset width -- )
    width check-memory-width width <iota> [| i |
        temp1 SRC width i - 1 - 8 * SRLI temp1 BASE offset i + STB
    ] each ;
:: load-memory ( DST BASE offset rep c-type -- )
    BASE offset foreign-address
    rep reg-class-of int-regs eq? [
        DST IP1 0 c-type [ heap-size ] [ 4 ] if*
        c-type [ c-type-signed ] [ t ] if* integer-load
    ] [
        IP0 IP1 0 4 f integer-load IP0 NATIVE-SP -16 STW
        rep double-rep eq? [
            IP0 IP1 4 4 f integer-load IP0 NATIVE-SP -12 STW DST NATIVE-SP -16 FLDD
        ] [ DST NATIVE-SP -16 FLDW ] if
        c-type [ DST DST rep f convert-nan ] when
    ] if ;
:: store-memory ( SRC BASE offset rep c-type -- )
    rep reg-class-of int-regs eq? [
        IP0 SRC COPY BASE offset foreign-address
        IP0 IP1 0 c-type [ heap-size ] [ 4 ] if* integer-store
    ] [
        BASE offset foreign-address
        c-type [ fp-temp SRC rep t convert-nan ] [ fp-temp SRC rep %copy ] if
        rep double-rep eq? [ fp-temp NATIVE-SP -16 FSTD ] [ fp-temp NATIVE-SP -16 FSTW ] if
        IP0 NATIVE-SP -16 LDW IP0 IP1 0 4 integer-store
        rep double-rep eq? [ IP0 NATIVE-SP -12 LDW IP0 IP1 4 4 integer-store ] when
    ] if ;
M: hppa %load-memory-imm load-memory ;
M: hppa %store-memory-imm store-memory ;
M:: hppa %load-memory ( DST BASE DISP scale offset rep c-type -- )
    temp2 DISP scale SLLI temp2 BASE temp2 ADD DST temp2 offset rep c-type load-memory ;
M:: hppa %store-memory ( SRC BASE DISP scale offset rep c-type -- )
    temp2 DISP scale SLLI temp2 BASE temp2 ADD SRC temp2 offset rep c-type store-memory ;
M:: hppa %convert-integer ( DST SRC c-type -- )
    32 c-type heap-size 8 * - :> count
    count zero? [ DST SRC COPY ] [
        DST SRC count SLLI
        c-type c-type-signed [ DST DST count SRAI ] [ DST DST count SRLI ] if
    ] if ;

SYMBOL: indirect-source
: native-frame-size ( bytes -- bytes' ) 32 + 64 max 64 align ;
:: argument-home ( reg rep -- offset )
    rep reg-class-of int-regs eq? [ 26 reg n>> - ] [ reg n>> 4 - ] if
    -4 * -36 + ;
:: output-home ( reg rep -- offset )
    rep reg-class-of int-regs eq? [ -28 reg n>> 28 - 4 * + ] [ -16 ] if ;
:: store-call-input ( SRC rep reg -- )
    rep reg-class-of int-regs eq? temp2 fp-temp ? :> scratch
    scratch SRC rep %copy
    rep reg-class-of float-regs eq? [ scratch scratch rep t convert-nan ] when
    scratch NATIVE-SP reg rep argument-home memory-offset rep store-rep ;
:: load-call-input ( SRC rep reg -- )
    reg NATIVE-SP reg rep argument-home memory-offset rep load-rep ;
:: save-call-output ( DST rep reg -- )
    reg NATIVE-SP reg rep output-home memory-offset rep store-rep ;
:: load-call-output ( DST rep reg -- )
    rep reg-class-of int-regs eq? temp2 fp-temp ? :> scratch
    scratch NATIVE-SP reg rep output-home memory-offset rep load-rep
    rep reg-class-of float-regs eq? [ scratch scratch rep f convert-nan ] when
    DST scratch rep %copy ;
:: store-stack-param ( SRC rep offset size -- )
    rep reg-class-of int-regs eq? temp2 fp-temp ? :> scratch
    scratch SRC rep %copy
    rep reg-class-of float-regs eq? [ scratch scratch rep t convert-nan ] when
    scratch NATIVE-SP -36 offset - rep double-rep eq? [ 4 - ] when
    memory-offset rep store-rep ;
M:: hppa %alien-assembly ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-size native-frame-size :> bytes
    NATIVE-SP NATIVE-SP bytes add-offset
    indirect-source get [| src | IP0 src int-rep %copy IP0 NATIVE-SP -32 STW ] when*
    stack-inputs [ first4 store-stack-param ] each
    ! Snapshot every source before assigning any physical parameter register.
    reg-inputs [ first3 store-call-input ] each
    reg-inputs [ first3 load-call-input ] each
    quot call( -- )
    reg-outputs [ first3 save-call-output ] each
    reg-outputs [ first3 load-call-output ] each
    NATIVE-SP NATIVE-SP bytes neg add-offset ;
M:: hppa %alien-invoke ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size symbol dll gc-map -- )
    varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size [
        symbol dll IP0 load-address rel-dlsym TRAMPOLINE2 CALL gc-map gc-map-here
    ] %alien-assembly ;
M:: hppa %alien-indirect ( src varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size gc-map -- )
    src indirect-source [
        varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size [
            IP0 NATIVE-SP -32 LDW TRAMPOLINE2 CALL gc-map gc-map-here
        ] %alien-assembly
    ] with-variable ;

:: load-callback-input ( DST rep reg -- )
    rep reg-class-of int-regs eq? [
        reg RETURN eq? [ DST IP1 rep %copy ] [
            -84 26 reg n>> - 4 * + :> offset
            DST spill-slot? [ temp2 NATIVE-SP offset LDW DST temp2 rep %copy ]
            [ DST NATIVE-SP offset LDW ] if
        ] if
    ] [
        -64 reg n>> 4 - 8 * + :> offset
        fp-temp NATIVE-SP offset memory-offset rep load-rep
        fp-temp fp-temp rep f convert-nan DST fp-temp rep %copy
    ] if ;
:: load-callback-stack ( DST rep offset size -- )
    rep reg-class-of int-regs eq? temp2 fp-temp ? :> scratch
    scratch NATIVE-SP -292 offset - rep double-rep eq? [ 4 - ] when
    memory-offset rep load-rep
    rep reg-class-of float-regs eq? [ scratch scratch rep f convert-nan ] when
    DST scratch rep %copy ;
M:: hppa %callback-inputs ( reg-outputs stack-outputs -- )
    ! GNU's large-result buffer arrives in r28, which begin_callback clobbers.
    ! Reserved r6 survives native C calls and is never allocated to a vreg.
    IP1 RETURN COPY
    arg1 VM COPY arg2 0 LDI "begin_callback" f f %c-invoke
    reg-outputs [ first3 load-callback-input ] each
    stack-outputs [ first4 load-callback-stack ] each ;
M:: hppa %callback-stack ( DST -- ) DST NATIVE-SP -256 add-offset ;
M:: hppa %callback-outputs ( reg-inputs -- )
    NATIVE-SP NATIVE-SP 64 LDO
    reg-inputs [| entry |
        entry first3 :> ( SRC rep reg )
        rep reg-class-of int-regs eq? temp2 fp-temp ? :> scratch
        scratch SRC rep %copy
        rep reg-class-of float-regs eq? [ scratch scratch rep t convert-nan ] when
        scratch NATIVE-SP reg rep output-home memory-offset rep store-rep
    ] each
    arg1 VM COPY "end_callback" f f %c-invoke
    reg-inputs [| entry | entry first3 :> ( SRC rep reg )
        reg NATIVE-SP reg rep output-home memory-offset rep load-rep
    ] each
    NATIVE-SP NATIVE-SP -64 LDO ;

M: hppa %unbox-alien 16 alien type-number - LDW ;
M:: hppa %unbox-any-c-ptr ( DST SRC -- )
    IP1 SRC COPY <label> :> end <label> :> is-alien
    DST 0 LDI end IP1 \ f type-number cc= %compare-integer-imm-branch
    temp2 IP1 tag-mask get %and-imm
    is-alien temp2 alien type-number cc= %compare-integer-imm-branch
    DST IP1 byte-array-offset add-offset end %jump-label
    is-alien resolve-label DST IP1 %unbox-alien end resolve-label ;
: alien-store ( SRC DST slot -- ) 4 * alien type-number - STW ;
: alien-load ( DST SRC slot -- ) 4 * alien type-number - LDW ;
M:: hppa %box-alien ( DST SRC TEMP -- )
    IP1 SRC COPY <label> :> end
    DST \ f type-number LI end IP1 ZERO cc= %compare-branch
    DST 20 alien TEMP %allot temp \ f type-number LI
    temp DST 1 alien-store temp DST 2 alien-store
    IP1 DST 3 alien-store IP1 DST 4 alien-store end resolve-label ;
M:: hppa %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    IP1 BASE COPY temp1 DISP COPY
    <label> :> end <label> :> not-f <label> :> not-alien
    DST IP1 COPY end temp1 ZERO cc= %compare-branch
    DST 20 alien TEMP %allot temp \ f type-number LI temp DST 2 alien-store
    not-f IP1 \ f type-number cc/= %compare-integer-imm-branch
    temp \ f type-number LI temp DST 1 alien-store
    temp1 DST 3 alien-store temp1 DST 4 alien-store end %jump-label
    not-f resolve-label temp2 IP1 tag-mask get %and-imm
    not-alien temp2 alien type-number cc/= %compare-integer-imm-branch
    temp IP1 1 alien-load temp DST 1 alien-store
    temp IP1 2 alien-load temp DST 2 alien-store
    temp IP1 3 alien-load temp temp temp1 ADD temp DST 3 alien-store
    temp IP1 4 alien-load temp temp temp1 ADD temp DST 4 alien-store end %jump-label
    not-alien resolve-label IP1 DST 1 alien-store temp1 DST 3 alien-store
    temp IP1 temp1 ADD temp temp byte-array-offset add-offset temp DST 4 alien-store
    end resolve-label ;
