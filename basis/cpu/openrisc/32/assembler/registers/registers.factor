! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math math.parser prettyprint.custom prettyprint.sections sequences ;
IN: cpu.openrisc.32.assembler.registers

TUPLE: register { n integer } ;
TUPLE: int-register < register ;
TUPLE: fp-register lo hi ;
M: int-register pprint* n>> >dec "R" prepend text ;
M: fp-register pprint* [ lo>> >dec ] [ hi>> >dec ] bi ":R" glue "R" prepend text ;

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

CONSTANT: F0 T{ fp-register f 3 4 }
CONSTANT: F1 T{ fp-register f 5 6 }
CONSTANT: F2 T{ fp-register f 7 8 }
CONSTANT: F3 T{ fp-register f 11 12 }

! C floating-point arguments share r3-r8 with integer arguments. Singles
! advance by one word, so their possible starting positions overlap.
CONSTANT: C-F0 T{ fp-register f 3 4 }
CONSTANT: C-F1 T{ fp-register f 4 5 }
CONSTANT: C-F2 T{ fp-register f 5 6 }
CONSTANT: C-F3 T{ fp-register f 6 7 }
CONSTANT: C-F4 T{ fp-register f 7 8 }
CONSTANT: C-F5 T{ fp-register f 8 8 }

ALIAS: ZERO R0
ALIAS: SP R1
ALIAS: FP R2
ALIAS: RA R9
ALIAS: TLS R10
ALIAS: RETURN R11
ALIAS: arg1 R3
ALIAS: arg2 R4
ALIAS: arg3 R5
ALIAS: arg4 R6
ALIAS: arg5 R7
ALIAS: arg6 R8
ALIAS: DS R14
ALIAS: RS R16
ALIAS: VM R18
ALIAS: CTX R20
ALIAS: SAFEPOINT R22
ALIAS: TRAMPOLINE R24
ALIAS: TRAMPOLINE2 R26
ALIAS: CACHE-MISS R28
ALIAS: MEGA-HITS R30
ALIAS: PIC-TAIL R13
ALIAS: temp R15
ALIAS: temp2 R17
ALIAS: IP0 R13
ALIAS: IP1 R15
ALIAS: temp1 R19
ALIAS: ds-0 R7
ALIAS: ds-1 R8
ALIAS: ds-2 R11
ALIAS: ds-3 R12
ALIAS: obj R7
ALIAS: type R8
ALIAS: cache R7
ALIAS: src R11
ALIAS: top R7
ALIAS: bottom R8
ALIAS: quotient R8
ALIAS: remainder R11
ALIAS: fp-temp F0
ALIAS: fp-temp2 F1
CONSTANT: fp-conversion-temp T{ fp-register f 15 17 }
