! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend system namespaces io.unix.multiplexers
io.unix.multiplexers.run-loop ;
IN: io.unix.macosx

M: macosx init-io ( -- )
    <run-loop-mx> mx set-global ;

macosx set-io-backend
