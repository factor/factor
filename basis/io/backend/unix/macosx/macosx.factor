! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.backend system namespaces
io.backend.unix.multiplexers io.backend.unix.multiplexers.run-loop
kernel accessors assocs continuations unix io.backend.unix
io.backend.unix.multiplexers.kqueue io.files.unix init ;
IN: io.backend.unix.macosx

SINGLETON: macosx-kqueue

M: macosx-kqueue init-io ( -- )
    <kqueue-mx> mx set-global ;

M: macosx init-io ( -- )
    <run-loop-mx> mx set-global ;

macosx set-io-backend

[ start-signal-pipe-thread ] "io.backend.unix:signal-pipe-thread" add-startup-hook
