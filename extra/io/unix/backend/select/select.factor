! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax kernel io.nonblocking io.unix.backend
bit-arrays sequences assocs unix math namespaces ;
IN: io.unix.backend.select

TUPLE: unix-select-io ;

! Global variables
SYMBOL: read-fdset
SYMBOL: write-fdset

M: unix-select-io init-unix-io ( -- )
    FD_SETSIZE 8 * <bit-array> read-fdset set-global
    FD_SETSIZE 8 * <bit-array> write-fdset set-global ;

: handle-fdset ( fdset tasks -- )
    swap [
        swap dup io-task-port timeout? [
            nip handle-timeout
        ] [
            tuck io-task-fd swap nth
            [ handle-fd ] [ drop ] if
        ] if drop
    ] curry assoc-each ;

: init-fdset ( fdset tasks -- )
    swap dup clear-bits
    [ >r drop t swap r> set-nth ] curry assoc-each ;

: read-fdset/tasks
    read-fdset get-global read-tasks get-global ;

: write-fdset/tasks
    write-fdset get-global write-tasks get-global ;

: init-fdsets ( -- read write except )
    read-fdset/tasks dupd init-fdset
    write-fdset/tasks dupd init-fdset
    f ;

M: unix-select-io register-io-task ( task -- ) drop ;

M: unix-select-io unregister-io-task ( task -- ) drop ;

M: unix-select-io unix-io-multiplex ( timeval -- )
    >r FD_SETSIZE init-fdsets r> select 0 < [
        err_no ignorable-error? [ (io-error) ] unless
    ] when
    read-fdset/tasks handle-fdset
    write-fdset/tasks handle-fdset ;

T{ unix-select-io } unix-io-backend set-global
