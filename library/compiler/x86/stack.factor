! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler
USING: alien arrays assembler inference kernel
kernel-internals lists math memory sequences words ;

: reg-stack ( n reg -- op ) swap cells neg [+] ;

M: ds-loc v>operand ds-loc-n ds-reg reg-stack ;

M: cs-loc v>operand cs-loc-n cs-reg reg-stack ;

M: %peek generate-node ( vop -- )
    drop 0 output-operand 0 input-operand MOV ;

M: %replace generate-node ( vop -- )
    drop 0 output-operand 0 input-operand MOV ;

: (%inc) 0 input cells dup 0 > [ ADD ] [ neg SUB ] if ;

M: %inc-d generate-node ( vop -- ) drop ds-reg (%inc) ;

M: %inc-r generate-node ( vop -- ) drop cs-reg (%inc) ;

M: %immediate generate-node ( vop -- )
    drop 0 output-operand 0 input address MOV ;

M: %indirect generate-node ( vop -- )
    #! indirect load of a literal through a table
    drop 0 output-operand 0 input load-indirect ;
