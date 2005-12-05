IN: compiler-backend
USING: assembler compiler-backend kernel sequences ;

! AMD64 register assignments
! RAX RCX RDX RSI RDI R8 R9 R10 R11 vregs
! R14 datastack
! R15 callstack

: ds-reg R14 ; inline
: cs-reg R15 ; inline

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    f ; inline

: vregs { RAX RCX RDX RSI RDI R8 R9 R10 R11 } ; inline

! FIXME
M: int-regs fastcall-regs drop 0 ;
M: int-regs reg-class-size drop 4 ;
M: float-regs fastcall-regs drop 0 ;

: dual-fp/int-regs? f ;

: address-operand ( address -- operand )
    #! On AMD64, we have to load 64-bit addresses into a
    #! scratch register first.
    0 scratch [ swap MOV ] keep ; inline

: fixnum>slot@ drop ; inline
