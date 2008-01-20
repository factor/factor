USING: kernel alien.c-types sequences math unix
combinators.cleave vectors kernel namespaces continuations
threads assocs vectors ;

IN: unix.process

! Low-level Unix process launching utilities. These are used
! to implement io.launcher on Unix. User code should use
! io.launcher instead.

: >argv ( seq -- alien ) [ malloc-char-string ] map f add >c-void*-array ;

: exec ( pathname argv -- int )
    [ malloc-char-string ] [ >argv ] bi* execv ;

: exec-with-path ( filename argv -- int )
    [ malloc-char-string ] [ >argv ] bi* execvp ;

: exec-with-env ( filename argv envp -- int )
    [ malloc-char-string ] [ >argv ] [ >argv ] tri* execve ;

: exec-args ( seq -- int )
    [ first ] [ ] bi exec ;

: exec-args-with-path ( seq -- int )
    [ first ] [ ] bi exec-with-path ;

: exec-args-with-env  ( seq seq -- int )
    >r [ first ] [ ] bi r> exec-with-env ;

: with-fork ( child parent -- )
    fork dup zero? -roll swap curry if ; inline

! Lame polling strategy for getting process exit codes. On
! BSD, we use kqueue which is more efficient.

SYMBOL: pid-wait

: (wait-for-pid) ( pid -- status )
    0 <int> [ 0 waitpid drop ] keep *int ;

: wait-for-pid ( pid -- status )
    [ pid-wait get-global [ ?push ] change-at stop ] curry
    callcc1 ;

: wait-loop ( -- )
    -1 0 <int> tuck WNOHANG waitpid               ! &status return
    [ *int ] [ pid-wait get delete-at* drop ] bi* ! status ?
    [ schedule-thread-with ] with each
    250 sleep
    wait-loop ;

: start-wait-loop ( -- )
    H{ } clone pid-wait set-global
    [ wait-loop ] in-thread ;