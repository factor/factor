! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.linux
USING: io.backend io.unix.backend io.unix.launcher io.unix.select
namespaces kernel assocs unix.process init ;

TUPLE: linux-io ;

INSTANCE: linux-io unix-io

M: linux-io init-io ( -- )
    <select-mx> mx set-global ;

T{ linux-io } set-io-backend

[ start-wait-thread ] "io.unix.linux" add-init-hook