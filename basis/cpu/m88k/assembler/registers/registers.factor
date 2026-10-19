! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math ;
IN: cpu.m88k.assembler.registers
TUPLE: int-register { n integer initial: 0 } ;
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
ALIAS: ZERO R0
ALIAS: RA R1
ALIAS: SP R31

! Shared with vm/cpu-m88k.hpp and the native transition assembly.
ALIAS: DS R14
ALIAS: RS R15
ALIAS: CTX R16
ALIAS: VM R17
ALIAS: SAFEPOINT R18
ALIAS: temp R19
ALIAS: temp2 R20
ALIAS: IP R21
ALIAS: PIC-TAIL R22
ALIAS: TRAMPOLINE R23
ALIAS: TRAMPOLINE2 R24
ALIAS: NATIVE-STACK R25
