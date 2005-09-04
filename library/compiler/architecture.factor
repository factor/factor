IN: compiler-frontend

! A few things the front-end needs to know about the back-end.

DEFER: fixnum-imm? ( -- ? )
#! Can fixnum operations take immediate operands?

DEFER: vregs ( -- n )
#! Number of vregs
