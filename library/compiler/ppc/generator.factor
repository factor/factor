! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler inference kernel kernel-internals
lists math memory words ;

! PowerPC register assignments
! r14 data stack
! r15 call stack
! r16 callframe
! r17 executing
! r18-r30 vregs

M: integer v>operand tag-bits shift ;
M: vreg v>operand vreg-n 18 + ;

M: %prologue generate-node ( vop -- )
    #! At the start of each word that calls a subroutine, we
    #! store the link register in r0, then push r0 on the C
    #! stack.
    drop
    1 1 -16 STWU
    0 MFLR
    0 1 20 STW ;

: compile-epilogue
    #! At the end of each word that calls a subroutine, we store
    #! the previous link register value in r0 by popping it off
    #! the stack, set the link register to the contents of r0,
    #! and jump to the link register.
    0 1 20 LWZ
    1 1 16 ADDI
    0 MTLR ;

M: %call-label generate-node ( vop -- )
    #! Near calling convention for inlined recursive combinators
    #! Note: length of instruction sequence is hard-coded.
    vop-label
    0 1 rel-address  compiled-offset 20 + 18 LOAD32
    1 1 -16 STWU
    18 1 20 STW
    B ;

: word-addr ( word -- )
    dup 0 1 rel-primitive word-xt 19 LOAD32 ;

: compile-call ( label -- )
    #! Far C call for primitives, near C call for compiled defs.
    dup primitive? [ word-addr  19 MTLR  BLRL ] [ BL ] ifte ;

M: %call generate-node ( vop -- )
    vop-label dup postpone-word compile-call ;

: compile-jump ( label -- )
    #! For tail calls. IP not saved on C stack.
    dup primitive? [ word-addr  19 MTCTR  BCTR ] [ B ] ifte ;

M: %jump generate-node ( vop -- )
    vop-label dup postpone-word  compile-epilogue compile-jump ;

M: %jump-label generate-node ( vop -- )
    vop-label B ;

: conditional ( vop -- label )
    dup vop-in-1 v>operand 0 swap f address CMPI vop-label ;

M: %jump-f generate-node ( vop -- )
    conditional BEQ ;

M: %jump-t generate-node ( vop -- )
    conditional BNE ;

M: %return-to generate-node ( vop -- )
    vop-label 0 18 LOAD32  absolute-16/16
    1 1 -16 STWU
    18 1 20 STW ;

M: %return generate-node ( vop -- )
    drop compile-epilogue BLR ;

M: %untag generate-node ( vop -- )
    ! todo: formalize scratch registers
    dest/src 0 0 28 RLWINM ;

M: %dispatch generate-node ( vop -- )
    ! Compile a piece of code that jumps to an offset in a
    ! jump table indexed by the fixnum at the top of the stack.
    ! The jump table must immediately follow this macro.
    drop
   ! POP-DS
    18 18 1 SRAWI
    ! The value 24 is a magic number. It is the length of the
    ! instruction sequence that follows to be generated.
    0 1 rel-address  compiled-offset 24 + 19 LOAD32
    18 18 19 ADD
    18 18 0 LWZ
    18 MTLR
    BLR ;
