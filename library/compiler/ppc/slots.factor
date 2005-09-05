! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    dest/src
    ! turn tagged fixnum slot # into an offset, multiple of 4
    dup dup 1 SRAWI
    ! compute slot address in vop-out-1
    >r dup dup r> ADD
    ! load slot value in vop-out-1
    dup 0 LWZ ;

M: %fast-slot generate-node ( vop -- )
    dup vop-out-1 v>operand dup rot vop-in-1 LWZ ;

M: %set-slot generate-node ( vop -- )
    dup vop-in-3 v>operand over vop-in-2 v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over dup 1 SRAWI
    ! compute slot address in vop-in-2
    over dup rot ADD
    ! store new slot value
    >r vop-in-1 v>operand r> 0 STW ;

M: %fast-set-slot generate-node ( vop -- )
    [ vop-in-1 v>operand ] keep
    [ vop-in-2 v>operand ] keep
    vop-in-3 STW ;

M: %write-barrier generate-node ( vop -- )
    #! Mark the card pointed to by vreg.
    #! Uses r6 for storage.
    vop-in-1 v>operand
    dup dup card-bits SRAWI
    dup dup 16 ADD
    6 over 0 LBZ
    6 6 card-mark ORI
    6 swap 0 STB ;

: userenv ( reg -- )
    #! Load the userenv pointer in a virtual register.
    "userenv" f dlsym swap LOAD32 0 1 rel-userenv ;

M: %getenv generate-node ( vop -- )
    dup vop-out-1 v>operand dup userenv
    dup rot vop-in-1 cell * LWZ ;

M: %setenv generate-node ( vop -- )
    ! bad! need to formalize scratch register usage
    4 <vreg> v>operand dup userenv >r
    dup vop-in-1 v>operand r> rot vop-in-2 cell * STW ;
