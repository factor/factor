IN: compiler-backend
USING: assembler compiler-backend kernel sequences ;

! x86 register assignments
! EAX, ECX, EDX, EBP vregs
! ESI datastack
! EBX callstack

: ds-reg ESI ; inline
: cs-reg EBX ; inline

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    t ; inline

: vregs ( -- n )
    #! Number of vregs
    3 ; inline

M: vreg v>operand vreg-n { EAX ECX EDX } nth ;

! On x86, parameters are never passed in registers.
M: int-regs fastcall-regs drop 0 ;
M: int-regs reg-class-size drop 4 ;
M: float-regs fastcall-regs drop 0 ;

: dual-fp/int-regs? f ;
