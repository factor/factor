! Copyright (C) 2025 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data assocs
byte-arrays classes.algebra combinators compiler.cfg
compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps
compiler.codegen.labels compiler.codegen.relocation
compiler.constants cpu.architecture cpu.arm.64.assembler
cpu.arm.64.assembler.registers generalizations kernel layouts
literals make math math.bitwise memory namespaces sequences
system ;
FROM: cpu.arm.64.assembler => B ;
IN: cpu.arm.64

ERROR: not-implemented ;

ERROR: %copy-not-implemented dst src rep ;

M: arm.64 machine-registers
    {
        { int-regs ${
            X0  X1  X2  X3  X4  X5  X6  X7  X8
            X10 X11 X12 X13 X14 X15
        } }
        { float-regs ${
            V0  V1  V2  V3  V4  V5  V6  V7
            V16 V17 V18 V19 V20 V21 V22 V23
            V24 V25 V26 V27 V28 V29 V30
        } }
    } ;

M: arm.64 frame-reg FP ;

M: arm.64 gc-root-offset n>> spill-offset 2 cells + cell /i ;

: imm>halfwords ( uimm64 -- assoc )
    4 <iota> [
        [ -16 * shift 16 bits ] keep
    ] with map>alist ;

: %load-immediate-movz ( DST assoc -- )
    [ 0 = ] reject-keys [ 0 0 MOVZ ] [
        unclip overd
        first2 MOVZ
        [ first2 MOVK ] with each
    ] if-empty ;

: %load-immediate-movn ( DST assoc -- )
    [ 0xffff = ] reject-keys [ 0 0 MOVN ] [
        unclip overd
        first2 [ bitnot 16 bits ] dip MOVN
        [ first2 MOVK ] with each
    ] if-empty ;

M: arm.64 %load-immediate
    imm>halfwords
    dup keys [ [ 0 = ] count ] [ [ 0xffff = ] count ] bi >=
    [ %load-immediate-movz ] [ %load-immediate-movn ] if ;

M: arm.64 %load-reference
    [ swap (LDR=) rel-literal ] [ \ f type-number MOV ] if* ;

M: arm.64 %load-float
    [ >S 0 LDR ] [
        alien.c-types:float <ref>
        rc-relative-arm-b.cond/ldr rel-binary-literal
    ] bi* ;

M: arm.64 %load-double
    [ >D 0 LDR ] [
        double <ref>
        rc-relative-arm-b.cond/ldr rel-binary-literal
    ] bi* ;

M: arm.64 %load-vector
    drop
    [ >Q 0 LDR ]
    [ rc-relative-arm-b.cond/ldr rel-binary-literal ] bi* ;

: extend-offset ( reg imm -- operand )
    dup 9 >signed over = [
        [ temp ] dip MOV
        temp
    ] unless [+] ;

: loc>operand ( loc -- operand )
    [ ds-loc? DS RS ? ] [ n>> cells neg extend-offset ] bi ;

M: arm.64 %peek loc>operand LDR ;
M: arm.64 %replace loc>operand STR ;

M: arm.64 %replace-imm
    {
        { [ over 0 = ] [
            nip XZR
            swap
        ] }
        { [ over fixnum? ] [
            [
                [ temp ] dip tag-fixnum MOV
                temp
            ] dip
        ] }
        { [ swap not ] [
            temp \ f type-number MOV
            [ temp ] dip
        ] }
    } cond %replace ;

M: arm.64 %clear [ 297 ] dip %replace-imm ;

M: arm.64 %inc
    [ ds-loc? DS RS ? dup ] [ n>> cells ] bi
    dup 0 > [ ADD ] [ neg SUB ] if ;

M: arm.64 stack-frame-size (stack-frame-size) 2 cells + 16 align ;

M: arm.64 %call 0 BL rc-relative-arm-b rel-word-pic ;

M: arm.64 %jump
    PIC-TAIL 2 insns ADR
    0 B rc-relative-arm-b rel-word-pic-tail ;

M: arm.64 %jump-label 0 B rc-relative-arm-b label-fixup ;

M: arm.64 %return RET ;

M:: arm.64 %dispatch ( SRC TEMP -- )
    temp 3 insns ADR
    temp dup SRC [+] LDR
    temp BR ;

M: arm.64 %slot 2drop [+] LDR ;
M: arm.64 %slot-imm slot-offset extend-offset LDR ;
M: arm.64 %set-slot 2drop [+] STR ;
M: arm.64 %set-slot-imm slot-offset extend-offset STR ;

