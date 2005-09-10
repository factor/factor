IN: compiler-backend
USING: assembler compiler-backend math ;

! PowerPC register assignments
! r3-r10 vregs
! r14 data stack
! r15 call stack

: cell
    #! Word size.
    4 ; inline

: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    f ; inline

: vregs ( -- n )
    #! Number of vregs
    8 ; inline

M: vreg v>operand vreg-n 3 + ;
