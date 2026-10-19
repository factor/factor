! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel math ;
IN: cpu.s390x.assembler.registers
TUPLE: register { n integer initial: 0 } ;
TUPLE: int-register < register ;
TUPLE: fp-register < register ;
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
