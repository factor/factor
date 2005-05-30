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

: write-barrier ( reg -- )
    #! Mark the card pointed to by vreg.
    dup dup card-bits SRAWI
    dup dup 16 ADD
    20 over 0 LBZ
    20 20 card-mark ORI
    20 swap 0 STB ;

M: %set-slot generate-node ( vop -- )
    dup vop-in-3 v>operand over vop-in-2 v>operand
    ! turn tagged fixnum slot # into an offset, multiple of 4
    over dup 1 SRAWI
    ! compute slot address in vop-in-2
    over dup pick ADD
    ! store new slot value
    >r >r vop-in-1 v>operand r> 0 STW r> write-barrier ;

M: %fast-set-slot generate-node ( vop -- )
    dup vop-in-1 v>operand over vop-in-2 v>operand
    [ rot vop-in-3 STW ] keep write-barrier ;

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
