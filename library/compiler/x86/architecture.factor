IN: compiler
USING: alien arrays assembler generic kernel kernel-internals
sequences words ;

! x86 register assignments
! EAX, ECX, EDX vregs
! ESI datastack
! EBX callstack

: ds-reg ESI ; inline
: cs-reg EBX ; inline
: remainder-reg EDX ; inline

: vregs { EAX ECX EDX } ; inline

: compile-c-call ( symbol dll -- )
    2dup dlsym CALL rel-relative rel-dlsym ;

: compile-c-call* ( symbol dll args -- operands )
    reverse-slice
    [ [ PUSH ] each compile-c-call ] keep
    [ drop EDX POP ] each ;

! On x86, parameters are never passed in registers.
M: int-regs return-reg drop EAX ;
M: int-regs fastcall-regs drop { } ;

M: float-regs fastcall-regs drop { } ;

: address-operand ( address -- operand )
    #! On x86, we can always use an address as an operand
    #! directly.
    ; inline

: fixnum>slot@ 1 SHR ; inline

: prepare-division CDQ ; inline

: compile-prologue ; inline

: compile-epilogue ; inline

: load-indirect ( dest literal -- )
    add-literal [] MOV rel-absolute-cell rel-address ; inline
