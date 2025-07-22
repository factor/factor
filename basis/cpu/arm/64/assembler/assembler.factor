! Copyright (C) 2024 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs combinators
combinators.short-circuit compiler.codegen.labels
compiler.constants cpu.architecture endian generalizations
grouping kernel make math math.bits math.bitwise math.order
math.parser parser prettyprint.custom prettyprint.sections
sequences sequences.generalizations words.constant ;
FROM: math.bitwise => bits ;
FROM: alien.c-types => float ;
IN: cpu.arm.64.assembler

: insns ( n -- n ) 4 * ; inline

<<
PREDICATE: register-number < integer [ 5 bits ] keep = ;
PREDICATE: register-width < integer power-of-2? ;
TUPLE: register
    { n register-number initial: 0 }
    { width register-width initial: 64 } ;

TUPLE: general-register < register ;
31 <iota> [
    [ [ "X" % # ] "" make create-word-in ]
    [ 64 general-register boa define-constant ] bi
] each

TUPLE: zero-register < general-register ;
TUPLE: stack-register < general-register ;

TUPLE: vector-register < register ;
32 <iota> [
    [ [ "V" % # ] "" make create-word-in ]
    [ 64 vector-register boa define-constant ] bi
] each

TUPLE: fp-register < register ;
>>


: general-prefix ( reg -- str ) width>> { { 32 "W" } { 64 "X" } } at ;
M: general-register pprint* [ [ general-prefix % ] [ n>> # ] bi ] "" make text ;

M: zero-register pprint*
    width>> {
        { 32 [ "WZR" ] }
        { 64 [ "XZR" ] }
        [ [ "ZR" % # ] "" make ]
    } case text ;

M: stack-register pprint*
    width>> {
        { 32 [ "WSP" ] }
        { 64 [ "SP" ] }
        [ [ "SP" % # ] "" make ]
    } case text ;

M: vector-register pprint* [ "V" % n>> # ] "" make text ;

: fp-prefix ( reg -- str ) width>> { { 8 "B" } { 16 "H" } { 32 "S" } { 64 "D" } { 128 "Q" } } at ;
M: fp-register pprint* [ [ fp-prefix % ] [ n>> # ] bi ] "" make text ;


ALIAS: RETURN       X0
ALIAS: arg1         X0
ALIAS: arg2         X1
ALIAS: arg3         X2
ALIAS: arg4         X3
ALIAS: arg5         X4
ALIAS: arg6         X5
ALIAS: arg7         X6
ALIAS: arg8         X7
ALIAS: XR           X8

ALIAS: temp         X9
ALIAS: ds-0         X10
ALIAS: ds-1         X11
ALIAS: ds-2         X12
ALIAS: ds-3         X13
ALIAS: temp1        X14
ALIAS: temp2        X15
ALIAS: quotient     X14
ALIAS: remainder    X15
ALIAS: obj          X14
ALIAS: type         X15
ALIAS: cache        X14

ALIAS: IP0          X16 ! intra-procedure-call register
ALIAS: IP1          X17 ! intra-procedure-call register
ALIAS: PR           X18 ! platform register

ALIAS: VM           X19
ALIAS: CTX          X20
ALIAS: DS           X21
ALIAS: RS           X22
ALIAS: PIC-TAIL     X23
ALIAS: SAFEPOINT    X24
ALIAS: MEGA-HITS    X25
ALIAS: CACHE-MISS   X26
ALIAS: CARDS-OFFSET X27
ALIAS: DECKS-OFFSET X28

ALIAS: FP           X29
ALIAS: LR           X30
CONSTANT: XZR T{ zero-register  f 31 64 }
CONSTANT: SP  T{ stack-register f 31 64 }

ALIAS: fp-temp      V31


ERROR: register-width-error reg ;
: check-32-bit ( reg -- reg ) dup width>> 32 = [ register-width-error ] unless ;
: check-64-bit ( reg -- reg ) dup width>> 64 = [ register-width-error ] unless ;

: >32-bit ( reg -- new-reg ) clone 32 >>width ;
: >64-bit ( reg -- new-reg ) clone 64 >>width ;

ERROR: register-type-error reg ;
: check-zero-register  ( reg -- reg ) dup stack-register? [ register-type-error ] when ;
: check-stack-register ( reg -- reg ) dup  zero-register? [ register-type-error ] when ;

: check-general-register ( reg -- reg ) dup general-register? [ register-type-error ] unless ;
: check-vector-register  ( reg -- reg ) dup vector-register?  [ register-type-error ] unless ;
: check-fp-register      ( reg -- reg ) dup fp-register?      [ register-type-error ] unless ;

: R    ( Rn -- n )              check-general-register                      n>> ;
: W    ( Wn -- n ) check-32-bit check-general-register                      n>> ;
: X    ( Xn -- n ) check-64-bit check-general-register                      n>> ;
: R/ZR ( Rn -- n )              check-general-register check-zero-register  n>> ;
: W/ZR ( Wn -- n ) check-32-bit check-general-register check-zero-register  n>> ;
: X/ZR ( Xn -- n ) check-64-bit check-general-register check-zero-register  n>> ;
: R/SP ( Rn -- n )              check-general-register check-stack-register n>> ;
: W/SP ( Wn -- n ) check-32-bit check-general-register check-stack-register n>> ;
: X/SP ( Xn -- n ) check-64-bit check-general-register check-stack-register n>> ;
: V    ( Vn -- n )              check-vector-register                       n>> ;

: >zero-register ( reg -- new-reg ) width>> 31 swap zero-register boa ;
: insert-zero-register ( Rn operand -- ZR Rn operand ) [ [ >zero-register ] keep ] dip ;
: insert-zero-register* ( Rd operand -- Rd ZR operand ) [ dup >zero-register ] dip ;


GENERIC: encode-type ( reg -- n )

M: general-register encode-type drop 0 ;
M:      fp-register encode-type drop 1 ;


GENERIC: encode-width ( reg -- sf/opc ) ! LDRl

M: general-register encode-width
    width>> {
        { 32 [ 0 ] }
        { 64 [ 1 ] }
        [ register-width-error ]
    } case ;

M: fp-register encode-width
    width>> {
        { 32 [ 0 ] }
        { 64 [ 1 ] }
        { 128 [ 2 ] }
        [ register-width-error ]
    } case ;

M: vector-register encode-width drop 1 ;

ERROR: register-width-mismatch registers ;
<<
: check-registers ( n quot -- quot: ( ... -- ... w ) )
    dupd '[
        _ ndup _ narray dup _ map dup all-equal?
        [ nip first ] [ drop register-width-mismatch ] if
    ] ; inline
>>
MACRO: (nencode-width) ( n -- quot ) [ encode-width ] check-registers ;

: 1encode-width ( Rn -- Rn w ) dup encode-width ;
: 2encode-width ( Rn1 Rn2 -- Rn1 Rn2 w ) 2 (nencode-width) ;
: 3encode-width ( Rn1 Rn2 Rn3 -- Rn1 Rn2 Rn3 w ) 3 (nencode-width) ;
: 4encode-width ( Rn1 Rn2 Rn3 Rn4 -- Rn1 Rn2 Rn3 Rn4 w ) 4 (nencode-width) ;


GENERIC: encode-width* ( reg -- opc VR )

M: general-register encode-width*
    width>> {
        { 32 [ 0 0 ] }
        { 64 [ 2 0 ] }
        [ register-width-error ]
    } case ;

M: fp-register encode-width*
    width>> {
        {  32 [ 0 1 ] }
        {  64 [ 1 1 ] }
        { 128 [ 2 1 ] }
        [ register-width-error ]
    } case ;

M: vector-register encode-width* drop 1 1 ;

ERROR: register-mismatch Rt Rt2 ;
: 2encode-width* ( Rt Rt2 -- Rt Rt2 opc VR )
    [ dup encode-width* ] bi@
    [ [ roll = ] bi@ and [ register-mismatch ] unless ] 2keep ;


GENERIC: encode-width** ( reg -- size VR opc1 shift )

M: general-register encode-width**
    width>> {
        { 32 [ 2 0 0 2 ] }
        { 64 [ 3 0 0 3 ] }
        [ register-width-error ]
    } case ;

M: fp-register encode-width**
    width>> {
        {   8 [ 0 1 0 0 ] }
        {  16 [ 1 1 0 1 ] }
        {  32 [ 2 1 0 2 ] }
        {  64 [ 3 1 0 3 ] }
        { 128 [ 0 1 1 4 ] }
        [ register-width-error ]
    } case ;

M: vector-register encode-width** drop 3 1 0 3 ;


GENERIC: encode-width*** ( reg -- ftype )

M: fp-register encode-width***
    width>> {
        { 16 [ 3 ] }
        { 32 [ 0 ] }
        { 64 [ 1 ] }
        [ register-width-error ]
    } case ;

M: vector-register encode-width*** drop 1 ;

MACRO: (nencode-width***) ( n -- quot ) [ encode-width*** ] check-registers ;
: 1encode-width*** ( R -- R ftype ) dup encode-width*** ;
: 2encode-width*** ( Rd Rn -- Rd Rn ftype ) 2 (nencode-width***) ;
: 3encode-width*** ( Rd Rn Rm -- Rd Rn Rm ftype ) 3 (nencode-width***) ;


ERROR: immediate-width-error n bits ;
: check-unsigned-immediate ( n bits -- n )
    2dup bits pick = [ drop ] [ immediate-width-error ] if ;

: check-signed-immediate ( n bits -- n )
    2dup >signed pick = [ bits ] [ immediate-width-error ] if ;

ERROR: scaling-error n shift ;
: ?>> ( n shift -- n' )
    2dup bits [ neg shift ] [ scaling-error ] if-zero ;


TUPLE: operand register amount type ;

M: operand encode-width register>> encode-width ;

: >operand< ( operand -- register type amount )
    [ register>> ] [ type>> ] [ amount>> ] tri ;

TUPLE: extended-register < operand ;
C: <extended-register> extended-register

: check-Wm ( Wm uimm3 -- Wm uimm3 )
    [ check-32-bit check-general-register check-zero-register ] dip ;
: check-Xm ( Xm uimm3 -- Wm uimm3 )
    [ check-64-bit check-general-register check-zero-register ] dip ;

: <UXTB> ( Rm uimm3 -- er ) check-Wm 0 <extended-register> ;
: <UXTH> ( Rm uimm3 -- er ) check-Wm 1 <extended-register> ;
: <UXTW> ( Rm uimm3 -- er ) check-Wm 2 <extended-register> ;
: <UXTX> ( Rm uimm3 -- er ) check-Xm 3 <extended-register> ;
: <SXTB> ( Rm uimm3 -- er ) check-Wm 4 <extended-register> ;
: <SXTH> ( Rm uimm3 -- er ) check-Wm 5 <extended-register> ;
: <SXTW> ( Rm uimm3 -- er ) check-Wm 6 <extended-register> ;
: <SXTX> ( Rm uimm3 -- er ) check-Xm 7 <extended-register> ;
: <LSL*> ( Rm uimm3 -- er ) over encode-width 2 + <extended-register> ;

TUPLE: shifted-register < operand ;
: <shifted-register> ( Rm amount type -- sr )
    [ over encode-width 5 + check-unsigned-immediate ] dip
    shifted-register boa ;

: <LSL> ( Rm uimm5/6 -- sr ) 0 <shifted-register> ;
: <LSR> ( Rm uimm5/6 -- sr ) 1 <shifted-register> ;
: <ASR> ( Rm uimm5/6 -- sr ) 2 <shifted-register> ;
: <ROR> ( Rm uimm5/6 -- sr ) 3 <shifted-register> ;


TUPLE: offset register offset type ;
C: <offset> offset
: >offset< ( index/offset -- register offset type ) [ register>> ] [ offset>> ] [ type>> ] tri ;

: [post] ( Xn imm -- offset ) 1 <offset> ;
: [pre]  ( Xn imm -- offset ) 3 <offset> ;

GENERIC: [+] ( Xn operand -- offset )
M: integer [+] 0 <offset> ;
M: extended-register [+] 2 <offset> ;
M: register [+] 0 <LSL*> [+] ;

: [] ( Xn -- address ) 0 [+] ;

PREDICATE: register-offset < offset type>> 2 = ;


CONSTANT: EQ  0 ! equal
                ! Z set
CONSTANT: NE  1 ! not equal
                ! Z clear
CONSTANT: HS  2 ! unsigned higher or same
CONSTANT: CS  2 ! C set
CONSTANT: LO  3 ! unsigned lower
CONSTANT: CC  3 ! C clear
CONSTANT: MI  4 ! negative (minus)
                ! N set
CONSTANT: PL  5 ! positive or zero (plus)
                ! N clear
CONSTANT: VS  6 ! overflow
                ! V set
CONSTANT: VC  7 ! no overflow
                ! V clear
CONSTANT: HI  8 ! unsigned higher
                ! C set and Z clear
CONSTANT: LS  9 ! unsigned lower or same
                ! C clear or Z set
CONSTANT: GE 10 ! greater or equal
                ! N equals V
CONSTANT: LT 11 ! less than
                ! N not equal to V
CONSTANT: GT 12 ! greater than
                ! Z clear and N equals V
CONSTANT: LE 13 ! less or equal
                ! Z set or N not equal to V
CONSTANT: AL 14 ! always
CONSTANT: NV 15 ! always (“never”)

CONSTANT: NZCV 0b1101101000010000
CONSTANT: FPSR 0b1101101000100001


GENERIC: ADD  ( Rd Rn operand -- )
GENERIC: ADDS ( Rd Rn operand -- )
GENERIC: SUB  ( Rd Rn operand -- )
GENERIC: SUBS ( Rd Rn operand -- )

GENERIC: NEG  ( Rd operand -- )
GENERIC: NEGS ( Rd operand -- )

M: shifted-register NEG  insert-zero-register* SUB  ;
M: shifted-register NEGS insert-zero-register* SUBS ;

M: register NEG  0 <LSL> NEG ;
M: register NEGS 0 <LSL> NEGS ;

: add/sub-register ( Rd Rn Rm -- Rd Rn operand )
    0 reach reach [ stack-register? ] either? [ <LSL*> ] [ <LSL> ] if ;

M: register ADD  add/sub-register ADD  ;
M: register ADDS add/sub-register ADDS ;
M: register SUB  add/sub-register SUB  ;
M: register SUBS add/sub-register SUBS ;

GENERIC: AND  ( Rn Rm operand -- )
GENERIC: BIC  ( Rn Rm operand -- )
GENERIC: ORR  ( Rn Rm operand -- )
GENERIC: ORN  ( Rn Rm operand -- )
GENERIC: EOR  ( Rn Rm operand -- )
GENERIC: EON  ( Rn Rm operand -- )
GENERIC: ANDS ( Rn Rm operand -- )
GENERIC: BICS ( Rn Rm operand -- )

: CMN ( Rn operand -- ) insert-zero-register ADDS ;
: CMP ( Rn operand -- ) insert-zero-register SUBS ;
: TST ( Rn operand -- ) insert-zero-register ANDS ;

GENERIC: LSL ( Rd Rn operand -- )
GENERIC: LSR ( Rd Rn operand -- )
GENERIC: ASR ( Rd Rn operand -- )
GENERIC: ROR ( Rd Rn operand -- )

GENERIC: STR ( Rt operand -- )
GENERIC: LDR ( Rt operand -- )

GENERIC: STRB ( Rt operand -- )
GENERIC: LDRB ( Rt operand -- )

GENERIC: STRH ( Rt operand -- )
GENERIC: LDRH ( Rt operand -- )

GENERIC: LDRSB ( Rt operand -- )
GENERIC: LDRSH ( Rt operand -- )
GENERIC: LDRSW ( Rt operand -- )

GENERIC#: STR* 1 ( Rt operand c-type -- )
GENERIC#: LDR* 1 ( Rt operand c-type -- )

GENERIC: MOV ( Rd operand -- )


MACRO: encode ( bitspec -- quot ) '[ _ bitfield* 4 >le % ] ;


: split-ADR-immediate ( imm -- immlo immhi )
    [ 2 bits ] [ -2 shift 19 check-signed-immediate ] bi ;

: (ADR) ( Xd imm op -- )
    [ split-ADR-immediate ] dip {
        { 0b10000 24 }
        { X/ZR 0 }
        29
        5
        31
    } encode ;

: ADR  ( Xd imm -- )        0 (ADR) ;
: ADRP ( Xd imm -- ) 12 ?>> 1 (ADR) ;


: unsigned-immediate? ( n bits -- ? ) dupd bits = ;

PREDICATE: unshifted-add/sub-immediate < integer
    12 unsigned-immediate? ;

PREDICATE: shifted-add/sub-immediate < integer
    { [ 0 = not ] [ 12 bits zero? ] [ -12 shift 12 unsigned-immediate? ] } 1&& ;

GENERIC: split-add/sub-immediate ( imm -- sh imm12 )
M: unshifted-add/sub-immediate split-add/sub-immediate 0 swap ;
M: shifted-add/sub-immediate split-add/sub-immediate -12 shift 1 swap ;

: add/sub-imm ( Rd Rn imm opc -- )
    [ 2encode-width ] 2dip [ split-add/sub-immediate ] dip {
        { 0b100010 23 }
        { R 0 }
        { R/SP 5 }
        31
        22
        10
        29
    } encode ;

UNION: add/sub-immediate unshifted-add/sub-immediate shifted-add/sub-immediate ;

M: add/sub-immediate ADD  [ check-stack-register ] 2dip 0 add/sub-imm ;
M: add/sub-immediate ADDS [ check-zero-register  ] 2dip 1 add/sub-imm ;
M: add/sub-immediate SUB  [ check-stack-register ] 2dip 2 add/sub-imm ;
M: add/sub-immediate SUBS [ check-zero-register  ] 2dip 3 add/sub-imm ;


: repeating-element ( imm-bits imm-width -- element-bits element-width )
    [ 2dup 2/ <groups> all-equal? ] [ 2/ ] while [ head ] keep ;

: bit-pairs ( element-bits -- pairs ) 2 <circular-clumps> ;

: transitions ( pairs -- n ) [ all-equal? not ] count ;

: bits-all-equal? ( imm imm-width -- ? )
    [ [ length ] dip = ] [ drop all-equal? ] 2bi and ;

: repeating-element? ( imm-bits imm-width -- ? )
    repeating-element drop bit-pairs transitions 2 = ;

: make-bits* ( imm imm-width -- imm-bits )
    [ bits ] keep <bits> ;

: (logical-immediate?) ( imm imm-width -- ? )
    [ make-bits* ] keep
    { [ bits-all-equal? not ] [ repeating-element? ] } 2&& ;

PREDICATE: logical-32-bit-immediate < integer 32 (logical-immediate?) ;
PREDICATE: logical-64-bit-immediate < integer 64 (logical-immediate?) ;

UNION: logical-immediate
    logical-32-bit-immediate logical-64-bit-immediate ;

:: Nimms ( element-bits element-width -- N imms )
    element-bits [ ] count 1 - :> set-bits
    element-width log2 1 + :> width-exponent
    width-exponent on-bits bitnot set-bits bitor
    6 toggle-bit [ -6 shift 1 bits ] [ 6 bits ] bi ;

: immr ( pairs -- immr )
    [ { f t } sequence= ] find drop bitnot 6 bits ;

ERROR: logical-immediate-error imm imm-width ;
ERROR: element-error element element-width transitions ;
: Nimmrimms ( imm imm-width -- N imms immr )
    [ make-bits* ] keep
    2dup bits-all-equal? [ logical-immediate-error ] when
    repeating-element over bit-pairs
    dup transitions 2 = [ element-error ] unless
    [ Nimms ] [ immr ] bi* ;

: logical-imm ( Rd Rn imm opc -- )
    [ 2encode-width ] 2dip [ pick width>> Nimmrimms ] dip {
        { 0b100100 23 }
        { R 0 }
        { R/ZR 5 }
        31
        22
        10
        16
        29
    } encode ;

M: logical-immediate AND  [ check-stack-register ] 2dip 0 logical-imm ;
M: logical-immediate ORR  [ check-stack-register ] 2dip 1 logical-imm ;
M: logical-immediate EOR  [ check-stack-register ] 2dip 2 logical-imm ;
M: logical-immediate ANDS [ check-zero-register  ] 2dip 3 logical-imm ;


: move-wide-imm ( Rd imm16 hw opc -- )
    [ 1encode-width ] 3dip [ pick 1 + check-unsigned-immediate ] dip {
        { 0b100101 23 }
        { R/ZR 0 }
        31
        5
        21
        29
    } encode ;

: MOVN ( Rd imm16 hw -- ) 0 move-wide-imm ;
: MOVZ ( Rd imm16 hw -- ) 2 move-wide-imm ;
: MOVK ( Rd imm16 hw -- ) 3 move-wide-imm ;

M: integer MOV 0 MOVZ ;


: bitfield ( Rd Rn immr imms opc -- )
    [ 2encode-width dup ] 3dip {
        { 0b100110 23 }
        { R/ZR 0 }
        { R/ZR 5 }
        31
        22
        16
        10
        29
    } encode ;

: SBFM ( Rd Rn immr imms -- ) 0 bitfield ;
:  BFM ( Rd Rn immr imms -- ) 1 bitfield ;
: UBFM ( Rd Rn immr imms -- ) 2 bitfield ;

ERROR: immediate-error n ;
:: UBFIZ ( Rd Rn lsb width -- )
    Rn encode-width 5 + :> max-width
    lsb max-width check-unsigned-immediate drop
    width dup 1 max-width 2^ lsb - between? [ immediate-error ] unless drop
    Rd Rn lsb neg max-width bits width 1 - UBFM ;

M:: integer LSL ( Rd Rn shift -- )
    Rn encode-width 5 + :> max-width
    shift max-width check-unsigned-immediate drop
    Rd Rn shift bitnot max-width bits [ 1 + ] keep UBFM ;

M:: integer LSR ( Rd Rn shift -- )
    Rn encode-width 5 + :> max-width
    shift max-width check-unsigned-immediate drop
    Rd Rn shift max-width on-bits UBFM ;

M:: integer ASR ( Rd Rn shift -- )
    Rn encode-width 5 + :> max-width
    shift max-width check-unsigned-immediate drop
    Rd Rn shift max-width on-bits SBFM ;


: conditional-branch ( imm19 cond op -- )
    [ 2 ?>> 19 check-signed-immediate ] 2dip {
        { 0b0101010 25 }
        5
        0
        4
    } encode ;

GENERIC#: B.cond 1 ( label/imm19 cond -- )
M: integer B.cond 0 conditional-branch ;
M: label B.cond [ 0 ] dip B.cond rc-relative-arm-b.cond/ldr label-fixup ;

: BEQ ( imm19 -- ) EQ B.cond ;
: BNE ( imm19 -- ) NE B.cond ;
: BHS ( imm19 -- ) HS B.cond ;
: BLO ( imm19 -- ) LO B.cond ;
: BVS ( imm19 -- ) VS B.cond ;
: BVC ( imm19 -- ) VC B.cond ;
: BHI ( imm19 -- ) HI B.cond ;
: BLS ( imm19 -- ) LS B.cond ;
: BGE ( imm19 -- ) GE B.cond ;
: BLT ( imm19 -- ) LT B.cond ;
: BGT ( imm19 -- ) GT B.cond ;
: BLE ( imm19 -- ) LE B.cond ;


: exception ( imm16 opc op2 LL -- )
    [ 16 check-unsigned-immediate ] 3dip {
        { 0b11010100 24 }
        5
        21
        2
        0
    } encode ;

: BRK ( imm16 -- ) 1 0 0 exception ;


: hint ( CRm op2 -- )
    {
        { 0b11010101000000110010 12 }
        { 0b11111 0 }
        8
        5
    } encode ;

: NOP ( -- ) 0 0 hint ;


: system-register-move ( Rt o0:op1:CRn:CRm:op2 L -- )
    {
        { 0b1101010100 22 }
        { X/ZR 0 }
        5
        21
    } encode ;

: MSR ( o0:op1:CRn:CRm:op2 Rt -- ) swap 0 system-register-move ;
: MRS ( Rt o0:op1:CRn:CRm:op2 -- ) 1 system-register-move ;


: unconditional-branch-reg ( Rn opc -- )
    {
        { 0b1101011 25 }
        { 0b11111 16 }
        { X/ZR 5 }
        21
    } encode ;

: BR    ( Xn -- ) 0 unconditional-branch-reg ;
: BLR   ( Xn -- ) 1 unconditional-branch-reg ;
: (RET) ( Xn -- ) 2 unconditional-branch-reg ;

: RET ( -- ) LR (RET) ;


: unconditional-branch-imm ( imm26 op -- )
    [ 2 ?>> 26 check-signed-immediate ] dip {
        { 0b00101 26 }
        0
        31
    } encode ;

GENERIC: B  ( label/imm19 -- )
GENERIC: BL ( label/imm19 -- )

M: integer B  0 unconditional-branch-imm ;
M: integer BL 1 unconditional-branch-imm ;

M: label B  0 B  rc-relative-arm-b label-fixup ;
M: label BL 0 BL rc-relative-arm-b label-fixup ;


! Pseudo load with immediate literal pool
: (LDR=) ( Rt -- class )
    [ 2 insns LDR ] [
        encode-width
        [ 2 + insns B ]
        [ 1 + insns 0 <array> % ]
        [ 0 = rc-absolute rc-absolute-cell ? ] tri
    ] bi ;

: LDR= ( Rt -- word class ) f swap (LDR=) ;

! literal load and call
: (LDR=BLR) ( -- class )
    temp 3 insns LDR
    temp BLR
    3 insns B
    8 0 <array> % rc-absolute-cell ;

: LDR=BLR ( -- word class ) f (LDR=BLR) ;

! literal load and jump
: (LDR=BR) ( -- class )
    temp 2 insns LDR
    temp BR
    8 0 <array> % rc-absolute-cell ;

: LDR=BR ( -- word class ) f (LDR=BR) ;


: compare-and-branch ( Rt imm19 op -- )
    [ 1encode-width ] 2dip [ 2 ?>> 19 check-signed-immediate ] dip {
        { 0b011010 25 }
        { R/ZR 0 }
        31
        5
        24
    } encode ;

GENERIC: CBZ  ( Rt label/imm19 -- )
GENERIC: CBNZ ( Rt label/imm19 -- )

M: integer CBZ  0 compare-and-branch ;
M: integer CBNZ 1 compare-and-branch ;

M: label CBZ  [ 0 CBZ  ] dip rc-relative-arm-b.cond/ldr label-fixup ;
M: label CBNZ [ 0 CBNZ ] dip rc-relative-arm-b.cond/ldr label-fixup ;


: test-and-branch ( Rt imm6 imm14 op -- )
    [ [ -5 shift ] [ 5 bits ] bi ] 2dip
    [ 2 ?>> 14 check-signed-immediate ] dip {
        { 0b011011 25 }
        { R/ZR 0 }
        31
        19
        5
        24
    } encode ;

: TBZ  ( Rt imm6 imm14 -- ) 0 test-and-branch ;
: TBNZ ( Rt imm6 imm14 -- ) 1 test-and-branch ;


: load-register-literal ( Rt imm19 opc VR -- )
    [ 2 ?>> 19 check-signed-immediate ] 2dip {
        { 0b011 27 }
        { R/ZR 0 }
        5
        30
        26
    } encode ;

M: integer LDR over [ encode-width ] [ encode-type ] bi load-register-literal ;
M: integer LDRSW 2 0 load-register-literal ;


: load/store-pair ( Rt Rt2 offset L -- )
    [
        [ 2encode-width* ] dip >offset< dup 0 = [ drop 2 ] when
        [ reach reach + 1 + ?>> 7 check-signed-immediate ] dip
    ] dip {
        { 0b101 27 }
        { R/ZR 0 }
        { R/ZR 10 }
        30
        26
        { X/SP 5 }
        15
        23
        22
    } encode ;

: STP ( Rt Rt2 offset -- ) 0 load/store-pair ;
: LDP ( Rt Rt2 offset -- ) 1 load/store-pair ;


: load/store-register-unsigned-offset ( Rt size VR opc1 Rn offset L -- )
    {
        { 0b111 27 }
        { 0b01 24 }
        { n>> 0 }
        30
        26
        23
        { X/SP 5 }
        10
        22
    } encode ;

: ((load/store-register)) ( Rt size VR opc1 Rn offset type L -- )
    [ 9 check-signed-immediate ] 2dip {
        { 0b111 27 }
        { n>> 0 }
        30
        26
        23
        { X/SP 5 }
        12
        10
        22
    } encode ;

: LDUR ( Rt operand -- )
    [ dup encode-width** drop ] [ >offset< ] bi* 1 ((load/store-register)) ;

:: (load/store-register) ( Rt operand size VR opc1 sh L -- )
    operand >offset< :> ( Rn offset type )
    offset sh neg shift :> scaled-offset
    {
        [ type 0 = ]
        [ offset sh bits 0 = ]
        [ scaled-offset 12 bits scaled-offset = ]
    } 0&& [
        Rt size VR opc1 Rn scaled-offset L
        load/store-register-unsigned-offset
    ] [
        Rt size VR opc1 Rn offset type L
        ((load/store-register))
    ] if ;

M: offset STRB 0 0 0 0 0 (load/store-register) ;
M: offset LDRB 0 0 0 0 1 (load/store-register) ;

M: offset STRH 1 0 0 1 0 (load/store-register) ;
M: offset LDRH 1 0 0 1 1 (load/store-register) ;

M: offset LDRSB 0 0 1 0 0 (load/store-register) ;
M: offset LDRSH 1 0 1 1 0 (load/store-register) ;
M: offset LDRSW 2 0 1 2 0 (load/store-register) ;

: load/store-register ( Rt operand L -- )
    [ over encode-width** ] dip (load/store-register) ;

M: offset STR 0 load/store-register ;
M: offset LDR 1 load/store-register ;

ERROR: unknown-c-type c-type ;
: encode-c-type ( c-type L -- size VR opc1 sh L )
    [ {
        { uchar      [ 0 0 0 0 ] }
        { char       [ 0 0 1 0 ] }
        { ushort     [ 1 0 0 1 ] }
        { short      [ 1 0 1 1 ] }
        { uint       [ 2 0 0 2 ] }
        { int        [ 2 0 1 2 ] }
        { ulonglong  [ 3 0 0 3 ] }
        { longlong   [ 3 0 0 3 ] }
        { int-rep    [ 3 0 0 3 ] }
        { tagged-rep [ 3 0 0 3 ] }
        { float      [ 2 1 0 2 ] }
        { float-rep  [ 2 1 0 2 ] }
        { double     [ 3 1 0 3 ] }
        { double-rep [ 3 1 0 3 ] }
        { vector-rep [ 4 1 0 4 ] }
        [ unknown-c-type ]
    } case ] dip
    dup 0 = [ [ drop 0 ] 2dip ] when ;

: load/store-register* ( Rt operand c-type L -- )
    encode-c-type (load/store-register) ;

M: offset STR* 0 load/store-register* ;
M: offset LDR* 1 load/store-register* ;

: >S ( amount size -- S )
    {
        { [ 2dup = ] [ 2drop 1 ] }
        { [ over 0 = ] [ 2drop 0 ] }
        [ scaling-error ]
    } cond ;

: (load/store-register-register) ( Rt operand size VR opc1 L -- )
    [ >offset< [ >operand< ] dip ] 4dip
    [ tuck [ >S ] 2dip ] 3dip {
        { 0b111 27 }
        { 0b1 21 }
        { n>> 0 }
        { X/SP 5 }
        { R/ZR 16 }
        13
        12
        10
        30
        26
        23
        22
    } encode ;

M: register-offset STRB 0 0 0 0 (load/store-register-register) ;
M: register-offset LDRB 0 0 0 1 (load/store-register-register) ;

M: register-offset STRH 1 0 0 0 (load/store-register-register) ;
M: register-offset LDRH 1 0 0 1 (load/store-register-register) ;

M: register-offset LDRSB 0 0 1 0 (load/store-register-register) ;
M: register-offset LDRSH 1 0 1 0 (load/store-register-register) ;
M: register-offset LDRSW 2 0 1 0 (load/store-register-register) ;

: load/store-register-register ( Rt operand L -- )
    [ over encode-width** drop ] dip (load/store-register-register) ;

M: register-offset STR 0 load/store-register-register ;
M: register-offset LDR 1 load/store-register-register ;

: load/store-register-register* ( Rt operand c-type L -- )
    encode-c-type nip (load/store-register-register) ;

M: register-offset STR* 0 load/store-register-register* ;
M: register-offset LDR* 1 load/store-register-register* ;


: data-processing-2-sources ( Rd Rn Rm opcode -- )
    [ 3encode-width ] dip {
        { 0b11010110 21 }
        { R/ZR 0 }
        { R/ZR 5 }
        { R/ZR 16 }
        31
        10
    } encode ;

: UDIV ( Rd Rn Rm -- ) 0b000010 data-processing-2-sources ;
: SDIV ( Rd Rn Rm -- ) 0b000011 data-processing-2-sources ;
: LSLV ( Rd Rn Rm -- ) 0b001000 data-processing-2-sources ;
: LSRV ( Rd Rn Rm -- ) 0b001001 data-processing-2-sources ;
: ASRV ( Rd Rn Rm -- ) 0b001010 data-processing-2-sources ;
: RORV ( Rd Rn Rm -- ) 0b001011 data-processing-2-sources ;

M: register LSL LSLV ;
M: register LSR LSRV ;
M: register ASR ASRV ;
M: register ROR RORV ;


: data-processing-1-source ( Rd Rn opcode -- )
    [ 2encode-width ] dip {
        { 0b1011010110 21 }
        { R/ZR 0 }
        { R/ZR 5 }
        31
        10
    } encode ;

: CLZ ( Rd Rn -- ) 0b000100 data-processing-1-source ;
: CLS ( Rd Rn -- ) 0b000101 data-processing-1-source ;


: logical-shifted-register ( Rd Rn operand opc N -- )
    [ >operand< [ 3encode-width ] 2dip ] 2dip {
        { 0b01010 24 }
        { R/ZR 0 }
        { R/ZR 5 }
        { R/ZR 16 }
        31
        22
        10
        29
        21
    } encode ;

M: shifted-register AND  0 0 logical-shifted-register ;
M: shifted-register BIC  0 1 logical-shifted-register ;
M: shifted-register ORR  1 0 logical-shifted-register ;
M: shifted-register ORN  1 1 logical-shifted-register ;
M: shifted-register EOR  2 0 logical-shifted-register ;
M: shifted-register EON  2 1 logical-shifted-register ;
M: shifted-register ANDS 3 0 logical-shifted-register ;
M: shifted-register BICS 3 1 logical-shifted-register ;

M: register AND  0 <LSL> AND  ;
M: register BIC  0 <LSL> BIC  ;
M: register ORR  0 <LSL> ORR  ;
M: register ORN  0 <LSL> ORN  ;
M: register EOR  0 <LSL> EOR  ;
M: register EON  0 <LSL> EON  ;
M: register ANDS 0 <LSL> ANDS ;
M: register BICS 0 <LSL> BICS ;

M: register MOV ( Rd register -- )
    2dup [ stack-register? ] either?
    [ 0 ADD ] [ insert-zero-register* ORR ] if ;

: MVN ( Rd operand -- ) insert-zero-register* ORN ;


: add/sub-shifted-register ( Rd Rn operand op -- )
    [ >operand< ] dip [ 3encode-width ] 3dip {
        { 0b01011 24 }
        { R/ZR 0 }
        { R/ZR 5 }
        { R/ZR 16 }
        31
        22
        10
        29
    } encode ;

M: shifted-register ADD  0 add/sub-shifted-register ;
M: shifted-register ADDS 1 add/sub-shifted-register ;
M: shifted-register SUB  2 add/sub-shifted-register ;
M: shifted-register SUBS 3 add/sub-shifted-register ;


: add/sub-extended-register ( Rd Rn operand op -- )
    [ >operand< ] dip [ 3encode-width ] 3dip {
        { 0b01011001 21 }
        { R/SP 0 }
        { R/SP 5 }
        { R/ZR 16 }
        31
        13
        10
        29
    } encode ;

M: extended-register ADD  0 add/sub-extended-register ;
M: extended-register ADDS 1 add/sub-extended-register ;
M: extended-register SUB  2 add/sub-extended-register ;
M: extended-register SUBS 3 add/sub-extended-register ;


: conditional-select ( Rd Rn Rm cond op op2 -- )
    [ 3encode-width ] 3dip {
        { 0b11010100 21 }
        { R/ZR 0 }
        { R/ZR 5 }
        { R/ZR 16 }
        31
        12
        30
        10
    } encode ;

: CSEL  ( Rd Rn Rm cond -- ) 0 0 conditional-select ;
: CSINC ( Rd Rn Rm cond -- ) 0 1 conditional-select ;
: CSINV ( Rd Rn Rm cond -- ) 1 0 conditional-select ;
: CSNEG ( Rd Rn Rm cond -- ) 1 1 conditional-select ;


: data-processing-3-sources ( Rd Rn Rm Ra op -- )
    [ 4encode-width ] dip {
        { 0b11011 24 }
        { R/ZR 0 }
        { R/ZR 5 }
        { R/ZR 16 }
        { R/ZR 10 }
        31
        15
    } encode ;

: MADD ( Rd Rn Rm Ra -- ) 0 data-processing-3-sources ;
: MSUB ( Rd Rn Rm Ra -- ) 1 data-processing-3-sources ;

: MUL ( Rd Rn Rm -- ) dup >zero-register MADD ;

: data-processing-3-sources* ( Xd Xn Xm op -- )
    {
        { 0b1 31 }
        { 0b11011 24 }
        { 0b11111 10 }
        { X/ZR 0 }
        { X/ZR 5 }
        { X/ZR 16 }
        21
    } encode ;

: SMULH ( Xd Xn Xm -- ) 2 data-processing-3-sources* ;
: UMULH ( Xd Xn Xm -- ) 6 data-processing-3-sources* ;


: FMOVgen ( Rd Rn -- )
    2dup dup general-register?
    [ [ swap ] when [ encode-width ] [ encode-width*** ] bi* ]
    [ 1 0 ? ] bi {
        { 0b11110 24 }
        { 0b1 21 }
        { R 0 }
        { R 5 }
        31
        22
        16
    } encode ;

: FMOVr ( Rd Rn -- )
    2encode-width*** {
        { 0b11110 24 }
        { 0b1 21 }
        { 0b10000 10 }
        { R 0 }
        { R 5 }
        22
    } encode ;

: FMOV ( Rd Rn -- ) 2dup [ general-register? ] either? [ FMOVgen ] [ FMOVr ] if ;


: FCVTZSsi ( Rd Rn -- )
    [ 1encode-width ] bi@ {
        { 0b11110 24 }
        { 0b1 21 }
        { 0b11 19 }
        { 0b000 16 }
        { R 0 }
        31
        { n>> 5 }
        22
    } encode ;

: SCVTFsi ( Rd Rn -- )
    [ 1encode-width ] bi@ {
        { 0b11110 24 }
        { 0b1 21 }
        { 0b00 19 }
        { 0b010 16 }
        { n>> 0 }
        22
        { R 5 }
        31
    } encode ;

: fp-data-processing-1-source ( Rd Rn ftype opc op -- )
    {
        { 0b11110 24 }
        { 0b1 21 }
        { 0b10000 10 }
        { n>> 0 }
        { n>> 5 }
        22
        15
        17
    } encode ;

: FSQRTs ( Rd Rn -- ) 2encode-width*** 3 0 fp-data-processing-1-source ;

: FCVT ( Rd Rn -- ) 2dup [ encode-width*** ] bi@ swap 1 fp-data-processing-1-source ;


: fp-compare ( Rn Rm opcode -- )
    [ 2encode-width*** ] dip {
        { 0b11110 24 }
        { 0b1 21 }
        { 0b1000 10 }
        { n>> 5 }
        { n>> 16 }
        22
        4
    } encode ;

: FCMP  ( Rn Rm -- ) 0 fp-compare ;
: FCMPE ( Rn Rm -- ) 1 fp-compare ;


: fp-data-processing-2-sources ( Rd Rn Rm opcode -- )
    [ 3encode-width*** ] dip {
        { 0b11110 24 }
        { 0b1 21 }
        { 0b10 10 }
        { n>> 0 }
        { n>> 5 }
        { n>> 16 }
        22
        12
    } encode ;

: FMULs ( Rd Rn Rm -- ) 0 fp-data-processing-2-sources ;
: FDIVs ( Rd Rn Rm -- ) 1 fp-data-processing-2-sources ;
: FADDs ( Rd Rn Rm -- ) 2 fp-data-processing-2-sources ;
: FSUBs ( Rd Rn Rm -- ) 3 fp-data-processing-2-sources ;
: FMAXs ( Rd Rn Rm -- ) 4 fp-data-processing-2-sources ;
: FMINs ( Rd Rn Rm -- ) 5 fp-data-processing-2-sources ;


: simd-scalar-2-misc ( Rd Rn size0 U size1 opcode -- )
    {
        { 0b01 30 }
        { 0b11110 24 }
        { 0b10000 17 }
        { 0b10 10 }
        { V 0 }
        { V 5 }
        22
        19
        23
        12
    } encode ;

: FCVTZSvi ( Rd Rn spec* -- ) 0 1 0b11011 simd-scalar-2-misc ;
: SCVTFvi  ( Rd Rn spec  -- ) 0 0 0b11101 simd-scalar-2-misc ;


: simd-table-lookup ( Rd Rn Rm op2 len op -- )
    {
        { 0b1001110 24 }
        { V 0 }
        { V 5 }
        { V 16 }
        22
        13
        12
    } encode ;

: TBL ( Rd Rn Rm -- ) 0 0 0 simd-table-lookup ;
: TBX ( Rd Rn Rm -- ) 0 0 1 simd-table-lookup ;


: simd-permute ( Rd Rn Rm size opcode -- )
    {
        { 0b1 30 }
        { 0b001110 24 }
        { 0b10 10 }
        { V 0 }
        { V 5 }
        { V 16 }
        22
        12
    } encode ;

: TRN1 ( Rd Rn Rm spec -- ) 0b010 simd-permute ;
: TRN2 ( Rd Rn Rm spec -- ) 0b110 simd-permute ;


: simd-extract ( Rd Rn Rm imm4 op2 -- )
    {
        { 0b1 30 }
        { 0b101110 24 }
        { V 0 }
        { V 5 }
        { V 16 }
        11
        22
    } encode ;

: EXT ( Rd Rn Rm imm4 -- ) 0 simd-extract ;


: simd-copy ( Rd Rn imm5 imm4 op -- )
    {
        { 0b1 30 }
        { 0b01110000 21 }
        { 0b1 10 }
        { V 0 }
        { V 5 }
        16
        11
        29
    } encode ;

: INSgen ( Rd Rn imm rep -- )
    scalar-rep-of rep-size log2 [ 5 swap - check-unsigned-immediate ] keep
    [ shift ] [ 2^ bitor ] bi 0b0011 0 simd-copy ;

: INSelt ( Rd Rn immd immn rep -- )
    scalar-rep-of rep-size log2
    [ 5 swap - '[ _ check-unsigned-immediate ] bi@ ] keep
    [ [ shift ] [ 2^ bitor ] bi ] [ 1 - log2 shift ] bi-curry bi*
    1 simd-copy ;

: simd-copy* ( Rd Rn imm5 rep imm4 op -- )
    [
        [ 1encode-width ] 3dip
        scalar-rep-of rep-size log2 [ 5 swap - check-unsigned-immediate ] keep
        [ shift ] [ 2^ bitor ] bi
    ] 2dip {
        { 0b01110000 21 }
        { 0b1 10 }
        { R 0 }
        30
        { V 5 }
        16
        11
        29
    } encode ;

: SMOV ( Rd Rn imm rep -- ) 0b0101 0 simd-copy* ;
: UMOV ( Rd Rn imm rep -- ) 0b0111 0 simd-copy* ;


: simd-3-ext ( Rd Rn Rm size U opcode -- )
    {
        { 0b1 30 }
        { 0b01110 24 }
        { 0b1 15 }
        { 0b1 10 }
        { V 0 }
        { V 5 }
        { V 16 }
        22
        29
        11
    } encode ;

: SDOT ( Rd Rn Rm size -- ) 0 2 simd-3-ext ;
: UDOT ( Rd Rn Rm size -- ) 1 2 simd-3-ext ;


: simd-2-misc ( Rd Rn size0 U size1 opcode Q -- )
    {
        { 0b01110 24 }
        { 0b10000 17 }
        { 0b10 10 }
        { V 0 }
        { V 5 }
        22
        29
        23
        12
        30
    } encode ;

: CNTv    ( Rd Rn -- )    0 0 0 0b00101 1 simd-2-misc ;
: ABSv    ( Rd Rn size -- ) 0 0 0b01011 1 simd-2-misc ;
: SQXTN   ( Rd Rn size -- ) 0 0 0b10100 0 simd-2-misc ;
: SQXTN2  ( Rd Rn size -- ) 0 0 0b10100 1 simd-2-misc ;
: FCVTN   ( Rd Rn size -- ) 0 0 0b10110 1 simd-2-misc ;
: FABSv   ( Rd Rn size -- ) 0 1 0b01111 1 simd-2-misc ;
: MVNv    ( Rd Rn -- )    0 1 0 0b00101 1 simd-2-misc ;
: NEGv    ( Rd Rn size -- ) 1 0 0b01011 1 simd-2-misc ;
: SQXTUN  ( Rd Rn size -- ) 1 0 0b10010 0 simd-2-misc ;
: SQXTUN2 ( Rd Rn size -- ) 1 0 0b10010 1 simd-2-misc ;
: SHLL    ( Rd Rn size -- ) 1 0 0b10011 0 simd-2-misc ;
: FSQRTv  ( Rd Rn size -- ) 1 1 0b11111 1 simd-2-misc ;


: simd-across-lanes ( Rd Rn size U opcode -- )
    {
        { 0b1 30 }
        { 0b01110 24 }
        { 0b11000 17 }
        { 0b10 10 }
        { V 0 }
        { V 5 }
        22
        29
        12
    } encode ;

: ADDV ( Rd Rn size -- ) 0 0b11011 simd-across-lanes ;


: simd-3-same ( Rd Rn Rm size0 U size1 opcode -- )
    {
        { 0b1 30 }
        { 0b01110 24 }
        { 0b1 21 }
        { 0b1 10 }
        { V 0 }
        { V 5 }
        { V 16 }
        22
        29
        23
        11
    } encode ;

: SHADD ( Rd Rn Rm size -- ) 0 0 0b00000 simd-3-same ;
: SQADD ( Rd Rn Rm size -- ) 0 0 0b00001 simd-3-same ;
: ANDv  ( Rd Rn Rm -- )    0 0 0 0b00011 simd-3-same ;
: SQSUB ( Rd Rn Rm size -- ) 0 0 0b00101 simd-3-same ;
: CMGT  ( Rd Rn Rm size -- ) 0 0 0b00110 simd-3-same ;
: CMGE  ( Rd Rn Rm size -- ) 0 0 0b00111 simd-3-same ;
: SSHL  ( Rd Rn Rm size -- ) 0 0 0b01000 simd-3-same ;
: SMAXv ( Rd Rn Rm size -- ) 0 0 0b01100 simd-3-same ;
: SMINv ( Rd Rn Rm size -- ) 0 0 0b01101 simd-3-same ;
: SABD  ( Rd Rn Rm size -- ) 0 0 0b01110 simd-3-same ;
: ADDv  ( Rd Rn Rm size -- ) 0 0 0b10000 simd-3-same ;
: MULv  ( Rd Rn Rm size -- ) 0 0 0b10011 simd-3-same ;
: ADDPv ( Rd Rn Rm size -- ) 0 0 0b10111 simd-3-same ;
: FADDv ( Rd Rn Rm size -- ) 0 0 0b11010 simd-3-same ;
: FCMEQ ( Rd Rn Rm size -- ) 0 0 0b11100 simd-3-same ;
: FMAXv ( Rd Rn Rm size -- ) 0 0 0b11110 simd-3-same ;
: FSUBv ( Rd Rn Rm size -- ) 0 1 0b11010 simd-3-same ;
: FMINv ( Rd Rn Rm size -- ) 0 1 0b11110 simd-3-same ;
: UHADD ( Rd Rn Rm size -- ) 1 0 0b00000 simd-3-same ;
: UQADD ( Rd Rn Rm size -- ) 1 0 0b00001 simd-3-same ;
: EORv  ( Rd Rn Rm -- )    0 1 0 0b00011 simd-3-same ;
: UQSUB ( Rd Rn Rm size -- ) 1 0 0b00101 simd-3-same ;
: CMHI  ( Rd Rn Rm size -- ) 1 0 0b00110 simd-3-same ;
: CMHS  ( Rd Rn Rm size -- ) 1 0 0b00111 simd-3-same ;
: USHL  ( Rd Rn Rm size -- ) 1 0 0b01000 simd-3-same ;
: UMAXv ( Rd Rn Rm size -- ) 1 0 0b01100 simd-3-same ;
: UMINv ( Rd Rn Rm size -- ) 1 0 0b01101 simd-3-same ;
: UABD  ( Rd Rn Rm size -- ) 1 0 0b01110 simd-3-same ;
: SUBv  ( Rd Rn Rm size -- ) 1 0 0b10000 simd-3-same ;
: CMEQ  ( Rd Rn Rm size -- ) 1 0 0b10001 simd-3-same ;
: FMULv ( Rd Rn Rm size -- ) 1 0 0b11011 simd-3-same ;
: FCMGE ( Rd Rn Rm size -- ) 1 0 0b11100 simd-3-same ;
: FDIVv ( Rd Rn Rm size -- ) 1 0 0b11111 simd-3-same ;
: FCMGT ( Rd Rn Rm size -- ) 1 1 0b11100 simd-3-same ;
: BICv  ( Rd Rn Rm -- )    1 0 0 0b00011 simd-3-same ;
: ORRv  ( Rd Rn Rm -- )    2 0 0 0b00011 simd-3-same ;


: simd-shift-by-imm ( Rd Rn imm rep U opcode Q -- )
    [ scalar-rep-of rep-size 3 shift bitor ] 3dip {
        { 0b011110 23 }
        { 0b1 10 }
        { V 0 }
        { V 5 }
        16
        29
        11
        30
    } encode ;

: SSHR  ( Rd Rn imm rep -- ) 0 0b00000 1 simd-shift-by-imm ;
: SHL   ( Rd Rn imm rep -- ) 0 0b01010 1 simd-shift-by-imm ;
: SSHLL ( Rd Rn imm rep -- ) 0 0b10100 1 simd-shift-by-imm ;
: USHR  ( Rd Rn imm rep -- ) 1 0b00000 1 simd-shift-by-imm ;

: SXTL ( Rd Rn rep -- ) 0 swap SSHLL ;