M: arm.64 %add ADDS ;
M: arm.64 %add-imm ADDS ;
M: arm.64 %sub SUBS ;
M: arm.64 %sub-imm SUBS ;
M: arm.64 %mul MUL ;

M:: arm.64 %mul-imm ( DST SRC1 src2 -- )
    temp XZR MOV
    temp dup src2 ADD
    DST SRC1 temp MUL ;

M: arm.64 %and AND ;
M: arm.64 %and-imm AND ;
M: arm.64 %or ORR ;
M: arm.64 %or-imm ORR ;
M: arm.64 %xor EOR ;
M: arm.64 %xor-imm EOR ;
M: arm.64 %shl LSL ;
M: arm.64 %shl-imm LSL ;
M: arm.64 %shr LSR ;
M: arm.64 %shr-imm LSR ;
M: arm.64 %sar ASR ;
M: arm.64 %sar-imm ASR ;

M:: arm.64 %min ( DST SRC1 SRC2 -- )
    SRC1 SRC2 CMP
    DST SRC1 SRC2 LE CSEL ;

M:: arm.64 %max ( DST SRC1 SRC2 -- )
    SRC1 SRC2 CMP
    DST SRC1 SRC2 GE CSEL ;

M: arm.64 %not MVN ;
M: arm.64 %neg NEG ;

M:: arm.64 %log2 ( DST SRC -- )
    DST SRC CLZ
    DST DST 64 SUB
    DST DST MVN ;

M:: arm.64 %bit-count ( DST SRC -- )
    fp-temp >D SRC FMOV
    fp-temp dup CNTv
    fp-temp dup 0 ADDV
    DST fp-temp >D FMOV ;

: stack@ ( n -- operand ) [ SP ] dip 2 cells + [+] ;

: spill@ ( n -- operand ) spill-offset stack@ ;

: ?spill-slot ( obj -- obj ) dup spill-slot? [ n>> spill@ ] when ;

UNION: integer-rep int-rep tagged-rep ;

M: arm.64 %copy
    [ [ ?spill-slot ] bi@ ] dip {
        { [ 2over eq? ] [ 3drop ] }
        { [
            3dup
            [ [ register? ] both? ]
            [ integer-rep? ] bi* and
        ] [ drop MOV ] }
        { [
            3dup
            [ offset? ]
            [ register? ]
            [ integer-rep? ] tri* and and
        ] [ drop swap STR ] }
        { [
            3dup
            [ register? ]
            [ offset? ]
            [ integer-rep? ] tri* and and
        ] [ drop LDR ] }
        { [
            3dup
            [ [ register? ] both? ]
            [ double-rep? ] bi* and
        ] [ drop [ >D ] bi@ FMOV ] }
        { [
            3dup
            [ offset? ]
            [ register? ]
            [ double-rep? ] tri* and and
        ] [ drop >D swap STR ] }
        { [
            3dup
            [ register? ]
            [ offset? ]
            [ double-rep? ] tri* and and
        ] [ drop [ >D ] dip LDR ] }
        { [
            3dup
            [ [ register? ] both? ]
            [ float-rep? ] bi* and
        ] [ drop [ >S ] bi@ FMOV ] }
        { [
            3dup
            [ offset? ]
            [ register? ]
            [ float-rep? ] tri* and and
        ] [ drop >S swap STR ] }
        { [
            3dup
            [ register? ]
            [ offset? ]
            [ float-rep? ] tri* and and
        ] [ drop [ >S ] dip LDR ] }
        { [
            3dup
            [ [ register? ] both? ]
            [ vector-rep? ] bi* and
        ] [ drop MOVv ] }
        { [
            3dup
            [ offset? ]
            [ register? ]
            [ vector-rep? ] tri* and and
        ] [ drop >Q swap STR ] }
        { [
            3dup
            [ register? ]
            [ offset? ]
            [ vector-rep? ] tri* and and
        ] [ drop [ >Q ] dip LDR ] }
        [ %copy-not-implemented ]
    } cond ;

: fixnum-overflow ( label DST SRC1 SRC2 cc quot -- )
    dip {
        { cc-o [ BVS ] }
        { cc/o [ BVC ] }
    } case ; inline

M: arm.64 %fixnum-add [ ADDS ] fixnum-overflow ;
M: arm.64 %fixnum-sub [ SUBS ] fixnum-overflow ;

M:: arm.64 %fixnum-mul ( label DST SRC1 SRC2 cc -- )
    temp SRC1 SRC2 SMULH
    DST SRC1 SRC2 MUL
    temp DST 63 <ASR> CMP
    label cc {
        { cc-o [ BNE ] }
        { cc/o [ BEQ ] }
    } case ;

