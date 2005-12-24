IN: compiler-backend

! A few things the front-end needs to know about the back-end.

DEFER: fixnum-imm? ( -- ? )
#! Can fixnum operations take immediate operands?

DEFER: vregs ( -- regs )

DEFER: dual-fp/int-regs? ( -- ? )
#! Should fp parameters to fastcalls be loaded in integer
#! registers too? Only for PowerPC.

DEFER: compile-c-call ( library function -- )
