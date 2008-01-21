! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.c-types kernel io.nonblocking io.unix.backend
bit-arrays sequences assocs unix math namespaces structs ;
IN: io.unix.epoll

TUPLE: epoll-mx events ;

: max-events ( -- n )
    #! We read up to 256 events at a time. This is an arbitrary
    #! constant...
    256 ; inline

: <epoll-mx> ( -- mx )
    epoll-mx construct-mx
    max-events epoll_create dup io-error over set-mx-fd
    max-events "epoll-event" <c-array> over set-epoll-mx-events ;

GENERIC: io-task-events ( task -- n )

M: input-task drop EPOLLIN ;

M: output-task drop EPOLLOUT ;

: make-event ( task -- event )
    "epoll-event" <c-object>
    over io-task-events over set-epoll-event-events
    over io-task-fd over set-epoll-fd ;

: do-epoll-ctl ( task mx what -- )
    >r >r make-event r> mx-fd r> pick event-data *int roll
    epoll_ctl io-error ;

M: epoll-mx register-io-task ( task mx -- )
    EPOLL_CTL_ADD do-epoll-ctl ;

M: epoll-mx unregister-io-task ( task mx -- )
    EPOLL_CTL_DEL do-epoll-ctl ;

: wait-kevent ( mx timeout -- n )
    >r mx-fd epoll-mx-events max-events r> epoll_wait
    dup multiplexer-error ;

: epoll-read-task ( mx fd -- )
    over mx-reads at* [ handle-io-task ] [ 2drop ] if ;

: epoll-write-task ( mx fd -- )
    over mx-reads at* [ handle-io-task ] [ 2drop ] if ;

: handle-event ( mx kevent -- )
    epoll-event-fd 2dup epoll-read-task epoll-write-task ;

: handle-events ( mx n -- )
    [ over epoll-mx-events kevent-nth handle-kevent ] with each ;

M: epoll-mx wait-for-events ( ms mx -- )
    dup rot wait-kevent handle-kevents ;
