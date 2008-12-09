! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.macosx
USING: io.unix.backend io.unix.bsd io.unix.kqueue io.backend
namespaces system ;

M: macosx init-io ( -- )
    <kqueue-mx> mx set-global ;

macosx set-io-backend
