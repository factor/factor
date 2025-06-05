! Copyright (C) 2023 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.c-types alien.data assocs
byte-arrays classes.algebra classes.struct combinators
compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.intrinsics compiler.cfg.registers
compiler.cfg.stack-frame compiler.codegen.gc-maps
compiler.codegen.labels compiler.codegen.relocation
compiler.constants cpu.architecture cpu.arm.64.assembler
generalizations kernel layouts literals math memory namespaces
sequences system vm ;
FROM: alien.c-types => float double heap-size ;
FROM: cpu.arm.64.assembler => B ;
IN: cpu.arm.64

M: arm.64 machine-registers {
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

M: arm.64 complex-addressing? t ;

HOOK: reserved-stack-space cpu ( -- n )
M: arm.64 reserved-stack-space 0 ;

: special-offset ( m -- n ) reserved-stack-space + ;

M: arm.64 gc-root-offset n>> spill-offset special-offset cell + cell /i ;

M: arm.64 %load-immediate ( reg val -- )
    [ XZR MOV ] [
        4 <iota> [
            [ -16 * shift 0xffff bitand ] keep
        ] with map>alist [ 0 = ] reject-keys
        unclip overd first2 MOVZ
        [ first2 MOVK ] with each
    ] if-zero ;

M: arm.64 %load-reference
    [ swap (LDR=) rel-literal ]
    [ \ f type-number MOV ] if* ;

: copy-memory* ( dst src rep -- )
    pick offset? [ swapd STR* ] [ LDR* ] if ;

GENERIC: copy-register* ( dst src rep -- )
M: int-rep copy-register* drop MOV ;
M: tagged-rep copy-register* drop MOV ;
M: vector-rep copy-register* drop FMOV ;
M: float-rep copy-register* drop FMOV ;
M: double-rep copy-register* drop FMOV ;

M: arm.64 %load-float  float  <ref> float-rep  %load-vector ;
M: arm.64 %load-double double <ref> double-rep %load-vector ;

M:: arm.64 %load-vector ( DST val rep -- )
    DST 0 rep copy-memory*
    val rc-relative-arm-b.cond/ldr rel-binary-literal ;

: reg-stack ( n reg -- operand ) swap cells neg [+] ;

GENERIC: loc>operand ( loc -- operand )
M: ds-loc loc>operand n>> DS reg-stack ;
M: rs-loc loc>operand n>> RS reg-stack ;

M: arm.64 %peek loc>operand LDR ;
M: arm.64 %replace loc>operand STR ;

M:: arm.64 %replace-imm ( imm loc -- )
    imm 0 = [ XZR loc %replace ] [
        {
            { [ imm not ] [ temp \ f type-number MOV ] }
            { [ imm fixnum? ] [ temp imm tag-fixnum MOV ] }
            [ imm temp (LDR=) rel-literal ]
        } cond
        temp loc loc>operand STR
    ] if ;

M: arm.64 %clear [ 297 ] dip %replace-imm ;

M: arm.64 %inc
    [ ds-loc? DS RS ? dup ] [ n>> cells ] bi
    dup 0 > [ ADD ] [ neg SUB ] if ;

M: arm.64 stack-frame-size (stack-frame-size) 2 cells + 16 align ;

M: arm.64 %call (LDR=BLR) rel-word-pic ;

M: arm.64 %jump
    PIC-TAIL 5 insns ADR
    (LDR=BR) rel-word-pic-tail ;

M: arm.64 %jump-label 0 B rc-relative-arm-b label-fixup ;

M: arm.64 %return RET ;

M:: arm.64 %dispatch ( SRC TEMP -- )
    temp 3 insns ADR
    temp dup SRC [+] LDR
    temp BR ;

:: (%slot) ( OBJ SLOT scale tag -- register operand )
    temp OBJ tag dup neg? [ neg ADD ] [ SUB ] if
    temp SLOT scale <LSL*> ; inline

M: arm.64 %slot (%slot) [+] LDR ;
M: arm.64 %slot-imm slot-offset [+] LDR ;
M: arm.64 %set-slot (%slot) [+] STR ;
M: arm.64 %set-slot-imm slot-offset [+] STR ;

M: arm.64 %add     ADDS ;
M: arm.64 %add-imm ADDS ;
M: arm.64 %sub     SUBS ;
M: arm.64 %sub-imm SUBS ;
M: arm.64 %mul     MUL ;

M:: arm.64 %mul-imm ( DST SRC1 src2 -- )
    temp XZR MOV
    temp dup src2 ADD
    DST SRC1 temp MUL ;

M: arm.64 %and     AND ;
M: arm.64 %and-imm AND ;
M: arm.64 %or      ORR ;
M: arm.64 %or-imm  ORR ;
M: arm.64 %xor     EOR ;
M: arm.64 %xor-imm EOR ;
M: arm.64 %shl     LSL ;
M: arm.64 %shl-imm LSL ;
M: arm.64 %shr     LSR ;
M: arm.64 %shr-imm LSR ;
M: arm.64 %sar     ASR ;
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
    fp-temp SRC FMOV
    fp-temp dup CNTv
    fp-temp dup 0 ADDV
    DST fp-temp FMOV ;

:: (%boolean) ( DST TEMP -- )
    DST \ f type-number MOV
    t TEMP (LDR=) rel-literal ;

M:: arm.64 %bit-test ( DST SRC1 SRC2 TEMP -- )
    DST TEMP (%boolean)
    SRC1 SRC2 2 insns TBZ
    DST TEMP MOV ;

: stack@ ( n -- op ) [ SP ] dip [+] ;

: spill@ ( n -- op ) spill-offset special-offset 2 cells + stack@ ;

: ?spill-slot ( obj -- obj ) dup spill-slot? [ n>> spill@ ] when ;

M: arm.64 %copy ( dst src rep -- )
    2over eq? [ 3drop ] [
        [ [ ?spill-slot ] bi@ ] dip
        2over [ register? ] both?
        [ copy-register* ] [ copy-memory* ] if
    ] if ;

: fixnum-overflow ( label dst src1 src2 cc quot -- )
    dip {
        { cc-o [ BVS ] }
        { cc/o [ BVC ] }
    } case ; inline

M: arm.64 %fixnum-add [ ADDS ] fixnum-overflow ;
M: arm.64 %fixnum-sub [ SUBS ] fixnum-overflow ;

M:: arm.64 %fixnum-mul ( label dst src1 src2 cc -- )
    temp src1 src2 SMULH
    dst src1 src2 MUL
    temp dst 63 <ASR> CMP
    label cc {
        { cc-o [ BNE ] }
        { cc/o [ BEQ ] }
    } case ;

M: arm.64 %add-float FADDs ;
M: arm.64 %sub-float FSUBs ;
M: arm.64 %mul-float FMULs ;
M: arm.64 %div-float FDIVs ;
M: arm.64 %min-float FMINs ;
M: arm.64 %max-float FMAXs ;
M: arm.64 %sqrt FSQRTs ;

M: arm.64 %single>double-float FCVT ;
M: arm.64 %double>single-float FCVT ;

M: arm.64 integer-float-needs-stack-frame? f ;

M: arm.64 %integer>float SCVTFsi ;
M: arm.64 %float>integer FCVTZSsi ;

: >spec ( rep -- size )
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

: >spec* ( rep -- size )
    {
        { float-4-rep 0 }
        { double-2-rep 1 }
    } at ;

: integer/float ( Rd Rn Rm rep int-op fp-op -- )
    [ [ >spec ] [ scalar-rep? ] bi ] 2dip if ; inline

: signed/unsigned ( Rd Rn Rm rep u-op s-op -- )
    [ [ >spec ] [ signed-int-vector-rep? ] bi ] 2dip if ; inline

: signed/unsigned/float ( Rd Rn Rm rep s-op u-op f-op -- )
    {
        { [ reach signed-int-vector-rep? ] [ 2drop ] }
        { [ reach unsigned-int-vector-rep? ] [ drop nip ] }
        { [ reach float-vector-rep? ] [ 2nip ] }
    } cond [ >spec ] dip call( Rd Rn Rm rep -- ) ; inline

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
M: arm.64 %shuffle-vector-imm 4drop ;
M: arm.64 %shuffle-vector-halves-imm 5drop ;
M: arm.64 %tail>head-vector drop dupd 8 EXT ;
M: arm.64 %merge-vector-head >spec TRN1 ;
M: arm.64 %merge-vector-tail >spec TRN2 ;
M: arm.64 %float-pack-vector >spec FCVTN ;
M: arm.64 %signed-pack-vector >spec [ nip SQXTN ] 4keep nipd SQXTN2 ;
M: arm.64 %unsigned-pack-vector >spec [ nip SQXTUN ] 4keep nipd SQXTUN2 ;
M: arm.64 %unpack-vector-head SXTL ;
M: arm.64 %unpack-vector-tail SHLL ;
M: arm.64 %integer>float-vector >spec SCVTFvi ;
M: arm.64 %float>integer-vector >spec* FCVTZSvi ;

M: arm.64 %compare-vector
    {
        { cc=  [ [ CMEQ ] [ FCMEQ ] integer/float ] }
        { cc>  [ [ CMHI ] [ CMGT ] [ FCMGT ] signed/unsigned/float ] }
        { cc>= [ [ CMHS ] [ CMGE ] [ FCMGE ] signed/unsigned/float ] }
    } case ;

M: arm.64 %add-vector [ ADDv ] [ FADDv ] integer/float ;
M: arm.64 %saturated-add-vector [ SQADD ] [ UQADD ] signed/unsigned ;
M: arm.64 %sub-vector [ SUBv ] [ FSUBv ] integer/float ;
M: arm.64 %saturated-sub-vector [ SQSUB ] [ UQSUB ] signed/unsigned ;
M: arm.64 %mul-vector [ MULv ] [ FMULv ] integer/float ;
M: arm.64 %div-vector >spec FDIVv ;
M: arm.64 %min-vector [ SMINv ] [ UMINv ] [ FMINv ] signed/unsigned/float ;
M: arm.64 %max-vector [ SMAXv ] [ UMAXv ] [ FMAXv ] signed/unsigned/float ;
M: arm.64 %avg-vector [ SHADD ] [ UHADD ] signed/unsigned ; ! srhadd, urhadd?
M: arm.64 %dot-vector [ SDOT ] [ UDOT ] signed/unsigned ;
M: arm.64 %sad-vector [ [ SABD ] [ UABD ] signed/unsigned ] 4keep 2nip dupd >spec ADDV ;
M: arm.64 %sqrt-vector >spec FSQRTv ;
M: arm.64 %horizontal-add-vector >spec ADDPv ;
M: arm.64 %abs-vector [ ABSv ] [ FABSv ] integer/float ;
M: arm.64 %and-vector drop ANDv ;
M: arm.64 %andn-vector drop BICv ;
M: arm.64 %or-vector drop ORRv ;
M: arm.64 %xor-vector drop EORv ;
M: arm.64 %not-vector drop MVNv ;
M: arm.64 %shl-vector [ SSHL ] [ USHL ] signed/unsigned ;
M: arm.64 %shr-vector [ 2nipd dupd >spec NEGv ] 4keep %shl-vector ;
M: arm.64 %shl-vector-imm >spec SHL ;
M: arm.64 %shr-vector-imm [ SSHR ] [ USHR ] signed/unsigned ;
M: arm.64 %integer>scalar drop FMOV ;
M: arm.64 %scalar>integer drop FMOV ;
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
M: arm.64 %select-vector-reps vector-reps ;
M: arm.64 %alien-vector-reps vector-reps ;
M: arm.64 %shuffle-vector-reps vector-reps ;
M: arm.64 %shuffle-vector-imm-reps f ;
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

M: arm.64 %move-vector-mask-reps f ;
M: arm.64 %add-vector-reps vector-reps ;
M: arm.64 %saturated-add-vector-reps int-vector-reps ;
M: arm.64 %sub-vector-reps vector-reps ;
M: arm.64 %saturated-sub-vector-reps int-vector-reps ;
M: arm.64 %mul-vector-reps vector-reps ;
M: arm.64 %mul-high-vector-reps f ;
M: arm.64 %mul-horizontal-add-vector-reps f ;
M: arm.64 %div-vector-reps float-vector-reps ;
M: arm.64 %min-vector-reps vector-reps ;
M: arm.64 %max-vector-reps vector-reps ;
M: arm.64 %avg-vector-reps int-vector-reps ;
M: arm.64 %dot-vector-reps int-vector-reps ;
M: arm.64 %sad-vector-reps int-vector-reps ;
M: arm.64 %sqrt-vector-reps float-vector-reps ;
M: arm.64 %horizontal-add-vector-reps int-vector-reps ;
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

M: arm.64 %unbox-alien alien-offset [+] LDR ;

M:: arm.64 %unbox-any-c-ptr ( DST SRC -- )
    <label> :> end
    DST XZR MOV
    ! is the object f?
    SRC \ f type-number CMP
    end BEQ
    ! compute tag in DST register
    DST SRC tag-mask get AND
    ! is the object an alien?
    DST alien type-number CMP
    ! add an offset to the start of byte array's data
    DST SRC byte-array-offset ADD
    end BNE
    ! if so, load the offset and add it to the address
    DST SRC alien-offset [+] LDR
    end resolve-label ;

: alien@ ( reg n -- operand ) cells alien type-number - [+] ;

M:: arm.64 %box-alien ( DST SRC TEMP -- )
    <label> :> end
    DST \ f type-number MOV
    SRC end CBZ
    DST 5 cells alien TEMP %allot
    temp \ f type-number MOV
    temp DST 1 alien@ STR ! base
    temp DST 2 alien@ STR ! expired
    SRC  DST 3 alien@ STR ! displacement
    SRC  DST 4 alien@ STR ! address
    end resolve-label ;

:: %box-displaced-alien/f ( DST DISP -- )
    temp \ f type-number MOV
    temp DST 1 alien@ STR
    DISP DST 3 alien@ STR
    DISP DST 4 alien@ STR ;

:: %box-displaced-alien/alien ( DST DISP BASE TEMP -- )
    ! set new alien's base to base.base
    temp BASE 1 alien@ LDR
    temp DST  1 alien@ STR
    ! compute displacement
    temp BASE 3 alien@ LDR
    temp dup DISP ADD
    temp DST  3 alien@ STR
    ! compute address
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
    ! check base type
    temp BASE tag-mask get AND
    ! is base f?
    temp \ f type-number CMP
    not-f BNE
    ! fill in new object
    DST DISP %box-displaced-alien/f
    end B
    not-f resolve-label
    ! is base an alien?
    temp alien type-number CMP
    not-alien BNE
    DST DISP BASE TEMP %box-displaced-alien/alien
    end B
    ! base has to be a byte array now
    not-alien resolve-label
    DST DISP BASE TEMP %box-displaced-alien/byte-array ;

M:: arm.64 %box-displaced-alien ( DST DISP BASE TEMP base-class -- )
    <label> :> end
    ! if displacement is zero, return the base
    DST BASE MOV
    DISP end CBZ
    ! allocate new object
    DST 5 cells alien TEMP %allot
    ! set expired to f
    temp \ f type-number MOV
    temp DST 2 alien@ STR
    DST DISP BASE TEMP {
        { [ base-class \ f class<= ] [ 2drop %box-displaced-alien/f ] }
        { [ base-class \ alien class<= ] [ %box-displaced-alien/alien ] }
        { [ base-class \ byte-array class<= ] [ %box-displaced-alien/byte-array ] }
        [ end %box-displaced-alien/dynamic ]
    } cond
    end resolve-label ;

M: arm.64 %convert-integer [ [ 0 ] dip heap-size 1 - ] [ c-type-signed ] bi [ SBFM ] [ UBFM ] if ;

:: (%memory) ( BASE DISP scale offset -- operand )
    temp BASE offset ADD
    temp DISP scale <LSL*> [+] ;

M: arm.64 %load-memory swap or [ (%memory) ] dip copy-memory* ;
M: arm.64 %load-memory-imm swap or [ [+] ] dip copy-memory* ;
M: arm.64 %store-memory swap or [ (%memory) swap ] dip copy-memory* ;
M: arm.64 %store-memory-imm swap or [ [+] swap ] dip copy-memory* ;

M: arm.64 %alien-global [ XZR MOV ] 2dip rc-absolute-cell rel-dlsym ;

M: arm.64 %vm-field     [ VM ] dip [+] LDR ;
M: arm.64 %set-vm-field [ VM ] dip [+] STR ;

M:: arm.64 %allot ( DST size class TEMP -- )
    VM "nursery" vm offset-of [+] :> operand
    DST operand LDR
    temp DST size data-alignment get align ADD
    temp operand STR
    temp class type-number tag-header MOV
    temp DST [] STR
    DST dup class type-number ADD ;

:: (%write-barrier) ( TEMP1 TEMP2 -- )
    temp card-mark MOV
    TEMP1 dup card-bits LSR
    temp TEMP1 CARDS-OFFSET [+] STRB
    TEMP1 dup deck-bits card-bits - LSR
    temp TEMP1 DECKS-OFFSET [+] STRB ;

M:: arm.64 %write-barrier ( SRC SLOT scale tag TEMP1 TEMP2 -- )
    TEMP1 SRC SLOT scale tag (%slot) ADD
    TEMP1 TEMP2 (%write-barrier) ;

M:: arm.64 %write-barrier-imm ( SRC slot tag TEMP1 TEMP2 -- )
    TEMP1 SRC slot tag slot-offset ADD
    TEMP1 TEMP2 (%write-barrier) ;

M:: arm.64 %check-nursery-branch ( label size cc TEMP1 TEMP2 -- )
    "nursery" vm offset-of :> offset
    TEMP1 VM offset [+] LDR
    TEMP1 TEMP1 size ADD
    TEMP2 VM offset 2 cells + [+] LDR
    TEMP1 TEMP2 CMP
    cc {
        { cc<= [ label BLE ] }
        { cc/<= [ label BGT ] }
    } case ;

M: arm.64 %call-gc \ minor-gc %call gc-map-here ;

M:: arm.64 %prologue ( n -- )
    FP LR SP n neg [pre] STP
    FP SP MOV ;

M:: arm.64 %epilogue ( n -- )
    FP LR SP n [post] LDP ;

M: arm.64 %safepoint
    SAFEPOINT dup [] STR ;

M: arm.64 test-instruction? t ;

: cc>cond ( cc -- cond )
    order-cc {
        ${ cc<  LT }
        ${ cc<= LE }
        ${ cc>  GT }
        ${ cc>= GE }
        ${ cc=  EQ }
        ${ cc/= NE }
    } at ;

: (%compare-imm) ( src1 src2 -- )
    {
        { [ dup fixnum? ] [ tag-fixnum CMP ] }
        { [ dup not ] [ drop \ f type-number CMP ] }
    } cond ;

:: %boolean ( DST cc TEMP -- )
    DST TEMP (%boolean)
    DST TEMP DST cc CSEL ;

M: arm.64 %compare [ CMP ] [ cc>cond ] [ %boolean ] tri* ;
M:: arm.64 %compare-imm ( DST SRC1 SRC2 cc TEMP -- )
    SRC1 SRC2 (%compare-imm)
    DST cc cc>cond TEMP %boolean ;
M: arm.64 %compare-integer-imm %compare ;

M: arm.64 %test [ TST ] [ cc>cond ] [ %boolean ] tri* ;
M: arm.64 %test-imm %test ;

:: %cset-float<> ( DST TEMP -- )
    DST TEMP (%boolean)
    3 insns BEQ
    2 insns BVS
    DST TEMP MOV ;

:: %cset-float/<> ( DST TEMP -- )
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
        { cc<>   [ DST    TEMP %cset-float<> ] }
        { cc<>=  [ DST VC TEMP %boolean ] }
        { cc/<   [ DST HS TEMP %boolean ] }
        { cc/<=  [ DST HI TEMP %boolean ] }
        { cc/>   [ DST LE TEMP %boolean ] }
        { cc/>=  [ DST LT TEMP %boolean ] }
        { cc/=   [ DST NE TEMP %boolean ] }
        { cc/<>  [ DST    TEMP %cset-float/<> ] }
        { cc/<>= [ DST VS TEMP %boolean ] }
    } case ;

