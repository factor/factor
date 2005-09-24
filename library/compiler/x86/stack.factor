! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel lists math
memory sequences words ;

: reg-stack ( n reg -- op ) swap cell * neg 2list ;

GENERIC: loc>operand

M: ds-loc loc>operand ds-loc-n ESI reg-stack ;
M: cs-loc loc>operand cs-loc-n EBX reg-stack ;

M: %peek generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in loc>operand MOV ;

M: %replace generate-node ( vop -- )
    dup 0 vop-out loc>operand swap 0 vop-in v>operand MOV ;

: (%inc) swap 0 vop-in cell * dup 0 > [ ADD ] [ neg SUB ] if ;

M: %inc-d generate-node ( vop -- ) ESI (%inc) ;

M: %inc-r generate-node ( vop -- ) EBX (%inc) ;

M: %immediate generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in address MOV ;

: load-indirect ( dest literal -- )
    intern-literal unit MOV 0 0 rel-address ;

M: %indirect generate-node ( vop -- )
    #! indirect load of a literal through a table
    dup 0 vop-out v>operand swap 0 vop-in load-indirect ;
