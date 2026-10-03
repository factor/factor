! Copyright (C) 2026 Factor authors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.parser prettyprint.custom prettyprint.sections sequences ;
IN: cpu.riscv.64.assembler.registers
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
ALIAS: SP X2
ALIAS: GP X3
ALIAS: TP X4
ALIAS: FP X8
ALIAS: S0 X8
ALIAS: S1 X9
ALIAS: DS X9
ALIAS: RS X18
ALIAS: CTX X19
ALIAS: VM X20
ALIAS: SAFEPOINT X21
ALIAS: TRAMPOLINE X22
ALIAS: TRAMPOLINE2 X23
ALIAS: CACHE-MISS X24
ALIAS: MEGA-HITS X25
ALIAS: PIC-TAIL X26
ALIAS: temp X5
ALIAS: temp2 X6
ALIAS: IP0 X7
ALIAS: IP1 X28
ALIAS: ds-0 X29
ALIAS: ds-1 X30
ALIAS: ds-2 X31
ALIAS: ds-3 X28
ALIAS: obj X29
ALIAS: type X30
ALIAS: cache X29
ALIAS: src X31
ALIAS: top X29
ALIAS: bottom X30
ALIAS: quotient X30
ALIAS: remainder X31
ALIAS: RETURN X10
ALIAS: A0 X10
ALIAS: arg1 X10
ALIAS: A1 X11
ALIAS: arg2 X11
ALIAS: A2 X12
ALIAS: arg3 X12
ALIAS: A3 X13
ALIAS: arg4 X13
ALIAS: A4 X14
ALIAS: arg5 X14
ALIAS: A5 X15
ALIAS: arg6 X15
ALIAS: A6 X16
ALIAS: arg7 X16
ALIAS: A7 X17
ALIAS: arg8 X17
ALIAS: S2 X18
ALIAS: S3 X19
ALIAS: S4 X20
ALIAS: S5 X21
ALIAS: S6 X22
ALIAS: S7 X23
ALIAS: S8 X24
ALIAS: S9 X25
ALIAS: S10 X26
ALIAS: S11 X27
ALIAS: T0 X5
ALIAS: T1 X6
ALIAS: T2 X7
ALIAS: T3 X28
ALIAS: T4 X29
ALIAS: T5 X30
ALIAS: T6 X31
ALIAS: FA0 F10
ALIAS: FA1 F11
ALIAS: FA2 F12
ALIAS: FA3 F13
ALIAS: FA4 F14
ALIAS: FA5 F15
ALIAS: FA6 F16
ALIAS: FA7 F17
ALIAS: fp-temp F0
ALIAS: fp-temp2 F1
ALIAS: temp1 X28
