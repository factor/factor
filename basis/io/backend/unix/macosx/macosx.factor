! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: init io.backend io.backend.unix
io.backend.unix.multiplexers io.backend.unix.multiplexers.kqueue
io.backend.unix.multiplexers.run-loop namespaces system vocabs ;
<< "io.files.unix" require >> ! needed for deploy
IN: io.backend.unix.macosx

SINGLETON: macosx-kqueue

M: macosx-kqueue init-io
    <kqueue-mx> mx set-global ;

M: macosx init-io
    <run-loop-mx> mx set-global ;

macosx set-io-backend

STARTUP-HOOK: start-signal-pipe-thread
