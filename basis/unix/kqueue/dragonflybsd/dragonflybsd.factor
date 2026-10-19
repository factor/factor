USING: alien.c-types alien.syntax classes.struct unix.time unix.types ;
IN: unix.kqueue

STRUCT: kevent
    { ident uintptr_t }
    { filter short }
    { flags ushort }
    { fflags uint }
    { data intptr_t }
    { udata void* }
    ;

FUNCTION-ALIAS: kevent-func int kevent ( int kq, kevent* changelist, int nchanges, kevent* eventlist, int nevents, timespec* timeout )

CONSTANT: EVFILT_READ -1
CONSTANT: EVFILT_WRITE -2
CONSTANT: EVFILT_AIO -3
CONSTANT: EVFILT_VNODE -4
CONSTANT: EVFILT_PROC -5
CONSTANT: EVFILT_SIGNAL -6
CONSTANT: EVFILT_TIMER -7
CONSTANT: EVFILT_EXCEPT -8
CONSTANT: EVFILT_USER -9
CONSTANT: EVFILT_FS -10
CONSTANT: EVFILT_SYSCOUNT 10
