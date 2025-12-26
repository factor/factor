! Copyright (C) 2025 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators kernel math math.bitwise
math.parser parser prettyprint.custom prettyprint.sections
sequences words.constant ;
IN: cpu.arm.64.assembler.registers

<<
<PRIVATE
PREDICATE: register-number < integer [ 5 bits ] keep = ;
PREDICATE: register-width < integer power-of-2? ;
PRIVATE>

TUPLE: register { n register-number initial: 0 } { width register-width initial: 64 } ;
TUPLE: general-register < register ;
TUPLE: zero-register < general-register ;
TUPLE: stack-register < general-register ;
TUPLE: fp-register < register ;
TUPLE: vector-register < register ;

<PRIVATE GENERIC: register-prefix ( reg -- str ) PRIVATE>

M: general-register register-prefix width>> { { 32 "W" } { 64 "X" } } at ;

M: fp-register register-prefix
    width>> { { 8 "B" } { 16 "H" } { 32 "S" } { 64 "D" } { 128 "Q" } } at ;

M: vector-register register-prefix drop "V" ;

M: register pprint* [ register-prefix ] [ n>> >dec ] bi append text ;

M: zero-register pprint*
    width>> {
        { 32 [ "WZR" ] }
        { 64 [ "XZR" ] }
    } case text ;

M: stack-register pprint*
    width>> {
        { 32 [ "WSP" ] }
        { 64 [ "SP" ] }
    } case text ;

<PRIVATE
: define-register ( prefix n width class -- )
    [ [ >dec append create-word-in ] keep ] 2dip
    boa define-constant ; inline

: define-general-registers ( prefix width -- )
    [ 31 <iota> ] dip
    '[ _ general-register define-register ] with each ;

: define-fp/simd-registers ( prefix width class -- )
    [ 32 <iota> ] 2dip '[ _ _ define-register ] with each ; inline
PRIVATE>

"W"  32                 define-general-registers
"X"  64                 define-general-registers

"B"   8 fp-register     define-fp/simd-registers
"H"  16 fp-register     define-fp/simd-registers
"S"  32 fp-register     define-fp/simd-registers
"D"  64 fp-register     define-fp/simd-registers
"Q" 128 fp-register     define-fp/simd-registers

"V" 128 vector-register define-fp/simd-registers
>>

ALIAS: PR  X18
ALIAS: FP  X29
ALIAS: LR  X30

CONSTANT: WZR T{ zero-register  f 31 32 }
CONSTANT: XZR T{ zero-register  f 31 64 }
CONSTANT: WSP T{ stack-register f 31 32 }
CONSTANT: SP  T{ stack-register f 31 64 }

CONSTANT: NZCV 0b1101101000010000
CONSTANT: FPCR 0b1101101000100000
CONSTANT: FPSR 0b1101101000100001

ALIAS: RETURN     X0
ALIAS: arg1       X0
ALIAS: arg2       X1
ALIAS: arg3       X2
ALIAS: arg4       X3
ALIAS: arg5       X4
ALIAS: arg6       X5
ALIAS: arg7       X6
ALIAS: arg8       X7

ALIAS: temp       X9
ALIAS: ds-0       X10
ALIAS: ds-1       X11
ALIAS: ds-2       X12
ALIAS: ds-3       X13
ALIAS: temp1      X14
ALIAS: temp2      X15
ALIAS: quotient   X14
ALIAS: remainder  X15
ALIAS: obj        X14
ALIAS: type       X15
ALIAS: cache      X14
ALIAS: top        X11
ALIAS: *top       X12

ALIAS: VM         X19
ALIAS: CTX        X20
ALIAS: DS         X21
ALIAS: RS         X22
ALIAS: PIC-TAIL   X23
ALIAS: SAFEPOINT  X24
ALIAS: TRAMPOLINE X25
ALIAS: CACHE-MISS X26
ALIAS: MEGA-HITS  X27

ALIAS: fp-temp    V30
ALIAS: fp-temp2   V31
