! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

M: %slot generate-node ( vop -- )
    #! the untagged object is in vop-out-1, the tagged slot
    #! number is in vop-in-1.
    dest/src
    ! turn tagged fixnum slot # into an offset, multiple of 4
    dup dup 1 SRAWI
    ! compute slot address in vop-out-1
    >r dup dup r> ADD
    ! load slot value in vop-out-1
    dup 0 LWZ ;

M: %fast-slot generate-node ( vop -- )
    #! the tagged object is in vop-out-1, the pointer offset is
    #! in vop-in-1. the offset already takes the type tag
    #! into account, so its just one instruction to load.
    dup vop-out-1 v>operand dup rot vop-in-1 LWZ ;

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
