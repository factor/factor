USING: alien.c-types alien.syntax classes.struct unix.time ;
IN: unix.kqueue

STRUCT: kevent
    { ident  ulong }
    { filter uint }
    { flags  uint }
    { fflags uint }
    { data   longlong }
    { udata  void* } ;

FUNCTION: int kevent ( int kq, kevent* changelist, size_t nchanges, kevent* eventlist, size_t nevents, timespec* timeout ) ;

CONSTANT: EVFILT_READ     0
CONSTANT: EVFILT_WRITE    1
CONSTANT: EVFILT_AIO      2 ! attached to aio requests
CONSTANT: EVFILT_VNODE    3 ! attached to vnodes
CONSTANT: EVFILT_PROC     4 ! attached to struct proc
CONSTANT: EVFILT_SIGNAL   5 ! attached to struct proc
CONSTANT: EVFILT_TIMER    6 ! timers
CONSTANT: EVFILT_SYSCOUNT 7 ! Filesystem events
