USE: alien.syntax
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

: EVFILT_READ     -1 ; inline
: EVFILT_WRITE    -2 ; inline
: EVFILT_AIO      -3 ; inline ! attached to aio requests
: EVFILT_VNODE    -4 ; inline ! attached to vnodes
: EVFILT_PROC     -5 ; inline ! attached to struct proc
: EVFILT_SIGNAL   -6 ; inline ! attached to struct proc
: EVFILT_TIMER    -7 ; inline ! timers
