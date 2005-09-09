! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel lists math
memory sequences words ;

: reg-stack ( reg n -- op ) cell * neg 2list ;
: ds-op ( ds-loc -- op ) ds-loc-n ESI swap reg-stack ;
: cs-op ( cs-loc -- op ) cs-loc-n EBX swap reg-stack ;

: (%peek) dup 0 vop-out v>operand swap 0 vop-in ;

M: %peek-d generate-node ( vop -- ) (%peek) ds-op MOV ;

M: %peek-r generate-node ( vop -- ) (%peek) cs-op MOV ;

: (%replace) dup 0 vop-in v>operand swap 0 vop-out ;
    
M: %replace-d generate-node ( vop -- ) (%replace) ds-op swap MOV ;

M: %replace-r generate-node ( vop -- ) (%replace) cs-op swap MOV ;

: (%inc) swap 0 vop-in cell * dup 0 > [ ADD ] [ neg SUB ] ifte ;

M: %inc-d generate-node ( vop -- ) ESI (%inc) ;

M: %inc-r generate-node ( vop -- ) EBX (%inc) ;

M: %immediate generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in address MOV ;

: load-indirect ( dest literal -- )
    intern-literal unit MOV 0 0 rel-address ;

M: %indirect generate-node ( vop -- )
    #! indirect load of a literal through a table
    dup 0 vop-out v>operand swap 0 vop-in load-indirect ;
