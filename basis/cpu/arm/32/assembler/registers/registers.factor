! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: cpu.arm.32.assembler ;
IN: cpu.arm.32.assembler.registers
! AAPCS callee-saved registers carry the Factor context across native calls.
ALIAS: DS R5
ALIAS: RS R6
ALIAS: VM R7
ALIAS: CTX R8
ALIAS: SAFEPOINT R9
ALIAS: TRAMPOLINE R10
ALIAS: PIC-TAIL R4
ALIAS: IP0 R12
ALIAS: IP1 R4
ALIAS: temp R12
ALIAS: temp1 R2
ALIAS: temp2 R3
ALIAS: ds-0 R0
ALIAS: ds-1 R1
ALIAS: ds-2 R2
ALIAS: ds-3 R3
ALIAS: obj R0
ALIAS: type R1
ALIAS: cache R2
ALIAS: arg1 R0
ALIAS: arg2 R1
ALIAS: arg3 R2
ALIAS: arg4 R3
ALIAS: RETURN R0