M: arm.64 %add-float [ >D ] tri@ FADDs ;
M: arm.64 %sub-float [ >D ] tri@ FSUBs ;
M: arm.64 %mul-float [ >D ] tri@ FMULs ;
M: arm.64 %div-float [ >D ] tri@ FDIVs ;
M: arm.64 %min-float [ >D ] tri@ FMINs ;
M: arm.64 %max-float [ >D ] tri@ FMAXs ;
M: arm.64 %sqrt [ >D ] bi@ FSQRTs ;

M: arm.64 %single>double-float [ >D ] [ >S ] bi* FCVT ;
M: arm.64 %double>single-float [ >S ] [ >D ] bi* FCVT ;

M: arm.64 %integer>float [ >D ] dip SCVTFsi ;
M: arm.64 %float>integer >D FCVTZSsi ;

M: arm.64 %zero-vector drop dup dup EORv ;
M: arm.64 %fill-vector drop dup dup BICv ;

M:: arm.64 %gather-vector-2 ( DST SRC1 SRC2 rep -- )
    DST SRC1 0 0 rep INSelt
    DST SRC2 1 0 rep INSelt ;

M:: arm.64 %gather-int-vector-2 ( DST SRC1 SRC2 rep -- )
    DST SRC1 0 rep INSgen
    DST SRC2 1 rep INSgen ;

M:: arm.64 %gather-vector-4 ( DST SRC1 SRC2 SRC3 SRC4 rep -- )
    DST SRC1 0 0 rep INSelt
    DST SRC1 1 0 rep INSelt
    DST SRC1 2 0 rep INSelt
    DST SRC1 3 0 rep INSelt ;

M:: arm.64 %gather-int-vector-4 ( DST SRC1 SRC2 SRC3 SRC4 rep -- )
    DST SRC1 0 rep INSgen
    DST SRC2 1 rep INSgen
    DST SRC3 2 rep INSgen
    DST SRC4 3 rep INSgen ;

M: arm.64 %select-vector UMOV ;
M: arm.64 %shuffle-vector drop TBL ;

M: arm.64 %shuffle-vector-imm
    [ fp-temp ] [ >byte-array ] [ ] tri* %load-vector
    fp-temp TBL ;

M: arm.64 %shuffle-vector-halves-imm ( DST SRC1 SRC2 shuffle rep -- )
    5drop not-implemented ;

: >size ( rep -- size )
    {
        { char-16-rep 0 }
        { uchar-16-rep 0 }
        { short-8-rep 1 }
        { ushort-8-rep 1 }
        { int-4-rep 2 }
        { uint-4-rep 2 }
        { longlong-2-rep 3 }
        { ulonglong-2-rep 3 }
        { float-4-rep 1 }
        { double-2-rep 3 }
    } at ;

M: arm.64 %tail>head-vector drop dupd 8 EXT ;
M: arm.64 %merge-vector-head >size TRN1 ;
M: arm.64 %merge-vector-tail >size TRN2 ;
M: arm.64 %float-pack-vector >size FCVTN ;
M: arm.64 %signed-pack-vector >size [ nip SQXTN ] 4keep nipd SQXTN2 ;
M: arm.64 %unsigned-pack-vector >size [ nip SQXTUN ] 4keep nipd SQXTUN2 ;
M: arm.64 %unpack-vector-head >size SXTL ;
M: arm.64 %unpack-vector-tail >size SHLL ;
M: arm.64 %integer>float-vector >size SCVTFvi ;
M: arm.64 %float>integer-vector >size 2/ FCVTZSvi ;

: integer/float ( Rd Rn Rm rep int-op fp-op -- )
    [ [ >size ] [ scalar-rep? ] bi ] 2dip if ; inline

: signed/unsigned/float ( Rd Rn Rm rep s-op u-op f-op -- )
    {
        { [ reach signed-int-vector-rep? ] [ 2drop ] }
        { [ reach unsigned-int-vector-rep? ] [ drop nip ] }
        { [ reach float-vector-rep? ] [ 2nip ] }
    } cond [ >size ] dip call( Rd Rn Rm size -- ) ; inline

M: arm.64 %compare-vector
    {
        { cc=  [ [ CMEQ ] [ FCMEQ ] integer/float ] }
        { cc>  [ [ CMHI ] [ CMGT ] [ FCMGT ] signed/unsigned/float ] }
        { cc>= [ [ CMHS ] [ CMGE ] [ FCMGE ] signed/unsigned/float ] }
    } case ;

