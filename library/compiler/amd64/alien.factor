! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler kernel math sequences ;

! GENERIC: store-insn ( offset reg-class -- )
! 
! GENERIC: load-insn ( elt parameter reg-class -- )
! 
! M: int-regs store-insn drop >r 3 1 r> stack@ STW ;
! 
! M: int-regs load-insn drop 3 + 1 rot stack@ LWZ ;
! 
! M: %unbox generate-node ( vop -- )
!     drop
!     ! Call the unboxer
!     1 input f compile-c-call
!     ! Store the return value on the C stack
!     0 input 2 input store-insn ;
! 
! M: %parameter generate-node ( vop -- )
!     ! Move a value from the C stack into the fastcall register
!     drop 0 input 1 input 2 input load-insn ;
! 
! M: %box generate-node ( vop -- )
!     drop
!     ! Move return value of C function into input register
!     param-regs first RAX MOV
!     0 input f compile-c-call ;
! 
! M: %cleanup generate-node ( vop -- ) drop ;