M: arm.64 %compare-float-ordered [ FCMPE ] 2dip (%compare-float) ;
M: arm.64 %compare-float-unordered [ FCMP ] 2dip (%compare-float) ;

M: arm.64 %compare-branch [ CMP ] dip cc>cond B.cond ;
M: arm.64 %compare-imm-branch [ (%compare-imm) ] dip cc>cond B.cond ;
M: arm.64 %compare-integer-imm-branch %compare-branch ;
M: arm.64 %test-branch [ TST ] dip cc>cond B.cond ;
M: arm.64 %test-imm-branch %test-branch ;

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
        { cc=    [ BNE ] }
        { cc/<>  [ %branch-float/<> ] }
        { cc/<>= [ BVS ] }
    } case ;

M: arm.64 %compare-float-ordered-branch [ FCMPE ] dip (%compare-float-branch) ;
M: arm.64 %compare-float-unordered-branch [ FCMP ] dip (%compare-float-branch) ;

M: arm.64 %spill -rot %copy ;
M: arm.64 %reload swap %copy ;

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

M: arm.64 return-regs {
    { int-regs ${ RETURN arg2 } }
    { float-regs ${ V0 } }
} ;

M: arm.64 param-regs drop {
    { int-regs ${ arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 } }
    { float-regs ${ V0 V1 V2 V3 V4 V5 V6 V7 } }
} ;