:: %move-int-vector-mask ( DST SRC -- )
    fp-temp SRC CMLT
    fp-temp2 >Q 2 insns LDR
    5 insns B
    {
        0x01 0x02 0x04 0x08 0x10 0x20 0x40 0x80
        0x01 0x02 0x04 0x08 0x10 0x20 0x40 0x80
    } %
    fp-temp dup fp-temp2 ANDv
    fp-temp2 fp-temp 0 SHLL
    fp-temp dup 0 SHLL2
    fp-temp2 dup 0 ADDV
    fp-temp dup 0 ADDV
    fp-temp dup fp-temp2 0 ZIP1
    DST fp-temp >S FMOV ;

M: arm.64 %move-vector-mask
    {
        { double-2-rep [ 2drop not-implemented ] }
        { float-4-rep [ 2drop not-implemented ] }
        [ drop %move-int-vector-mask ]
    } case ;

M: arm.64 %test-vector ( DST SRC TEMP rep vcc -- )
    5drop not-implemented ;

M: arm.64 %test-vector-branch ( label SRC TEMP rep vcc -- )
    5drop not-implemented ;

: signed/unsigned ( Rd Rn Rm rep u-op s-op -- )
    [ [ >size ] [ signed-int-vector-rep? ] bi ] 2dip if ; inline

M: arm.64 %add-vector [ ADDv ] [ FADDv ] integer/float ;
M: arm.64 %saturated-add-vector [ SQADD ] [ UQADD ] signed/unsigned ;
M: arm.64 %add-sub-vector 4drop not-implemented ;
M: arm.64 %sub-vector [ SUBv ] [ FSUBv ] integer/float ;
M: arm.64 %saturated-sub-vector [ SQSUB ] [ UQSUB ] signed/unsigned ;
M: arm.64 %mul-vector [ MULv ] [ FMULv ] integer/float ;

M:: arm.64 %mul-high-vector ( DST SRC1 SRC2 rep -- )
    DST SRC1 SRC2 rep [ SMULL ] [ UMULL ] signed/unsigned
    fp-temp SRC1 SRC2 rep [ SMULL2 ] [ UMULL2 ] signed/unsigned
    rep scalar-rep-of rep-size 2 shift :> imm
    DST DST imm rep >size SHRN
    DST fp-temp imm rep >size SHRN2 ;

M: arm.64 %mul-horizontal-add-vector [ MLAv ] [ FMLAv ] integer/float ;
M: arm.64 %saturated-mul-vector 4drop not-implemented ;
M: arm.64 %div-vector >size FDIVv ;
M: arm.64 %min-vector [ SMINv ] [ UMINv ] [ FMINv ] signed/unsigned/float ;
M: arm.64 %max-vector [ SMAXv ] [ UMAXv ] [ FMAXv ] signed/unsigned/float ;
M: arm.64 %avg-vector [ SHADD ] [ UHADD ] signed/unsigned ;
M: arm.64 %dot-vector [ SDOT ] [ UDOT ] signed/unsigned ;
M: arm.64 %sad-vector [ [ SABD ] [ UABD ] signed/unsigned ] 4keep 2nip dupd >size ADDV ;
M: arm.64 %sqrt-vector >size FSQRTv ;
M: arm.64 %horizontal-add-vector >size ADDPv ;
M: arm.64 %horizontal-sub-vector 4drop not-implemented ;
M: arm.64 %abs-vector [ ABSv ] [ FABSv ] integer/float ;
M: arm.64 %and-vector drop ANDv ;
M: arm.64 %andn-vector drop BICv ;
M: arm.64 %or-vector drop ORRv ;
M: arm.64 %xor-vector drop EORv ;
M: arm.64 %not-vector drop MVNv ;
M: arm.64 %shl-vector [ SSHL ] [ USHL ] signed/unsigned ;
M: arm.64 %shr-vector [ 2nipd dupd >size NEGv ] 4keep %shl-vector ;
M: arm.64 %shl-vector-imm >size SHL ;
M: arm.64 %shr-vector-imm [ SSHR ] [ USHR ] signed/unsigned ;
M: arm.64 %horizontal-shl-vector-imm 4drop not-implemented ;
M: arm.64 %horizontal-shr-vector-imm 4drop not-implemented ;

M: arm.64 %integer>scalar drop [ >D ] dip FMOV ;
M: arm.64 %scalar>integer drop >D FMOV ;
M: arm.64 %vector>scalar %copy ;
M: arm.64 %scalar>vector %copy ;

CONSTANT: int-vector-reps
    {
        char-16-rep
        uchar-16-rep
        short-8-rep
        ushort-8-rep
        int-4-rep
        uint-4-rep
        longlong-2-rep
        ulonglong-2-rep
    }

