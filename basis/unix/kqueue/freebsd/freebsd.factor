USING: alien.c-types alien.syntax classes.struct unix.types unix.time ;
IN: unix.kqueue

STRUCT: kevent
    { ident  __uint64_t }
    { filter short }
    { flags  ushort }
    { fflags uint }
    { data __int64_t }
    { udata  void* } 
    { ext __uint64_t[4] } ;

FUNCTION-ALIAS: kevent-func int kevent ( int kq, kevent* changelist, int nchanges, kevent* eventlist, int nevents, timespec* timeout )

! from FreeBSD 12 sys/sys/event.h

CONSTANT: EVFILT_READ     -1
CONSTANT: EVFILT_WRITE    -2
CONSTANT: EVFILT_AIO      -3 ! attached to aio requests
CONSTANT: EVFILT_VNODE    -4 ! attached to vnodes
CONSTANT: EVFILT_PROC     -5 ! attached to struct proc
CONSTANT: EVFILT_SIGNAL   -6 ! attached to struct proc
CONSTANT: EVFILT_TIMER    -7 ! timers
CONSTANT: EVFILT_PROCDESC -8 ! attached to process descriptors
CONSTANT: EVFILT_FS       -9 ! Filesystem events
CONSTANT: EVFILT_LIO      -10 ! attached to lio requests
CONSTANT: EVFILT_USER     -11 ! user events
CONSTANT: EVFILT_SENDFILE -12 ! attached to sendfile requests
CONSTANT: EVFILT_EMPTY    -13 ! empty send socket buf
CONSTANT: EVFILT_SYSCOUNT  13

