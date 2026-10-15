! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.parser prettyprint.custom prettyprint.sections sequences ;
IN: cpu.alpha.64.assembler.registers
TUPLE: register { n integer initial: 0 } ;
TUPLE: int-register < register ;
TUPLE: fp-register < register ;
M: int-register pprint* n>> >dec "R" prepend text ;
M: fp-register pprint* n>> >dec "F" prepend text ;
CONSTANT: R0 T{ int-register f 0 }
CONSTANT: R1 T{ int-register f 1 }
CONSTANT: R2 T{ int-register f 2 }
CONSTANT: R3 T{ int-register f 3 }
CONSTANT: R4 T{ int-register f 4 }
CONSTANT: R5 T{ int-register f 5 }
CONSTANT: R6 T{ int-register f 6 }
CONSTANT: R7 T{ int-register f 7 }
CONSTANT: R8 T{ int-register f 8 }
CONSTANT: R9 T{ int-register f 9 }
CONSTANT: R10 T{ int-register f 10 }
CONSTANT: R11 T{ int-register f 11 }
CONSTANT: R12 T{ int-register f 12 }
CONSTANT: R13 T{ int-register f 13 }
CONSTANT: R14 T{ int-register f 14 }
CONSTANT: R15 T{ int-register f 15 }
CONSTANT: R16 T{ int-register f 16 }
CONSTANT: R17 T{ int-register f 17 }
CONSTANT: R18 T{ int-register f 18 }
CONSTANT: R19 T{ int-register f 19 }
CONSTANT: R20 T{ int-register f 20 }
CONSTANT: R21 T{ int-register f 21 }
CONSTANT: R22 T{ int-register f 22 }
CONSTANT: R23 T{ int-register f 23 }
CONSTANT: R24 T{ int-register f 24 }
CONSTANT: R25 T{ int-register f 25 }
CONSTANT: R26 T{ int-register f 26 }
CONSTANT: R27 T{ int-register f 27 }
CONSTANT: R28 T{ int-register f 28 }
CONSTANT: R29 T{ int-register f 29 }
CONSTANT: R30 T{ int-register f 30 }
CONSTANT: R31 T{ int-register f 31 }
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
ALIAS: ZERO R31
ALIAS: RA R26
ALIAS: SP R30
ALIAS: GP R29
ALIAS: PV R27
ALIAS: FP R9
ALIAS: DS R10
ALIAS: RS R11
ALIAS: VM R12
ALIAS: CTX R13
ALIAS: SAFEPOINT R14
ALIAS: TRAMPOLINE R15
ALIAS: temp R1
ALIAS: temp2 R2
ALIAS: temp3 R3
ALIAS: obj R4
ALIAS: type R5
ALIAS: ds-0 R6
ALIAS: ds-1 R7
ALIAS: ds-2 R8
ALIAS: PIC-TAIL R25
ALIAS: arg1 R16
ALIAS: arg2 R17
ALIAS: arg3 R18
ALIAS: arg4 R19
ALIAS: arg5 R20
ALIAS: arg6 R21
ALIAS: RETURN R0
ALIAS: ds-3 R22
ALIAS: temp1 R24
ALIAS: cache R23
ALIAS: fp-temp F0
