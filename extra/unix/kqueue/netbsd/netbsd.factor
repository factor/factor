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

