! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel lists math
memory sequences words ;

: reg-stack ( reg n -- op ) cell * neg 2list ;
: ds-op ( n -- op ) ESI swap reg-stack ;
: cs-op ( n -- op ) EBX swap reg-stack ;

: (%peek) dup vop-out-1 v>operand swap vop-in-1 ;

M: %peek-d generate-node ( vop -- ) (%peek) ds-op MOV ;

M: %peek-r generate-node ( vop -- ) (%peek) cs-op MOV ;

: (%replace) dup vop-in-2 v>operand swap vop-in-1 ;
    
M: %replace-d generate-node ( vop -- ) (%replace) ds-op swap MOV ;

M: %replace-r generate-node ( vop -- ) (%replace) cs-op swap MOV ;

: (%inc) swap vop-in-1 cell * dup 0 > [ ADD ] [ neg SUB ] ifte ;

M: %inc-d generate-node ( vop -- ) ESI (%inc) ;

M: %inc-r generate-node ( vop -- ) EBX (%inc) ;

M: %immediate generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1 address MOV ;

: load-indirect ( dest literal -- )
    intern-literal unit MOV 0 0 rel-address ;

M: %indirect generate-node ( vop -- )
    #! indirect load of a literal through a table
    dup vop-out-1 v>operand swap vop-in-1 load-indirect ;
