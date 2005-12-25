! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: compiler-backend
USING: alien assembler kernel math ;

M: %unbox generate-node ( vop -- )
    drop ;

M: %parameter generate-node ( vop -- )
    ! Move a value from the C stack into the fastcall register
    drop ;

M: %box generate-node ( vop -- ) drop ;

M: %cleanup generate-node ( vop -- ) drop ;
