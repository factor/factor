! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.linux
USING: io.unix.backend io.unix.select namespaces kernel assocs ;

TUPLE: linux-io ;

INSTANCE: linux-io unix-io

M: linux-io init-io ( -- )
    start-wait-loop
    <epoll-mx> mx set-global ;

M: linux-io wait-for-pid ( pid -- status )
    [ kqueue-mx get-global add-pid-task stop ] curry callcc1 ;

T{ linux-io } io-backend set-global
