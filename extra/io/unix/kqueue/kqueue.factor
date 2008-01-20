! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel io.nonblocking io.unix.backend
io.unix.sockets sequences assocs unix unix.kqueue unix.process
math namespaces classes combinators threads vectors ;
IN: io.unix.kqueue

TUPLE: kqueue-mx events processes ;

: max-events ( -- n )
    #! We read up to 256 events at a time. This is an arbitrary
    #! constant...
    256 ; inline

: <kqueue-mx> ( -- mx )
    kqueue-mx construct-mx
    kqueue dup io-error over set-mx-fd
    H{ } clone over set-kqueue-mx-processes
    max-events "kevent" <c-array> over set-kqueue-mx-events ;

: io-task-filter ( task -- n )
    class {
        { read-task    [ EVFILT_READ  ] }
        { accept-task  [ EVFILT_READ  ] }
        { receive-task [ EVFILT_READ  ] }
        { write-task   [ EVFILT_WRITE ] }
        { connect-task [ EVFILT_WRITE ] }
        { send-task    [ EVFILT_WRITE ] }
    } case ;

: make-kevent ( task flags -- event )
    "kevent" <c-object>
    tuck set-kevent-flags
    over io-task-fd over set-kevent-ident
    swap io-task-filter over set-kevent-filter ;

: register-kevent ( kevent mx -- )
    mx-fd swap 1 f 0 f kevent io-error ;

M: kqueue-mx register-io-task ( task mx -- )
    over EV_ADD make-kevent over register-kevent
    delegate register-io-task ;

M: kqueue-mx unregister-io-task ( task mx -- )
    2dup delegate unregister-io-task
    swap EV_DELETE make-kevent swap register-kevent ;

: wait-kevent ( mx timespec -- n )
    >r dup mx-fd f 0 roll kqueue-mx-events max-events r> kevent
    dup multiplexer-error ;

: kevent-read-task ( mx fd -- )
    over mx-reads at handle-io-task ;

: kevent-write-task ( mx fd -- )
    over mx-reads at handle-io-task ;

: kevent-proc-task ( mx pid -- )
    dup (wait-for-pid) spin kqueue-mx-processes delete-at* [
        [ schedule-thread-with ] with each
    ] [ 2drop ] if ;

: handle-kevent ( mx kevent -- )
    dup kevent-ident swap kevent-filter {
        { [ dup EVFILT_READ = ] [ drop kevent-read-task ] }
        { [ dup EVFILT_WRITE = ] [ drop kevent-write-task ] }
        { [ dup EVFILT_PROC = ] [ drop kevent-proc-task ] }
    } cond ;

: handle-kevents ( mx n -- )
    [ over kqueue-mx-events kevent-nth handle-kevent ] with each ;

M: kqueue-mx unix-io-multiplex ( ms mx -- )
    swap make-timespec dupd wait-kevent handle-kevents ;

: make-proc-kevent ( pid -- kevent )
    "kevent" <c-object>
    tuck set-kevent-ident
    EV_ADD over set-kevent-flags
    EVFILT_PROC over set-kevent-filter
    NOTE_EXIT over set-kevent-fflags ;

: add-pid-task ( continuation pid mx -- )
    2dup kqueue-mx-processes at* [
        2nip push
    ] [
        drop
        over make-proc-kevent over register-kevent
        >r >r 1vector r> r> kqueue-mx-processes set-at
    ] if ;
