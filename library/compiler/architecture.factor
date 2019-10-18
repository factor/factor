IN: compiler-backend

! A few things the front-end needs to know about the back-end.

DEFER: cell ( -- n )
#! Word size

DEFER: fixnum-imm? ( -- ? )
#! Can fixnum operations take immediate operands?

DEFER: vregs ( -- n )
#! Number of vregs

DEFER: dual-fp/int-regs? ( -- ? )
#! Should fp parameters to fastcalls be loaded in integer
#! registers too? Only for PowerPC.
