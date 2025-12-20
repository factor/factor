! Copyright (C) 2024 Giftpflanze.
! See https://factorcode.org/license.txt for BSD license.
USING: compiler.constants cpu.arm.64.assembler layouts ;
IN: bootstrap.assembler.arm

: teb-stack-base-offset ( -- n ) 1 bootstrap-cells ;
: teb-stack-limit-offset ( -- n ) 2 bootstrap-cells ;

: jit-save-teb ( -- )
    temp1 PR teb-stack-base-offset [+] LDR
    temp2 PR teb-stack-limit-offset [+] LDR
    temp1 temp2 SP -16 [pre] STP ;

: jit-update-teb ( -- )
    temp CTX context-callstack-seg-offset [+] LDR
    temp2 temp segment-end-offset [+] LDR
    temp1 temp segment-start-offset [+] LDR
    temp1 temp2 temp teb-stack-base-offset [+] STP ;

: jit-restore-teb ( -- )
    temp1 temp2 SP 16 [post] LDP
    temp1 PR teb-stack-base-offset [+] STR
    temp2 PR teb-stack-limit-offset [+] STR ;
