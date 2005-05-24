! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: assembler
USING: alien compiler compiler-backend inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node ( vop -- )
    uncons load-library 2dup 1 rel-dlsym dlsym compile-call-far ;

: stack-size 8 + 16 align ;
: stack@ 3 + cell * ;

M: %parameters generate-node ( vop -- )
    dup 0 = [ drop ] [ stack-size 1 1 rot SUBI ] ifte ;

M: %unbox generate-node ( vop -- )
    uncons f 2dup 1 rel-dlsym dlsym compile-call-far
    3 1 rot stack@ STW ;

M: %parameter generate-node ( vop -- )
    dup 3 + 1 rot stack@ LWZ ;

M: %box generate-node ( vop -- )
    f 2dup 1 rel-dlsym dlsym compile-call-far ;

M: %cleanup generate-node ( vop -- )
    dup 0 = [ drop ] [ stack-size 1 1 rot ADDI ] ifte ;
