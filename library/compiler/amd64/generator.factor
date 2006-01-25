! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler-backend
USING: assembler kernel math namespaces ;

: stack-increment \ stack-reserve get 16 align 8 + ;

M: %prologue generate-node ( vop -- )
    drop RSP stack-increment SUB ;

: compile-epilogue ( -- )
    RSP stack-increment ADD ; inline
