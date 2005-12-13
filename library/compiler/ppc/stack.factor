! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler errors kernel kernel-internals math
memory namespaces words ;

GENERIC: loc>operand

M: ds-loc loc>operand ds-loc-n cells neg 14 swap ;
M: cs-loc loc>operand cs-loc-n cells neg 15 swap ;

M: %immediate generate-node ( vop -- )
    drop 0 input address 0 output-operand LOAD ;

: load-indirect ( dest literal -- )
    add-literal over LOAD32 rel-2/2 rel-address dup 0 LWZ ;

M: %indirect generate-node ( vop -- )
    drop 0 output-operand 0 input load-indirect ;

M: %peek generate-node ( vop -- )
    drop 0 output-operand 0 input loc>operand LWZ ;

M: %replace generate-node ( vop -- )
    drop 0 input-operand 0 output loc>operand STW ;

M: %inc-d generate-node ( vop -- )
    drop 14 14 0 input cell * ADDI ;

M: %inc-r generate-node ( vop -- )
    drop 15 15 0 input cell * ADDI ;
