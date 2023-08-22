! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel system namespaces io.files.unix io.backend
io.backend.unix io.backend.unix.multiplexers
io.backend.unix.multiplexers.epoll init ;
IN: io.backend.unix.linux

M: linux init-io
    <epoll-mx> mx set-global ;

linux set-io-backend

STARTUP-HOOK: start-signal-pipe-thread
