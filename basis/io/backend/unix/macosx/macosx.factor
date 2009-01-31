! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend system namespaces io.backend.unix.bsd
io.backend.unix.multiplexers io.backend.unix.multiplexers.run-loop ;
IN: io.backend.macosx

M: macosx init-io ( -- )
    <run-loop-mx> mx set-global ;

macosx set-io-backend
