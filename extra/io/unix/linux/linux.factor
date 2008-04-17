! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel io.backend io.monitors io.unix.backend
io.unix.select io.unix.linux.monitors system namespaces ;
IN: io.unix.linux

M: linux init-io ( -- )
    <select-mx> mx set-global ;

linux set-io-backend
