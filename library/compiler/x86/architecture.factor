IN: compiler-backend
USING: assembler compiler-backend kernel sequences ;

! x86 register assignments
! EAX, ECX, EDX vregs
! ESI datastack
! EBX callstack

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    t ; inline

: ds-reg ESI ; inline
: cs-reg EBX ; inline
: return-reg EAX ; inline
: remainder-reg EDX ; inline

: vregs { EAX ECX EDX } ; inline

! On x86, parameters are never passed in registers.
M: int-regs fastcall-regs drop 0 ;
M: int-regs reg-class-size drop 4 ;
M: float-regs fastcall-regs drop 0 ;

: dual-fp/int-regs? f ;

: address-operand ( address -- operand )
    #! On x86, we can always use an address as an operand
    #! directly.
    ; inline

: fixnum>slot@ 1 SHR ; inline

: prepare-division CDQ ; inline
