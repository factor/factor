USING: alien.libraries kernel vocabs vocabs.loader ;
IN: unix.kqueue

! NetBSD 11 added kevent extensions and the __kevent100 entry point.
! Select the structure and call together for the native libc ABI.
<< "__kevent100" f dlsym?
   [ "unix.kqueue.netbsd.current" ] [ "unix.kqueue.netbsd.compat" ] if require >>

CONSTANT: EVFILT_READ 0
CONSTANT: EVFILT_WRITE 1
CONSTANT: EVFILT_AIO 2
CONSTANT: EVFILT_VNODE 3
CONSTANT: EVFILT_PROC 4
CONSTANT: EVFILT_SIGNAL 5
CONSTANT: EVFILT_TIMER 6
CONSTANT: EVFILT_FS 7
CONSTANT: EVFILT_USER 8
CONSTANT: EVFILT_EMPTY 9
CONSTANT: EVFILT_SYSCOUNT 10
