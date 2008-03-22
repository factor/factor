USING: alien.syntax kernel io.priority io.unix.backend
unix ;
IN: io.unix.priority

: PRIO_PROCESS 0 ; inline
: PRIO_PGRP 1 ; inline
: PRIO_USER 2 ; inline

: PRIO_MIN -20 ; inline
: PRIO_MAX 20 ; inline

! which/who = 0 for current process
FUNCTION: int getpriority ( int which, int who ) ;
FUNCTION: int setpriority ( int which, int who, int prio ) ;

M: unix-io get-priority ( -- n )
    clear_err_no
    0 0 getpriority dup -1 = [ check-errno ] when ;

M: unix-io set-priority ( n -- )
    0 0 rot setpriority io-error ;
