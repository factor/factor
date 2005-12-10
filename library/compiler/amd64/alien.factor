! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler compiler inference kernel
kernel-internals lists math memory namespaces words ;

M: %alien-invoke generate-node drop ;

M: %parameter generate-node drop ;

M: %unbox generate-node drop ;

M: %box generate-node drop ;

M: %cleanup generate-node drop ;
