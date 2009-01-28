! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel system namespaces io.backend io.unix.backend
io.unix.multiplexers io.unix.multiplexers.epoll ;
IN: io.unix.linux

M: linux init-io ( -- )
    <epoll-mx> mx set-global ;

linux set-io-backend
