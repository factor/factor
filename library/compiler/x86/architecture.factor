IN: compiler-frontend
USING: assembler compiler-backend sequences ;

! Architecture description
: fixnum-imm? ( -- ? )
    #! Can fixnum operations take immediate operands?
    t ;

: vregs ( -- n )
    #! Number of vregs
    3 ;

M: vreg v>operand vreg-n { EAX ECX EDX } nth ;
