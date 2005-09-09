IN: compiler-backend
USING: assembler compiler-backend sequences ;

! x86 register assignments
! EAX, ECX, EDX, EBP vregs
! ESI datastack
! EBX callstack

: cell
    #! Word size.
    4 ; inline

: vregs ( -- n )
    #! Number of vregs
    3 ; inline

M: vreg v>operand vreg-n { EAX ECX EDX } nth ;
