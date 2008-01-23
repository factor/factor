! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: io.unix.bsd
USING: io.backend io.unix.backend io.unix.kqueue io.unix.select
io.unix.launcher namespaces kernel assocs threads continuations
;

! On *BSD and Mac OS X, we use select() for the top-level
! multiplexer, and we hang a kqueue off of it but file change
! notification and process exit notification.

! kqueue is buggy with files and ptys so we can't use it as the
! main multiplexer.

TUPLE: bsd-io ;

INSTANCE: bsd-io unix-io

M: bsd-io init-io ( -- )
    <select-mx> mx set-global
    <kqueue-mx> kqueue-mx set-global
    kqueue-mx get-global <mx-port> <mx-task> dup io-task-fd
    2dup mx get-global mx-reads set-at
    mx get-global mx-writes set-at ;

M: bsd-io wait-for-process ( pid -- status )
    [ kqueue-mx get-global add-pid-task stop ] curry callcc1 ;

T{ bsd-io } set-io-backend
