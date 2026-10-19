! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data alien.syntax assocs continuations io.launcher
io.launcher.private io.launcher.unix kernel libc locals math namespaces system ;
IN: io.launcher.haiku

LIBRARY: factor
FUNCTION: int factor_haiku_prepare_process ( )
FUNCTION: int factor_haiku_watch_process ( int pid )
FUNCTION: int factor_haiku_next_process_exit ( int* pid, int* status )

M: haiku (run-process)
    factor_haiku_prepare_process io-error spawn-process ;

M:: haiku (process-started) ( process -- )
    [ process handle>> factor_haiku_watch_process io-error ] [
        ! Native registration failure already terminates/reaps this new child.
        process processes get delete-at
        process f >>handle drop
        rethrow
    ] recover ;

ERROR: unknown-owned-process pid ;

M:: haiku (wait-for-processes) ( -- ? )
    { int int } [ factor_haiku_next_process_exit ] with-out-parameters
    :> status :> pid :> available
    available io-error
    available zero? [ t ] [
        pid find-process dup [
            status code>status notify-exit f
        ] [ drop pid unknown-owned-process ] if
    ] if ;