CONSTANT: float-vector-reps
    {
        float-4-rep
        double-2-rep
    }

M: arm.64 %zero-vector-reps vector-reps ;
M: arm.64 %fill-vector-reps vector-reps ;
M: arm.64 %gather-vector-2-reps { double-2-rep longlong-2-rep ulonglong-2-rep } ;
M: arm.64 %gather-int-vector-2-reps { longlong-2-rep ulonglong-2-rep } ;
M: arm.64 %gather-vector-4-reps { float-4-rep int-4-rep uint-4-rep } ;
M: arm.64 %gather-int-vector-4-reps { int-4-rep uint-4-rep } ;
M: arm.64 %select-vector-reps int-vector-reps ;
M: arm.64 %alien-vector-reps vector-reps ;
M: arm.64 %shuffle-vector-reps { char-16-rep uchar-16-rep } ;
M: arm.64 %shuffle-vector-imm-reps { char-16-rep uchar-16-rep } ;
M: arm.64 %shuffle-vector-halves-imm-reps f ;
M: arm.64 %merge-vector-reps vector-reps ;
M: arm.64 %float-pack-vector-reps { double-2-rep } ;
M: arm.64 %signed-pack-vector-reps int-vector-reps ;
M: arm.64 %unsigned-pack-vector-reps int-vector-reps ;
M: arm.64 %unpack-vector-head-reps vector-reps ;
M: arm.64 %unpack-vector-tail-reps vector-reps ;
M: arm.64 %integer>float-vector-reps { int-4-rep longlong-2-rep } ;
M: arm.64 %float>integer-vector-reps float-vector-reps ;
M: arm.64 %compare-vector-reps { cc< cc<= cc> cc>= cc= cc<> } member? vector-reps and ;

M: arm.64 %compare-vector-ccs
    nip {
        { cc<  [ { { cc>  t } } f ] }
        { cc<= [ { { cc>= t } } f ] }
        { cc>  [ { { cc>  f } } f ] }
        { cc>= [ { { cc>= f } } f ] }
        { cc=  [ { { cc=  f } } f ] }
        { cc<> [ { { cc=  f } } t ] }
    } case ;

M: arm.64 %move-vector-mask-reps vector-reps ;
M: arm.64 %test-vector-reps f ;
M: arm.64 %add-vector-reps vector-reps ;
M: arm.64 %saturated-add-vector-reps int-vector-reps ;
M: arm.64 %sub-vector-reps vector-reps ;
M: arm.64 %saturated-sub-vector-reps int-vector-reps ;
M: arm.64 %mul-vector-reps vector-reps ;
M: arm.64 %mul-high-vector-reps int-vector-reps ;
M: arm.64 %mul-horizontal-add-vector-reps vector-reps ;
M: arm.64 %div-vector-reps float-vector-reps ;
M: arm.64 %min-vector-reps vector-reps ;
M: arm.64 %max-vector-reps vector-reps ;
M: arm.64 %avg-vector-reps int-vector-reps ;
M: arm.64 %dot-vector-reps int-vector-reps ;
M: arm.64 %sad-vector-reps int-vector-reps ;
M: arm.64 %sqrt-vector-reps float-vector-reps ;
M: arm.64 %horizontal-add-vector-reps int-vector-reps ;
M: arm.64 %horizontal-sub-vector-reps int-vector-reps ;
M: arm.64 %abs-vector-reps vector-reps ;
M: arm.64 %and-vector-reps int-vector-reps ;
M: arm.64 %andn-vector-reps int-vector-reps ;
M: arm.64 %or-vector-reps int-vector-reps ;
M: arm.64 %xor-vector-reps int-vector-reps ;
M: arm.64 %not-vector-reps int-vector-reps ;
M: arm.64 %shl-vector-reps int-vector-reps ;
M: arm.64 %shr-vector-reps int-vector-reps ;
M: arm.64 %shl-vector-imm-reps int-vector-reps ;
M: arm.64 %shr-vector-imm-reps int-vector-reps ;
M: arm.64 %horizontal-shl-vector-imm-reps f ;
M: arm.64 %horizontal-shr-vector-imm-reps f ;

M: arm.64 %unbox-alien alien-offset [+] LDR ;

M:: arm.64 %unbox-any-c-ptr ( DST SRC -- )
    <label> :> end
    DST XZR MOV
    SRC \ f type-number CMP
    end BEQ
    DST SRC tag-mask get AND
    DST alien type-number CMP
    DST SRC byte-array-offset ADD
    end BNE
    DST SRC alien-offset [+] LDR
    end resolve-label ;

