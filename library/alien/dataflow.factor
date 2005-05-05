IN: alien

! Linear IR nodes

SYMBOL: #cleanup ( unwind stack by parameter )

SYMBOL: #unbox ( move top of datastack to C stack )
SYMBOL: #unbox-float
SYMBOL: #unbox-double

! for register parameter passing; move top of C stack to a
! register. no-op on x86, generates code on PowerPC.
SYMBOL: #parameter

! for increasing stack space on PowerPC; unused on x86.
SYMBOL: #parameters

SYMBOL: #box ( move EAX to datastack )
SYMBOL: #box-float
SYMBOL: #box-double

! These are set in the alien-invoke dataflow IR node.
SYMBOL: alien-returns
SYMBOL: alien-parameters
