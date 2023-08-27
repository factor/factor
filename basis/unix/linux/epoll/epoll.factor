! Copyright (C) 2008, 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
IN: unix.linux.epoll
USING: alien.c-types alien.syntax classes.struct math
unix.types ;

FUNCTION: int epoll_create ( int size )

UNION-STRUCT: epoll-data
    { ptr void*    }
    { fd  int      }
    { u32 uint32_t }
    { u64 uint64_t } ;

PACKED-STRUCT: epoll-event
    { events uint32_t   }
    { data   epoll-data } ;

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