: alien@ ( reg n -- operand ) cells alien type-number - [+] ;

M:: arm.64 %box-alien ( DST SRC TEMP -- )
    <label> :> end
    DST \ f type-number MOV
    SRC end CBZ
    DST 5 cells alien TEMP %allot
    temp \ f type-number MOV
    temp DST 1 alien@ STR
    temp DST 2 alien@ STR
    SRC  DST 3 alien@ STR
    SRC  DST 4 alien@ STR
    end resolve-label ;

:: %box-displaced-alien/f ( DST DISP -- )
    temp \ f type-number MOV
    temp DST 1 alien@ STR
    DISP DST 3 alien@ STR
    DISP DST 4 alien@ STR ;

:: %box-displaced-alien/alien ( DST DISP BASE TEMP -- )
    temp BASE 1 alien@ LDR
    temp DST  1 alien@ STR
    temp BASE 3 alien@ LDR
    temp dup DISP ADD
    temp DST  3 alien@ STR
    temp BASE 4 alien@ LDR
    temp dup DISP ADD
    temp DST  4 alien@ STR ;

:: %box-displaced-alien/byte-array ( DST DISP BASE TEMP -- )
    BASE DST 1 alien@ STR
    DISP DST 3 alien@ STR
    temp BASE DISP ADD
    temp dup byte-array-offset ADD
    temp DST 4 alien@ STR ;

:: %box-displaced-alien/dynamic ( DST DISP BASE TEMP end -- )
    <label> :> not-f
    <label> :> not-alien
    temp BASE tag-mask get AND
    temp \ f type-number CMP
    not-f BNE
    DST DISP %box-displaced-alien/f
    end B
    not-f resolve-label
    temp alien type-number CMP
    not-alien BNE
    DST DISP BASE TEMP %box-displaced-alien/alien
    end B
    not-alien resolve-label
    DST DISP BASE TEMP %box-displaced-alien/byte-array ;

M:: arm.64 %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    <label> :> end
    DST BASE MOV
    DISP end CBZ
    DST 5 cells alien TEMP %allot
    temp \ f type-number MOV
    temp DST 2 alien@ STR
    DST DISP BASE TEMP {
        { [ base-class \ f class<= ] [ 2drop %box-displaced-alien/f ] }
        { [ base-class \ alien class<= ] [ %box-displaced-alien/alien ] }
        { [ base-class \ byte-array class<= ] [ %box-displaced-alien/byte-array ] }
        [ end %box-displaced-alien/dynamic ]
    } cond
    end resolve-label ;

M: arm.64 %convert-integer
    [ [ 0 ] dip heap-size 8 * ] [ c-type-signed ] bi
    [ SBFX ] [ UBFX ] if ;

:: (%memory) ( BASE DISP scale offset -- operand )
    temp BASE offset ADD
    temp DISP scale <LSL*> [+] ;

M: arm.64 %load-memory or* [ (%memory) ] dip LDR* ;
M: arm.64 %load-memory-imm or* [ extend-offset ] dip LDR* ;
M: arm.64 %store-memory or* [ (%memory) ] dip STR* ;
M: arm.64 %store-memory-imm or* [ extend-offset ] dip STR* ;

M: arm.64 %alien-global ( DST symbol library -- )
    3drop not-implemented ;

M: arm.64 %vm-field [ VM ] dip [+] LDR ;
M: arm.64 %set-vm-field [ VM ] dip [+] STR ;

M:: arm.64 %allot ( DST size class TEMP -- )
    DST VM vm-nursery-here-offset [+] LDR
    temp DST size data-alignment get align ADD
    temp VM vm-nursery-here-offset [+] STR
    temp class type-number tag-header MOV
    temp DST [] STR
    DST dup class type-number ADD ;

:: (%write-barrier) ( CARD TEMP -- )
    temp card-mark MOV
    CARD dup card-bits LSR
    TEMP VM vm-cards-offset-offset [+] LDR
    temp CARD TEMP [+] STRB
    CARD dup deck-bits card-bits - LSR
    TEMP VM vm-decks-offset-offset [+] LDR
    temp CARD TEMP [+] STRB ;

M:: arm.64 %write-barrier ( SRC SLOT scale tag CARD TEMP -- )
    CARD SRC SLOT ADD
    CARD TEMP (%write-barrier) ;

M:: arm.64 %write-barrier-imm ( SRC slot tag CARD TEMP -- )
    CARD SRC slot tag slot-offset ADD
    CARD TEMP (%write-barrier) ;

