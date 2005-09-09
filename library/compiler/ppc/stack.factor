! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler errors kernel math memory words ;

: ds-op cell * neg 14 swap ;
: cs-op cell * neg 15 swap ;

M: %immediate generate-node ( vop -- )
    dup 0 vop-in address swap 0 vop-out v>operand LOAD ;

: load-indirect ( dest literal -- )
    intern-literal over LOAD dup 0 LWZ ;

M: %indirect generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in load-indirect ;

M: %peek-d generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in ds-op LWZ ;

M: %replace-d generate-node ( vop -- )
    dup 1 vop-in v>operand swap 0 vop-in ds-op STW ;

M: %inc-d generate-node ( vop -- )
    14 14 rot 0 vop-in cell * ADDI ;

M: %inc-r generate-node ( vop -- )
    15 15 rot 0 vop-in cell * ADDI ;

M: %peek-r generate-node ( vop -- )
    dup 0 vop-out v>operand swap 0 vop-in cs-op LWZ ;

M: %replace-r generate-node ( vop -- )
    dup 1 vop-in v>operand swap 0 vop-in cs-op STW ;
