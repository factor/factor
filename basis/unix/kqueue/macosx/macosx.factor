USING: alien.c-types alien.syntax classes.struct unix.time ;
IN: unix.kqueue

STRUCT: kevent
    { ident  ulong }
    { filter short }
    { flags  ushort }
    { fflags uint }
    { data   long }
    { udata  void* } ;

FUNCTION-ALIAS: kevent-func int kevent ( int kq, kevent* changelist, int nchanges, kevent* eventlist, int nevents, timespec* timeout )

CONSTANT: EVFILT_READ     -1
CONSTANT: EVFILT_WRITE    -2
CONSTANT: EVFILT_AIO      -3 ! attached to aio requests
CONSTANT: EVFILT_VNODE    -4 ! attached to vnodes
CONSTANT: EVFILT_PROC     -5 ! attached to struct proc
CONSTANT: EVFILT_SIGNAL   -6 ! attached to struct proc
CONSTANT: EVFILT_TIMER    -7 ! timers
CONSTANT: EVFILT_MACHPORT -8 ! Mach ports
CONSTANT: EVFILT_FS       -9 ! Filesystem events
