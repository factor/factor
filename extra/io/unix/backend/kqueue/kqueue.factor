! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel io.nonblocking io.unix.backend
io.unix.sockets sequences assocs unix unix.kqueue math
namespaces classes combinators ;
IN: io.unix.backend.kqueue

TUPLE: unix-kqueue-io ;

! Global variables
SYMBOL: kqueue-fd
SYMBOL: kqueue-events

: max-events ( -- n )
    #! We read up to 256 events at a time. This is an arbitrary
    #! constant...
    256 ; inline

M: unix-kqueue-io init-unix-io ( -- )
    max-events "kevent" <c-array> kqueue-events set-global
    kqueue dup io-error kqueue-fd set-global ;

: io-task-filter ( task -- n )
    class {
        { read-task    [ EVFILT_READ  ] }
        { accept-task  [ EVFILT_READ  ] }
        { receive-task [ EVFILT_READ  ] }
        { write-task   [ EVFILT_WRITE ] }
        { connect-task [ EVFILT_WRITE ] }
        { send-task    [ EVFILT_WRITE ] }
    } case ;

: make-kevent ( task -- event )
    "kevent" <c-object>
    over io-task-fd over set-kevent-ident
    swap io-task-filter over set-kevent-filter ;

: register-kevent ( task flags -- )
    >r make-kevent r> over set-kevent-flags
    kqueue-fd get-global swap 1 f 0 f kevent io-error ;

: make-add-kevent ( task -- event )
    make-kevent
    EV_ADD over set-kevent-flags ;

: make-delete-kevent ( task -- event )
    make-kevent
    EV_DELETE over set-kevent-flags ;

M: unix-kqueue-io register-io-task ( task -- )
    EV_ADD EV_ENABLE bitor register-kevent ;

M: unix-kqueue-io unregister-io-task ( task -- )
    EV_DELETE EV_DISABLE bitor register-kevent ;

: wait-kevent ( timespec -- n )
    >r
    kqueue-fd get-global
    f 0 kqueue-events get-global max-events
    r> kevent dup multiplexer-error ;

: kevent-task ( kevent -- task )
    dup kevent-ident swap kevent-filter {
        { [ dup EVFILT_READ = ] [ read-tasks ] }
        { [ dup EVFILT_WRITE = ] [ write-tasks ] }
    } cond nip get at ;

: handle-kevents ( n eventlist -- )
    [ kevent-nth kevent-task handle-fd ] curry each ;

M: unix-kqueue-io unix-io-multiplex ( ms -- )
    make-timespec
    wait-kevent
    kqueue-events get-global handle-kevents ;

T{ unix-kqueue-io } unix-io-backend set-global
