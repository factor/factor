IN: compiler-backend
USING: alien assembler compiler compiler-backend kernel
sequences ;

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

: compile-c-call ( symbol dll -- )
    2dup dlsym CALL 1 0 rel-dlsym ;

: compile-c-call* ( symbol dll args -- operands )
    [ [ PUSH ] each compile-c-call ] keep
    [ drop 0 scratch POP ] each ;

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
