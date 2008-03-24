USING: alien.syntax kernel io.process io.unix.backend
unix ;
IN: io.unix.process

M: unix-io current-priority ( -- n )
    clear_err_no
    0 0 getpriority dup -1 = [ check-errno ] when ;

M: unix-io set-current-priority ( n -- )
    0 0 rot setpriority io-error ;

M: unix-io priority-values ( -- assoc )
    {
        { +lowest-priority+ 20 }
        { +low-priority+ 10 }
        { +normal-priority+ 0 }
        { +high-priority+ -10 }
        { +highest-priority+ -20 }
    } ;
