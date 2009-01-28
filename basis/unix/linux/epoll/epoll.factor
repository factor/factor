! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: unix.linux.epoll
USING: alien.syntax math ;

FUNCTION: int epoll_create ( int size ) ;

FUNCTION: int epoll_ctl ( int epfd, int op, int fd, epoll_event* event ) ;

C-STRUCT: epoll-event
    { "uint" "events" }
    { "uint" "fd" }
    { "uint" "padding" } ;

FUNCTION: int epoll_wait ( int epfd, epoll_event* events, int maxevents, int timeout ) ;

: EPOLL_CTL_ADD 1 ; inline ! Add a file decriptor to the interface.
: EPOLL_CTL_DEL 2 ; inline ! Remove a file decriptor from the interface.
: EPOLL_CTL_MOD 3 ; inline ! Change file decriptor epoll_event structure.

: EPOLLIN      HEX: 001 ; inline
: EPOLLPRI     HEX: 002 ; inline
: EPOLLOUT     HEX: 004 ; inline
: EPOLLRDNORM  HEX: 040 ; inline
: EPOLLRDBAND  HEX: 080 ; inline
: EPOLLWRNORM  HEX: 100 ; inline
: EPOLLWRBAND  HEX: 200 ; inline
: EPOLLMSG     HEX: 400 ; inline
: EPOLLERR     HEX: 008 ; inline
: EPOLLHUP     HEX: 010 ; inline
: EPOLLONESHOT 30 2^    ; inline
: EPOLLET      31 2^    ; inline
