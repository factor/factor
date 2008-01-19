! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel io.nonblocking io.unix.backend
sequences assocs unix unix.kqueue math namespaces ;
IN: io.unix.backend.kqueue

TUPLE: unix-kqueue-io ;

! Global variables
SYMBOL: kqueue-fd
SYMBOL: kqueue-changes
SYMBOL: kqueue-events

: max-events ( -- n )
    #! We read up to 256 events at a time. This is an arbitrary
    #! constant...
    256 ; inline

M: unix-kqueue-io init-unix-io ( -- )
    V{ } clone kqueue-changes set-global
    max-events "kevent" <c-array> kqueue-events set-global
    kqueue kqueue-fd dup io-error set-global ;

: add-change ( event -- ) kqueue-changes get-global push ;

: io-task-filter ( task -- n )
    class {
        { read-task    EVFILT_READ  }
        { accept-task  EVFILT_READ  }
        { receive-task EVFILT_READ  }
        { write-task   EVFILT_WRITE }
        { connect-task EVFILT_WRITE }
        { send-task    EVFILT_WRITE }
    } case ;

: make-kevent ( task -- event )
    "kevent" <c-object>
    over io-task-fd over set-kevent-ident
    over io-task-filter over set-kevent-filter ;

: make-add-kevent ( task -- event )
    make-kevent
    EV_ADD over set-kevent-flags ;

: make-delete-kevent ( task -- event )
    make-kevent
    EV_DELETE over set-kevent-flags ;

M: unix-select-io register-io-task ( task -- )
    make-add-kevent add-change ;

M: unix-select-io unregister-io-task ( task -- )
    make-delete-kevent add-change ;

: kqueue-changelist ( -- byte-array n )
    kqueue-changes get-global
    dup concat f like over length rot delete-all ;

: kqueue-eventlist ( -- byte-array n )
    kqueue-events get-global max-events ;

: do-kevent ( timespec -- n )
    >r
    kqueue-fd get-global
    kqueue-changelist
    kqueue-eventlist
    r> kevent dup multiplexer-error ;

: kevent-task ( kevent -- task )
    dup kevent-filter {
        { [ dup EVFILT_READ = ] [ read-tasks ] }
        { [ dup EVFILT_WRITE = ] [ write-tasks ] }
    } cond get at ;

: handle-kevents ( n eventlist -- )
    [ kevent-nth kevent-task handle-fd ] curry each ;

M: unix-select-io unix-io-multiplex ( ms -- )
    make-timespec
    do-kevent
    kqueue-events get-global handle-kevents ;

T{ unix-kqueue-io } unix-io-backend set-global
