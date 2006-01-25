! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: assembler kernel math namespaces ;

M: %prologue generate-node ( vop -- )
    drop RSP stack-increment SUB ;
