! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler errors kernel math memory words ;

: ds-op cell * neg 14 swap ;
: cs-op cell * neg 15 swap ;

M: %immediate generate-node ( vop -- )
    dup vop-in-1 address swap vop-out-1 v>operand LOAD ;

: load-indirect ( dest literal -- )
    intern-literal over LOAD dup 0 LWZ ;

M: %indirect generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1 load-indirect ;

M: %peek-d generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1 ds-op LWZ ;

M: %replace-d generate-node ( vop -- )
    dup vop-in-2 v>operand swap vop-in-1 ds-op STW ;

M: %inc-d generate-node ( vop -- )
    14 14 rot vop-in-1 cell * ADDI ;

M: %inc-r generate-node ( vop -- )
    15 15 rot vop-in-1 cell * ADDI ;

M: %dec-r generate-node ( vop -- )
    15 15 rot vop-in-1 cell * SUBI ;

M: %peek-r generate-node ( vop -- )
    dup vop-out-1 v>operand swap vop-in-1 cs-op LWZ ;

M: %replace-r generate-node ( vop -- )
    dup vop-in-2 v>operand swap vop-in-1 cs-op STW ;
