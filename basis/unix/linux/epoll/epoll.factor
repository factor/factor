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

CONSTANT: EPOLL_CTL_ADD 1 ! Add a file decriptor to the interface.
CONSTANT: EPOLL_CTL_DEL 2 ! Remove a file decriptor from the interface.
CONSTANT: EPOLL_CTL_MOD 3 ! Change file decriptor epoll_event structure.

CONSTANT: EPOLLIN      HEX: 001
CONSTANT: EPOLLPRI     HEX: 002
CONSTANT: EPOLLOUT     HEX: 004
CONSTANT: EPOLLRDNORM  HEX: 040
CONSTANT: EPOLLRDBAND  HEX: 080
CONSTANT: EPOLLWRNORM  HEX: 100
CONSTANT: EPOLLWRBAND  HEX: 200
CONSTANT: EPOLLMSG     HEX: 400
CONSTANT: EPOLLERR     HEX: 008
CONSTANT: EPOLLHUP     HEX: 010
: EPOLLONESHOT ( -- n ) 30 2^ ; inline
: EPOLLET      ( -- n ) 31 2^ ; inline
