! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.c-types alien.syntax arrays classes.struct
classes.parser combinators kernel literals math system ;
IN: unix.linux.epoll

FUNCTION: int epoll_create ( int size )
FUNCTION: int epoll_create1 ( int flags )

CONSTANT: EPOLL_CLOEXEC $[
    cpu sparc? [ 0o20000000 ] [
        cpu alpha.64? cpu hppa? or 0o10000000 0o2000000 ?
    ] if
]

<<
: define-epoll-event-class ( class slots cpu -- )
    x86? [ define-packed-struct-class ] [ define-struct-class ] if ;
>>

<<
UNION-STRUCT: epoll-data
    { ptr void*    }
    { fd  int      }
    { u32 uint32_t }
    { u64 uint64_t } ;

"epoll-event" create-class-in
    "events" uint32_t
    "data" epoll-data [ f <struct-slot-spec> ] 2bi@ 2array
cpu define-epoll-event-class
>>

FUNCTION: int epoll_ctl ( int epfd, int op, int fd, epoll-event* event )

FUNCTION: int epoll_wait ( int epfd, epoll-event* events, int maxevents, int timeout )

CONSTANT: EPOLL_CTL_ADD 1 ! Add a file decriptor to the interface.
CONSTANT: EPOLL_CTL_DEL 2 ! Remove a file decriptor from the interface.
CONSTANT: EPOLL_CTL_MOD 3 ! Change file decriptor epoll_event structure.

CONSTANT: EPOLLIN      0x001
CONSTANT: EPOLLPRI     0x002
CONSTANT: EPOLLOUT     0x004
CONSTANT: EPOLLRDNORM  0x040
CONSTANT: EPOLLRDBAND  0x080
CONSTANT: EPOLLWRNORM  0x100
CONSTANT: EPOLLWRBAND  0x200
CONSTANT: EPOLLMSG     0x400
CONSTANT: EPOLLERR     0x008
CONSTANT: EPOLLHUP     0x010
CONSTANT: EPOLLRDHUP   0x2000
: EPOLLONESHOT ( -- n ) 30 2^ ; inline
: EPOLLET      ( -- n ) 31 2^ ; inline