M:: arm.64 %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    TEMP1 VM vm-nursery-here-offset [+] LDR
    TEMP1 dup size ADD
    TEMP2 VM vm-nursery-end-offset [+] LDR
    TEMP1 TEMP2 CMP
    cc {
        { cc<= [ label BLE ] }
        { cc/<= [ label BGT ] }
    } case ;

M: arm.64 %call-gc \ minor-gc %call gc-map-here ;

M: arm.64 %prologue
    neg dup 10 >signed over = [
        [ FP LR SP ] dip [pre] STP
    ] [
        [ SP dup ] dip neg SUB
        FP LR SP [] STP
    ] if
    FP SP MOV ;

M: arm.64 %epilogue
    dup 10 >signed over = [
        [ FP LR SP ] dip [post] LDP
    ] [
        FP LR SP [] LDP
        [ SP dup ] dip ADD
    ] if ;

M: arm.64 %safepoint SAFEPOINT dup [] STR ;

: cc>cond ( cc -- cond )
    order-cc {
        ${ cc<  LT }
        ${ cc<= LE }
        ${ cc>  GT }
        ${ cc>= GE }
        ${ cc=  EQ }
        ${ cc/= NE }
    } at ;

:: (%boolean) ( DST TEMP -- )
    DST \ f type-number MOV
    t TEMP (LDR=) rel-literal ;

:: %boolean ( DST cc TEMP -- )
    DST TEMP (%boolean)
    DST TEMP DST cc CSEL ;

M: arm.64 %compare [ CMP ] [ cc>cond ] [ %boolean ] tri* ;

: (%compare-imm) ( SRC1 src2 -- ) [ tag-fixnum ] [ \ f type-number ] if* CMP ;

M: arm.64 %compare-imm [ (%compare-imm) ] [ cc>cond ] [ %boolean ] tri* ;
M: arm.64 %compare-integer-imm %compare ;

:: %csel-float<> ( DST TEMP -- )
    DST TEMP (%boolean)
    3 insns BEQ
    2 insns BVS
    DST TEMP MOV ;

:: %csel-float/<> ( DST TEMP -- )
    DST TEMP (%boolean)
    2 insns BEQ
    2 insns BVC
    DST TEMP MOV ;

:: (%compare-float) ( DST cc TEMP -- )
    cc {
        { cc<    [ DST LO TEMP %boolean ] }
        { cc<=   [ DST LS TEMP %boolean ] }
        { cc>    [ DST GT TEMP %boolean ] }
        { cc>=   [ DST GE TEMP %boolean ] }
        { cc=    [ DST EQ TEMP %boolean ] }
        { cc<>   [ DST    TEMP %csel-float<>  ] }
        { cc<>=  [ DST VC TEMP %boolean ] }
        { cc/<   [ DST HS TEMP %boolean ] }
        { cc/<=  [ DST HI TEMP %boolean ] }
        { cc/>   [ DST LE TEMP %boolean ] }
        { cc/>=  [ DST LT TEMP %boolean ] }
        { cc/=   [ DST NE TEMP %boolean ] }
        { cc/<>  [ DST    TEMP %csel-float/<> ] }
        { cc/<>= [ DST VS TEMP %boolean ] }
    } case ;

M: arm.64 %compare-float-ordered [ [ >D ] bi@ FCMPE ] 2dip (%compare-float) ;
M: arm.64 %compare-float-unordered [ [ >D ] bi@ FCMP ] 2dip (%compare-float) ;
M: arm.64 %compare-branch [ CMP ] dip cc>cond B.cond ;
M: arm.64 %compare-imm-branch [ (%compare-imm) ] dip cc>cond B.cond ;
M: arm.64 %compare-integer-imm-branch %compare-branch ;

: %branch-float<> ( label -- )
    3 insns BEQ
    2 insns BVS
    B ;

: %branch-float/<> ( label -- )
    2 insns BEQ
    2 insns BVC
    B ;

: (%compare-float-branch) ( label cc -- )
    {
        { cc<    [ BLO ] }
        { cc<=   [ BLS ] }
        { cc>    [ BGT ] }
        { cc>=   [ BGE ] }
        { cc=    [ BEQ ] }
        { cc<>   [ %branch-float<> ] }
        { cc<>=  [ BVC ] }
        { cc/<   [ BHS ] }
        { cc/<=  [ BHI ] }
        { cc/>   [ BLE ] }
        { cc/>=  [ BLT ] }
        { cc/=   [ BNE ] }
        { cc/<>  [ %branch-float/<> ] }
        { cc/<>= [ BVS ] }
    } case ;

