USE: alien.syntax
IN: unix.kqueue

C-STRUCT: kevent
    { "ulong"  "ident"  } ! identifier for this event
    { "short"  "filter" } ! filter for event
    { "ushort" "flags"  } ! action flags for kqueue
    { "uint"   "fflags" } ! filter flag value
    { "long"   "data"   } ! filter data value
    { "void*"  "udata"  } ! opaque user data identifier
;

FUNCTION: int kevent ( int kq, kevent* changelist, int nchanges, kevent* eventlist, int nevents, timespec* timeout ) ;
