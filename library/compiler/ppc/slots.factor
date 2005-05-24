! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces sequences words ;

: userenv ( vreg -- )
    #! Load the userenv pointer in a virtual register.
    v>operand "userenv" f dlsym swap LOAD32 0 1 rel-userenv ;

M: %getenv generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1
    [ userenv@ unit MOV ] keep 0 rel-userenv ;

M: %setenv generate-node ( vop -- )
    dup vop-in-2
    [ userenv@ unit swap vop-in-1 v>operand MOV ] keep
    0 rel-userenv ;
