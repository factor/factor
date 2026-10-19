! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.parser prettyprint.custom prettyprint.sections sequences ;
IN: cpu.loongarch.64.assembler.registers
TUPLE: register { n integer initial: 0 } ;
TUPLE: int-register < register ;
TUPLE: fp-register < register ;
M: int-register pprint* n>> >dec "X" prepend text ;
M: fp-register pprint* n>> >dec "F" prepend text ;
CONSTANT: X0 T{ int-register f 0 }
CONSTANT: X1 T{ int-register f 1 }
CONSTANT: X2 T{ int-register f 2 }
CONSTANT: X3 T{ int-register f 3 }
CONSTANT: X4 T{ int-register f 4 }
CONSTANT: X5 T{ int-register f 5 }
CONSTANT: X6 T{ int-register f 6 }
CONSTANT: X7 T{ int-register f 7 }
CONSTANT: X8 T{ int-register f 8 }
CONSTANT: X9 T{ int-register f 9 }
CONSTANT: X10 T{ int-register f 10 }
CONSTANT: X11 T{ int-register f 11 }
CONSTANT: X12 T{ int-register f 12 }
CONSTANT: X13 T{ int-register f 13 }
CONSTANT: X14 T{ int-register f 14 }
CONSTANT: X15 T{ int-register f 15 }
CONSTANT: X16 T{ int-register f 16 }
CONSTANT: X17 T{ int-register f 17 }
CONSTANT: X18 T{ int-register f 18 }
CONSTANT: X19 T{ int-register f 19 }
CONSTANT: X20 T{ int-register f 20 }
CONSTANT: X21 T{ int-register f 21 }
CONSTANT: X22 T{ int-register f 22 }
CONSTANT: X23 T{ int-register f 23 }
CONSTANT: X24 T{ int-register f 24 }
CONSTANT: X25 T{ int-register f 25 }
CONSTANT: X26 T{ int-register f 26 }
CONSTANT: X27 T{ int-register f 27 }
CONSTANT: X28 T{ int-register f 28 }
CONSTANT: X29 T{ int-register f 29 }
CONSTANT: X30 T{ int-register f 30 }
CONSTANT: X31 T{ int-register f 31 }
CONSTANT: F0 T{ fp-register f 0 }
CONSTANT: F1 T{ fp-register f 1 }
CONSTANT: F2 T{ fp-register f 2 }
CONSTANT: F3 T{ fp-register f 3 }
CONSTANT: F4 T{ fp-register f 4 }
CONSTANT: F5 T{ fp-register f 5 }
CONSTANT: F6 T{ fp-register f 6 }
CONSTANT: F7 T{ fp-register f 7 }
CONSTANT: F8 T{ fp-register f 8 }
CONSTANT: F9 T{ fp-register f 9 }
CONSTANT: F10 T{ fp-register f 10 }
CONSTANT: F11 T{ fp-register f 11 }
CONSTANT: F12 T{ fp-register f 12 }
CONSTANT: F13 T{ fp-register f 13 }
CONSTANT: F14 T{ fp-register f 14 }
CONSTANT: F15 T{ fp-register f 15 }
CONSTANT: F16 T{ fp-register f 16 }
CONSTANT: F17 T{ fp-register f 17 }
CONSTANT: F18 T{ fp-register f 18 }
CONSTANT: F19 T{ fp-register f 19 }
CONSTANT: F20 T{ fp-register f 20 }
CONSTANT: F21 T{ fp-register f 21 }
CONSTANT: F22 T{ fp-register f 22 }
CONSTANT: F23 T{ fp-register f 23 }
CONSTANT: F24 T{ fp-register f 24 }
CONSTANT: F25 T{ fp-register f 25 }
CONSTANT: F26 T{ fp-register f 26 }
CONSTANT: F27 T{ fp-register f 27 }
CONSTANT: F28 T{ fp-register f 28 }
CONSTANT: F29 T{ fp-register f 29 }
CONSTANT: F30 T{ fp-register f 30 }
CONSTANT: F31 T{ fp-register f 31 }
ALIAS: ZERO X0
ALIAS: RA X1
ALIAS: SP X3
ALIAS: TP X2
ALIAS: FP X22
ALIAS: DS X23
ALIAS: RS X24
ALIAS: CTX X25
ALIAS: VM X26
ALIAS: SAFEPOINT X27
ALIAS: TRAMPOLINE X28
ALIAS: TRAMPOLINE2 X29
ALIAS: CACHE-MISS X30
ALIAS: MEGA-HITS X31
ALIAS: PIC-TAIL X20
ALIAS: temp X12
ALIAS: temp2 X13
ALIAS: IP0 X14
ALIAS: IP1 X15
ALIAS: ds-0 X16
ALIAS: ds-1 X17
ALIAS: ds-2 X18
ALIAS: ds-3 X19
ALIAS: obj X16
ALIAS: type X17
ALIAS: cache X16
ALIAS: src X18
ALIAS: top X16
ALIAS: bottom X17
ALIAS: quotient X17
ALIAS: remainder X18
ALIAS: RETURN X4
ALIAS: temp1 X15
ALIAS: A0 X4
ALIAS: arg1 X4
ALIAS: T0 X12
ALIAS: A1 X5
ALIAS: arg2 X5
ALIAS: T1 X13
ALIAS: A2 X6
ALIAS: arg3 X6
ALIAS: T2 X14
ALIAS: A3 X7
ALIAS: arg4 X7
ALIAS: T3 X15
ALIAS: A4 X8
ALIAS: arg5 X8
ALIAS: T4 X16
ALIAS: A5 X9
ALIAS: arg6 X9
ALIAS: T5 X17
ALIAS: A6 X10
ALIAS: arg7 X10
ALIAS: T6 X18
ALIAS: A7 X11
ALIAS: arg8 X11
ALIAS: T7 X19
ALIAS: S0 X23
ALIAS: S1 X24
ALIAS: S2 X25
ALIAS: S3 X26
ALIAS: S4 X27
ALIAS: S5 X28
ALIAS: S6 X29
ALIAS: S7 X30
ALIAS: S8 X31
ALIAS: FA0 F0
ALIAS: FA1 F1
ALIAS: FA2 F2
ALIAS: FA3 F3
ALIAS: FA4 F4
ALIAS: FA5 F5
ALIAS: FA6 F6
ALIAS: FA7 F7
ALIAS: fp-temp F22
ALIAS: fp-temp2 F23