M: arm.64 %compare-float-ordered-branch [ [ >D ] bi@ FCMPE ] dip (%compare-float-branch) ;
M: arm.64 %compare-float-unordered-branch [ [ >D ] bi@ FCMP ] dip (%compare-float-branch) ;

M: arm.64 %spill -rot %copy ;
M: arm.64 %reload swap %copy ;

M: arm.64 return-regs
    {
        { int-regs ${ X0 X1 } }
        { float-regs ${ V0 } }
    } ;

M: arm.64 param-regs
    drop {
        { int-regs ${ X0 X1 X2 X3 X4 X5 X6 X7 } }
        { float-regs ${ V0 V1 V2 V3 V4 V5 V6 V7 } }
    } ;

M: arm.64 return-struct-in-registers? heap-size 16 <= ;
M: arm.64 value-struct? heap-size 16 <= ;
M: arm.64 dummy-stack-params? f ;
M: arm.64 dummy-int-params? f ;
M: arm.64 dummy-fp-params? f ;
M: arm.64 struct-return-on-stack? f ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;

: %load-reg-param ( vreg rep reg -- ) swap %copy ;

: %load-return ( DST rep -- ) dup return-reg %load-reg-param ;

M:: arm.64 %unbox ( DST SRC func rep -- )
    arg1 SRC tagged-rep %copy
    arg2 VM MOV
    func f f %c-invoke
    DST rep %load-return ;

M:: arm.64 %local-allot ( DST size align offset -- )
    DST SP offset local-allot-offset 2 cells + ADD ;

M:: arm.64 %box ( DST SRC func rep gc-map -- )
    rep reg-class-of f param-regs at first SRC rep %copy
    rep int-rep? arg2 arg1 ? VM MOV
    func f gc-map %c-invoke
    DST int-rep %load-return ;

M:: arm.64 %save-context ( TEMP1 TEMP2 -- )
    DS RS CTX context-datastack-offset [+] STP ;

M: arm.64 %c-invoke [ (LDR=BLR*) ] dip gc-map-here ;

M: arm.64 %alien-invoke '[ _ _ _ %c-invoke ] %alien-assembly ;

: ?spill-slot* ( obj -- obj )
    dup spill-slot? [
        [ temp ] dip n>> spill@ LDR
        temp
    ] when ;

M: arm.64 %alien-indirect
    [ 8 nrot ] dip '[
        temp _ ?spill-slot* MOV
        TRAMPOLINE BLR
        _ gc-map-here
    ] %alien-assembly ;

:: %store-stack-param ( vreg rep n -- )
    rep return-reg vreg rep %copy
    n stack@ rep return-reg rep %copy ;

: %store-reg-param ( vreg rep reg -- ) -rot %copy ;

M:: arm.64 %alien-assembly ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-inputs [ first3 %store-stack-param ] each
    reg-inputs [ first3 %store-reg-param ] each
    quot call( -- )
    reg-outputs [ first3 %load-reg-param ] each ;

: next-stack@ ( n -- operand ) [ temp ] dip 2 cells + [+] ;

:: %load-stack-param ( vreg rep n -- )
    rep return-reg n next-stack@ rep %copy
    vreg rep return-reg rep %copy ;

M: arm.64 %callback-inputs
    temp FP [] LDR
    [ [ first3 %load-reg-param ] each ]
    [ [ first3 %load-stack-param ] each ] bi*
    arg1 VM MOV
    arg2 XZR MOV
    "begin_callback" f f %c-invoke ;

M: arm.64 %callback-outputs
    arg1 VM MOV
    "end_callback" f f %c-invoke
    [ first3 %store-reg-param ] each ;

M: arm.64 enable-cpu-features
    enable-alien-4-intrinsics
    enable-float-intrinsics
    enable-fsqrt
    enable-float-min/max
    enable-min/max
    enable-log2
    enable-bit-count ; ! could include enable-bit-test

M: arm.64 complex-addressing? f ; ! could be t
M: arm.64 integer-float-needs-stack-frame? f ;
M: arm.64 test-instruction? f ; ! could be t
M: arm.64 fused-unboxing? t ;

M: arm.64 immediate-arithmetic? add/sub-immediate? ;
M: arm.64 immediate-bitwise? logical-64-bit-immediate? ;
M: arm.64 immediate-comparand? add/sub-immediate? ;
M: arm.64 immediate-store?
    {
        { [ dup fixnum? ] [ tag-fixnum 16 unsigned-immediate? ] }
        { [ dup not ] [ drop t ] }
        [ drop f ]
    } cond ;
