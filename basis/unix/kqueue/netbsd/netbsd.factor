USING: alien.syntax ;
IN: unix.kqueue

C-STRUCT: kevent
    { "ulong"    "ident"  } ! identifier for this event
    { "uint"     "filter" } ! filter for event
    { "uint"     "flags"  } ! action flags for kqueue
    { "uint"     "fflags" } ! filter flag value
    { "longlong" "data"   } ! filter data value
    { "void*"    "udata"  } ! opaque user data identifier
;

FUNCTION: int kevent ( int kq, kevent* changelist, size_t nchanges, kevent* eventlist, size_t nevents, timespec* timeout ) ;

CONSTANT: EVFILT_READ     0
CONSTANT: EVFILT_WRITE    1
CONSTANT: EVFILT_AIO      2 ! attached to aio requests
CONSTANT: EVFILT_VNODE    3 ! attached to vnodes
CONSTANT: EVFILT_PROC     4 ! attached to struct proc
CONSTANT: EVFILT_SIGNAL   5 ! attached to struct proc
CONSTANT: EVFILT_TIMER    6 ! timers
CONSTANT: EVFILT_SYSCOUNT 7 ! Filesystem events
