! Copyright (C) 2025 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien assocs classes.struct combinators
compiler.cfg compiler.cfg.comparisons compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stack-frame
compiler.codegen.gc-maps compiler.codegen.labels
compiler.codegen.relocation compiler.constants cpu.architecture
cpu.arm.64.assembler kernel layouts literals math memory
namespaces sequences system vm ;
FROM: cpu.arm.64.assembler => B ;
IN: cpu.arm.64

M: arm.64 enable-cpu-features ( -- )
    ;

M: arm.64 machine-registers ( -- assoc )
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

M: arm.64 %safepoint ( -- )
    SAFEPOINT dup [] STR ;

: loc>operand ( loc -- operand )
    [ ds-loc? DS RS ? ] [ n>> cells neg ] bi [+] ;

M: arm.64 %peek ( DST loc -- )
    loc>operand LDR ;

M: arm.64 immediate-comparand? ( obj -- ? )
    add/sub-immediate? ;

: (%compare-imm) ( SRC1 src2 -- )
    [ tag-fixnum ] [ \ f type-number ] if* CMP ;

: cc>cond ( cc -- cond )
    order-cc {
        ${ cc<  LT }
        ${ cc<= LE }
        ${ cc>  GT }
        ${ cc>= GE }
        ${ cc=  EQ }
        ${ cc/= NE }
    } at ;

: (%boolean) ( DST TEMP -- )
    [ \ f type-number MOV ]
    [ t swap (LDR=) rel-literal ] bi* ;

: %boolean ( DST cc TEMP -- )
    [ nip (%boolean) ] 3keep
    swap overd CSEL ;

M: arm.64 %compare-imm ( DST SRC1 src2 cc TEMP -- )
    [ (%compare-imm) ] [ cc>cond ] [ %boolean ] tri* ;

M: arm.64 %replace ( SRC loc -- )
    loc>operand STR ;

M: arm.64 %return ( -- )
    RET ;

M: arm.64 %inc ( loc -- )
    [ ds-loc? DS RS ? dup ] [ n>> cells ] bi
    dup 0 > [ ADD ] [ neg SUB ] if ;

M: arm.64 %compare-imm-branch ( label SRC1 src2 cc -- )
    [ (%compare-imm) ] dip cc>cond B.cond ;

M: arm.64 immediate-store? ( obj -- ? )
    {
        { [ dup fixnum? ] [ tag-fixnum 16 unsigned-immediate? ] }
        { [ dup not ] [ drop t ] }
        [ drop f ]
    } cond ;

M: arm.64 stack-frame-size ( stack-frame -- n )
    (stack-frame-size) 2 cells + 16 align ;

M: arm.64 %prologue ( n -- )
    [ FP LR SP ] dip neg [pre] STP
    FP SP MOV ;

M: arm.64 %call ( word -- )
    (LDR=BLR) rel-word-pic ;

M: arm.64 %replace-imm ( imm loc -- )
    {
        { [ over 0 = ] [
            nip XZR
            swap
        ] }
        { [ over fixnum? ] [
            [ temp swap tag-fixnum MOV ] dip
            temp swap
        ] }
        { [ swap not ] [
            temp \ f type-number MOV
            temp swap
        ] }
    } cond %replace ;

M: arm.64 %epilogue ( n -- )
    [ FP LR SP ] dip [post] LDP ;

M: arm.64 %jump ( word -- )
    PIC-TAIL 5 insns ADR
    (LDR=BR) rel-word-pic-tail ;

M: arm.64 fused-unboxing? ( -- ? )
    t ;

M: arm.64 %load-reference ( reg obj -- )
    [ swap (LDR=) rel-literal ]
    [ \ f type-number MOV ] if* ;

M: arm.64 %jump-label ( label -- )
    0 B rc-relative-arm-b label-fixup ;

M: arm.64 %load-immediate ( reg val -- )
    [ XZR MOV ] [
        4 <iota> [
            [ -16 * shift 0xffff bitand ] keep
        ] with map>alist [ 0 = ] reject-keys
        unclip overd first2 MOVZ
        [ first2 MOVK ] with each
    ] if-zero ;

M: arm.64 %clear ( loc -- )
    297 swap %replace-imm ;

: stack@ ( n -- op ) SP swap [+] ;

: spill@ ( n -- op ) spill-offset 2 cells + stack@ ;

: ?spill-slot ( obj -- obj ) dup spill-slot? [ n>> spill@ ] when ;

UNION: 64-gr-rep int-rep tagged-rep ;

ERROR: %copy-not-implemented dst src rep ;

