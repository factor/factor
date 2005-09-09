! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    dest/src
    ! turn tagged fixnum slot # into an offset, multiple of 4
    dup dup 1 SRAWI
    ! compute slot address in 0 vop-out
    >r dup dup r> ADD
    ! load slot value in 0 vop-out
    dup 0 LWZ ;

M: %fast-slot generate-node ( vop -- )
    dup 0 vop-out v>operand dup rot 0 vop-in LWZ ;

M: %set-slot generate-node ( vop -- )
    dup 2 vop-in v>operand over 1 vop-in v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over dup 1 SRAWI
    ! compute slot address in 1 vop-in
    over dup rot ADD
    ! store new slot value
    >r 0 vop-in v>operand r> 0 STW ;

M: %fast-set-slot generate-node ( vop -- )
    [ 0 vop-in v>operand ] keep
    [ 1 vop-in v>operand ] keep
    2 vop-in STW ;

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    #! Uses r6 for storage.
    0 vop-in v>operand
    dup dup card-bits SRAWI
    dup dup 16 ADD
    6 over 0 LBZ
    6 6 card-mark ORI
    6 swap 0 STB ;

: userenv ( reg -- )
    #! Load the userenv pointer in a virtual register.
    "userenv" f dlsym swap LOAD32 0 1 rel-userenv ;

M: %getenv generate-node ( vop -- )
    dup 0 vop-out v>operand dup userenv
    dup rot 0 vop-in cell * LWZ ;

M: %setenv generate-node ( vop -- )
    ! bad! need to formalize scratch register usage
    4 <vreg> v>operand dup userenv >r
    dup 0 vop-in v>operand r> rot 1 vop-in cell * STW ;
