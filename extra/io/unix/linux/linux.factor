! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.linux
USING: io.backend io.unix.backend io.unix.launcher io.unix.epoll
namespaces kernel assocs unix.process ;

TUPLE: linux-io ;

INSTANCE: linux-io unix-io

M: linux-io init-io ( -- )
    <epoll-mx> mx set-global
    start-wait-loop ;

M: linux-io wait-for-process ( pid -- status )
    wait-for-pid ;

T{ linux-io } io-backend set-global
