! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: arrays assembler compiler kernel ;

: load-indirect ( dest literal -- )
    #! We cannot use the x86 definition here.
    0 scratch swap add-literal MOV 0 0 rel-address
    0 scratch swap 1array MOV ;
