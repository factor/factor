! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: assembler compiler-frontend kernel math namespaces ;

M: %prologue generate-node ( vop -- )
    drop
    0 input \ stack-reserve set
    RSP stack-increment SUB ;
