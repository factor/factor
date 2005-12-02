IN: compiler-backend
USING: assembler compiler-backend kernel sequences ;

! AMD64 register assignments
! RAX RCX RDX RSI RDI R8 R9 R10 R11 vregs
! R12 datastack
! R13 callstack

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    t ; inline

: vregs ( -- n )
    #! Number of vregs
    3 ; inline

M: vreg v>operand vreg-n { RAX RCX RDX RSI RDI R8 R9 R10 R11 } nth ;

! FIXME
M: int-regs fastcall-regs drop 0 ;
M: int-regs reg-class-size drop 4 ;
M: float-regs fastcall-regs drop 0 ;

: dual-fp/int-regs? f ;