M: arm.64 %copy ( dst src rep -- )
    [ [ ?spill-slot ] bi@ ] dip {
        { [ 2over eq? ] [ 3drop ] }
        { [
            3dup [ [ register? ] both? ] [ 64-gr-rep? ] bi* and
        ] [ drop MOV ] }
        { [
            3dup [ offset? ] [ register? ] [ 64-gr-rep? ] tri* and and
        ] [ drop swap STR ] }
        { [
            3dup [ register? ] [ offset? ] [ 64-gr-rep? ] tri* and and
        ] [ drop LDR ] }
        [ %copy-not-implemented ]
    } cond ;

M: arm.64 param-regs ( abi -- regs )
    drop {
        { int-regs ${ X0 X1 X2 X3 X4 X5 X6 X7 } }
        { float-regs ${ V0 V1 V2 V3 V4 V5 V6 V7 } }
    } ;

M: arm.64 return-regs ( -- regs )
    {
        { int-regs ${ X0 X1 } }
        { float-regs ${ V0 } }
    } ;

M: arm.64 stack-cleanup ( stack-size return abi -- n )
    3drop 0 ;

M:: arm.64 %save-context ( TEMP1 TEMP2 -- )
    TEMP1 %context
    TEMP2 SP MOV
    TEMP2 TEMP1 "callstack-top" context offset-of [+] STR
    DS TEMP1 "datastack" context offset-of [+] STR
    RS TEMP1 "retainstack" context offset-of [+] STR ;

M: arm.64 %vm-field ( DST offset -- )
    VM swap [+] LDR ;

M: arm.64 %c-invoke ( symbols dll gc-map -- )
    [ (LDR=BLR) rel-dlsym ] dip gc-map-here ;

: return-reg ( rep -- reg ) reg-class-of return-regs at first ;

:: %store-stack-param ( vreg rep n -- )
    rep return-reg vreg rep %copy
    n stack@ rep return-reg rep %copy ;

: %store-reg-param ( vreg rep reg -- )
    -rot %copy ;

: %prepare-var-args ( reg-inputs -- )
    drop ;

: %load-reg-param ( vreg rep reg -- )
    swap %copy ;

M:: arm.64 %alien-assembly ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size quot -- )
    stack-inputs [ first3 %store-stack-param ] each
    reg-inputs [ first3 %store-reg-param ] each
    varargs? [ reg-inputs %prepare-var-args ] when
    quot call( -- )
    reg-outputs [ first3 %load-reg-param ] each ;

M: arm.64 %alien-invoke ( varargs? reg-inputs stack-inputs reg-outputs dead-outputs cleanup stack-size symbols dll gc-map -- )
    '[ _ _ _ %c-invoke ] %alien-assembly ;

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

M: arm.64 %call-gc ( gc-map -- )
    \ minor-gc %call gc-map-here ;

M: arm.64 %reload ( dst rep src -- )
    swap %copy ;

M:: arm.64 %allot ( ALLOT size class NURSERY -- )
    ALLOT VM "nursery" vm offset-of [+] LDR
    temp ALLOT size data-alignment get align ADD
    temp VM "nursery" vm offset-of [+] STR
    temp class type-number tag-header MOV
    temp ALLOT [] STR
    ALLOT dup class type-number ADD ;

: alien@ ( reg n -- operand )
    cells alien type-number - [+] ;

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

M: arm.64 dummy-stack-params? ( -- ? )
    f ;

M: arm.64 dummy-fp-params? ( -- ? )
    f ;

: %load-return ( DST rep -- )
    dup return-reg %load-reg-param ;

M:: arm.64 %unbox ( DST SRC func rep -- )
    arg1 SRC tagged-rep %copy
    arg2 VM MOV
    func f f %c-invoke
    DST rep %load-return ;

M: arm.64 %spill ( src rep dst -- )
    -rot %copy ;

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

M: arm.64 frame-reg ( -- REG )
    FP ;

:: next-stack@ ( n -- operand )
    temp n 2 cells + [+] ;

:: %load-stack-param ( vreg rep n -- )
    rep return-reg n next-stack@ rep %copy
    vreg rep return-reg rep %copy ;

M: arm.64 %callback-inputs ( reg-outputs stack-outputs -- )
    temp FP [] LDR
    [ [ first3 %load-reg-param ] each ]
    [ [ first3 %load-stack-param ] each ] bi*
    arg1 VM MOV
    arg2 XZR MOV
    "begin_callback" f f %c-invoke ;

M: arm.64 %callback-outputs ( reg-inputs -- )
    arg1 VM MOV
    "end_callback" f f %c-invoke
    [ first3 %store-reg-param ] each ;

M:: arm.64 %box ( DST SRC func rep gc-map -- )
    rep reg-class-of f param-regs at first SRC rep %copy
    rep int-rep? arg2 arg1 ? VM MOV
    func f gc-map %c-invoke
    DST int-rep %load-return ;
