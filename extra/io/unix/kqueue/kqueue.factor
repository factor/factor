! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel math math.bitfields namespaces
locals accessors combinators threads vectors hashtables
sequences assocs continuations
unix unix.time unix.kqueue unix.process
io.nonblocking io.unix.backend io.launcher io.unix.launcher
io.monitors ;
IN: io.unix.kqueue

TUPLE: kqueue-mx < mx events monitors ;

: max-events ( -- n )
    #! We read up to 256 events at a time. This is an arbitrary
    #! constant...
    256 ; inline

: <kqueue-mx> ( -- mx )
    kqueue-mx construct-mx
        H{ } clone >>monitors
        kqueue dup io-error >>fd
        max-events "kevent" <c-array> >>events ;

GENERIC: io-task-filter ( task -- n )

M: input-task io-task-filter drop EVFILT_READ ;

M: output-task io-task-filter drop EVFILT_WRITE ;

GENERIC: io-task-fflags ( task -- n )

M: io-task io-task-fflags drop 0 ;

: make-kevent ( task flags -- event )
    "kevent" <c-object>
    tuck set-kevent-flags
    over io-task-fd over set-kevent-ident
    over io-task-fflags over set-kevent-fflags
    swap io-task-filter over set-kevent-filter ;

: register-kevent ( kevent mx -- )
    fd>> swap 1 f 0 f kevent
    0 < [ err_no ESRCH = [ (io-error) ] unless ] when ;

M: kqueue-mx register-io-task ( task mx -- )
    [ >r EV_ADD make-kevent r> register-kevent ]
    [ call-next-method ]
    2bi ;

M: kqueue-mx unregister-io-task ( task mx -- )
    [ call-next-method ]
    [ >r EV_DELETE make-kevent r> register-kevent ]
    2bi ;

: wait-kevent ( mx timespec -- n )
    >r [ fd>> f 0 ] keep events>> max-events r> kevent
    dup multiplexer-error ;

:: kevent-read-task ( mx fd kevent -- )
    mx fd mx reads>> at handle-io-task ;

:: kevent-write-task ( mx fd kevent -- )
    mx fd mx writes>> at handle-io-task ;

:: kevent-proc-task ( mx pid kevent -- )
    pid wait-for-pid
    pid find-process
    dup [ swap notify-exit ] [ 2drop ] if ;

: parse-action ( mask -- changed )
    [
        NOTE_DELETE +remove-file+ ?flag
        NOTE_WRITE +modify-file+ ?flag
        NOTE_EXTEND +modify-file+ ?flag
        NOTE_ATTRIB +modify-file+ ?flag
        NOTE_RENAME +rename-file+ ?flag
        NOTE_REVOKE +remove-file+ ?flag
        drop
    ] { } make prune ;

:: kevent-vnode-task ( mx kevent fd -- )
    ""
    kevent kevent-fflags parse-action
    fd mx monitors>> at queue-change ;

: handle-kevent ( mx kevent -- )
    [ ] [ kevent-ident ] [ kevent-filter ] tri {
        { [ dup EVFILT_READ = ] [ drop kevent-read-task ] }
        { [ dup EVFILT_WRITE = ] [ drop kevent-write-task ] }
        { [ dup EVFILT_PROC = ] [ drop kevent-proc-task ] }
        { [ dup EVFILT_VNODE = ] [ drop kevent-vnode-task ] }
    } cond ;

: handle-kevents ( mx n -- )
    [ over events>> kevent-nth handle-kevent ] with each ;

M: kqueue-mx wait-for-events ( ms mx -- )
    swap dup [ make-timespec ] when
    dupd wait-kevent handle-kevents ;

! Procs
: make-proc-kevent ( pid -- kevent )
    "kevent" <c-object>
    tuck set-kevent-ident
    EV_ADD over set-kevent-flags
    EVFILT_PROC over set-kevent-filter
    NOTE_EXIT over set-kevent-fflags ;

: register-pid-task ( pid mx -- )
    swap make-proc-kevent swap register-kevent ;

! VNodes
TUPLE: vnode-monitor < monitor fd ;

: vnode-fflags ( -- n )
    {
        NOTE_DELETE
        NOTE_WRITE
        NOTE_EXTEND
        NOTE_ATTRIB
        NOTE_LINK
        NOTE_RENAME
        NOTE_REVOKE
    } flags ;

: make-vnode-kevent ( fd flags -- kevent )
    "kevent" <c-object>
    tuck set-kevent-flags
    tuck set-kevent-ident
    EVFILT_VNODE over set-kevent-filter
    vnode-fflags over set-kevent-fflags ;

: register-monitor ( monitor mx -- )
    >r dup fd>> r>
    [ >r EV_ADD EV_CLEAR bitor make-vnode-kevent r> register-kevent drop ]
    [ monitors>> set-at ] 3bi ;

: unregister-monitor ( monitor mx -- )
    >r fd>> r>
    [ monitors>> delete-at ]
    [ >r EV_DELETE make-vnode-kevent r> register-kevent ] 2bi ;

: <vnode-monitor> ( path mailbox -- monitor )
    >r [ O_RDONLY 0 open dup io-error ] keep r>
    vnode-monitor construct-monitor swap >>fd
    [ dup kqueue-mx get register-monitor ] [ ] [ fd>> close ] cleanup ;

M: vnode-monitor dispose
    [ kqueue-mx get unregister-monitor ] [ fd>> close ] bi ;