M: arm.64 return-struct-in-registers? heap-size 2 cells <= ;

M: arm.64 value-struct? drop t ;
M: arm.64 dummy-stack-params? f ;
M: arm.64 dummy-int-params? f ;
M: arm.64 dummy-fp-params? f ;
M: arm.64 long-long-on-stack? f ;
M: arm.64 long-long-odd-register? f ;
M: arm.64 float-right-align-on-stack? f ;
M: arm.64 struct-return-on-stack? f ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;

: %load-reg-param ( VREG rep REG -- ) swap %copy ;

: %load-return ( DST rep -- ) dup return-reg %load-reg-param ;

M:: arm.64 %unbox ( DST SRC func rep -- )
    arg1 SRC tagged-rep %copy
    arg2 VM MOV
    func f f %c-invoke
    DST rep %load-return ;

M:: arm.64 %local-allot ( DST size align offset -- )
    DST SP offset local-allot-offset special-offset ADD ;

M:: arm.64 %box ( DST SRC func rep gc-map -- )
    rep reg-class-of f param-regs at first SRC rep %copy
    rep int-rep? arg2 arg1 ? VM MOV
    func f gc-map %c-invoke
    DST int-rep %load-return ;

M:: arm.64 %save-context ( TEMP1 TEMP2 -- )
    TEMP1 %context
    TEMP2 SP MOV
    ! TEMP2 SP 2 cells SUB
    TEMP2 TEMP1 "callstack-top" context offset-of [+] STR
    DS    TEMP1 "datastack"     context offset-of [+] STR
    RS    TEMP1 "retainstack"   context offset-of [+] STR ;

