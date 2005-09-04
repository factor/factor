IN: compiler-frontend
USING: assembler compiler-backend math ;

! Architecture description
: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    f ;

: vregs ( -- n )
    #! Number of vregs
    8 ;

M: vreg v>operand vreg-n 3 + ;
