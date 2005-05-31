! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien compiler compiler-backend inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node ( vop -- )
    vop-in-1 uncons load-library compile-c-call ;

: stack-size 8 + 16 align ;
: stack@ 3 + cell * ;

M: %parameters generate-node ( vop -- )
    dup 0 = [ drop ] [ stack-size 1 1 rot SUBI ] ifte ;

M: %unbox generate-node ( vop -- )
    vop-in-1 uncons f compile-c-call 3 1 rot stack@ STW ;

M: %parameter generate-node ( vop -- )
    vop-in-1 dup 3 + 1 rot stack@ LWZ ;

M: %box generate-node ( vop -- )
    vop-in-1 f compile-c-call ;

M: %cleanup generate-node ( vop -- )
    vop-in-1 dup 0 = [ drop ] [ stack-size 1 1 rot ADDI ] ifte ;
