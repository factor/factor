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

GENERIC: v>operand
M: integer v>operand tag-bits shift ;
M: vreg v>operand vreg-n 18 + ;

! At the start of each word that calls a subroutine, we store
! the link register in r0, then push r0 on the C stack.
M: %prologue generate-node ( vop -- )
    drop
    1 1 -16 STWU
    0 MFLR
    0 1 20 STW ;

! At the end of each word that calls a subroutine, we store
! the previous link register value in r0 by popping it off the
! stack, set the link register to the contents of r0, and jump
! to the link register.
: compile-epilogue
    0 1 20 LWZ
    1 1 16 ADDI
    0 MTLR ;

! Far calls are made to addresses already known when the
! IR node is being generated. No forward reference far
! calls are possible.
: compile-call-far ( word -- )
    19 LOAD32
    19 MTLR
    BLRL ;

: compile-call-label ( label -- )
    dup primitive? [
        dup 1 rel-primitive word-xt compile-call-far
    ] [
        BL
    ] ifte ;

: compile-call-label ( word -- )
    #! Hack: length of instruction sequence that follows
    0 1 rel-address  compiled-offset 20 + 18 LOAD32
    1 1 -16 STWU
    18 1 20 STW
    B ;

M: %call-label generate-node ( vop -- )
    vop-label compile-call-label ;

M: %call generate-node ( vop -- )
    vop-label dup postpone-word compile-call-label ;

: compile-jump-far ( word -- )
    19 LOAD32
    19 MTCTR
    BCTR ;

: compile-jump-label ( label -- )
    dup primitive? [
        dup 1 rel-primitive word-xt compile-jump-far
    ] [
        B
    ] ifte ;

M: %jump generate-node ( vop -- )
    vop-label dup postpone-word  compile-epilogue
    compile-jump-label ;

M: %jump-label generate-node ( vop -- )
    vop-label compile-jump-label ;

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

! \ slot [
!     PEEK-DS
!     2unlist type-tag >r cell * r> - >r 18 18 r> LWZ
!     REPL-DS
! ] "generator" set-word-prop