M: arm.64 %c-invoke [ (LDR=BLR) rel-dlsym ] dip gc-map-here ;

M: arm.64 %alien-invoke '[ _ _ _ %c-invoke ] %alien-assembly ;

M: arm.64 %alien-indirect ( src varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size gc-map -- )
    8 1 nrotd '[
        _ ?spill-slot BLR
        _ gc-map-here
    ] %alien-assembly ;

: %store-reg-param ( vreg rep reg -- ) -rot %copy ;

:: %store-stack-param ( vreg rep n -- )
    rep return-reg vreg rep %copy
    n reserved-stack-space + stack@ rep return-reg rep %copy ;

: %prepare-var-args ( reg-inputs -- ) drop ;

M:: arm.64 %alien-assembly ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-inputs [ first3 %store-stack-param ] each
    reg-inputs [ first3 %store-reg-param ] each
    varargs? [ reg-inputs %prepare-var-args ] when
    quot call( -- )
    reg-outputs [ first3 %load-reg-param ] each ;

:: next-stack@ ( n -- operand )
    FP n 2 cells + reserved-stack-space + [+] ;

:: %load-stack-param ( vreg rep n -- )
    rep return-reg n next-stack@ rep %copy
    vreg rep return-reg rep %copy ;

M: arm.64 %callback-inputs ( reg-outputs stack-outputs -- )
    [ [ first3 %load-reg-param ] each ]
    [ [ first3 %load-stack-param ] each ] bi*
    arg1 VM MOV
    arg2 XZR MOV
    "begin_callback" f f %c-invoke ;

M: arm.64 %callback-outputs ( reg-inputs -- )
    arg1 VM MOV
    "end_callback" f f %c-invoke
    [ first3 %store-reg-param ] each ;

M: arm.64 stack-cleanup 3drop 0 ;

M: arm.64 enable-cpu-features
    enable-min/max
    enable-log2
    enable-bit-test
    enable-alien-4-intrinsics
    enable-float-min/max
    enable-bit-count
    enable-float-intrinsics
    enable-fsqrt ;
