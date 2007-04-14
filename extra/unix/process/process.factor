USING: kernel alien.c-types sequences math unix
combinators.cleave vectors kernel namespaces continuations
threads assocs vectors io.unix.backend ;

IN: unix.process

! Low-level Unix process launching utilities. These are used
! to implement io.launcher on Unix. User code should use
! io.launcher instead.

: >argv ( seq -- alien )
    [ malloc-char-string ] map f add >c-void*-array ;

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
    fork dup io-error dup zero? -roll swap curry if ; inline

: wait-for-pid ( pid -- status )
    0 <int> [ 0 waitpid drop ] keep *int WEXITSTATUS ;

: set-priority ( n -- )
    0 0 rot setpriority io-error ;