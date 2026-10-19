USING: alien.c-types alien.syntax classes.struct unix.time unix.types ;
IN: unix.kqueue

STRUCT: kevent
    { ident uintptr_t }
    { filter uint }
    { flags uint }
    { fflags uint }
    { data longlong }
    { udata void* }
    ;

FUNCTION-ALIAS: kevent-func int __kevent50 ( int kq, kevent* changelist, int nchanges, kevent* eventlist, int nevents, timespec* timeout )

