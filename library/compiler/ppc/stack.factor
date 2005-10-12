! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler errors kernel math memory words ;

GENERIC: loc>operand

M: ds-loc loc>operand ds-loc-n cell * neg 14 swap ;
M: cs-loc loc>operand cs-loc-n cell * neg 15 swap ;

M: %immediate generate-node ( vop -- )
    dup 0 vop-in address swap 0 vop-out v>operand LOAD ;

: load-indirect ( dest literal -- )
    intern-literal over LOAD32 0 1 rel-address dup 0 LWZ ;

M: %indirect generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in load-indirect ;

M: %peek generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in loc>operand LWZ ;

M: %replace generate-node ( vop -- )
    dup 0 vop-in v>operand swap 0 vop-out loc>operand STW ;

M: %inc-d generate-node ( vop -- )
    14 14 rot 0 vop-in cell * ADDI ;

M: %inc-r generate-node ( vop -- )
    15 15 rot 0 vop-in cell * ADDI ;
