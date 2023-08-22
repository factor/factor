! Copyright (C) 2007, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.data assocs combinators
continuations environment fry io.backend io.backend.unix
io.files.private io.files.unix io.launcher io.launcher.private
io.pathnames io.ports kernel libc math namespaces sequences
simple-tokenizer strings system unix unix.ffi unix.process ;
QUALIFIED-WITH: unix.signals sig
IN: io.launcher.unix

: get-arguments ( process -- seq )
    command>> dup string? [ tokenize ] when ;

: assoc>env ( assoc -- env )
    [ "=" glue ] { } assoc>map ;

: setup-process-group ( process -- process )
    dup group>> {
        { +same-group+ [ ] }
        { +new-group+ [ 0 0 setpgid io-error ] }
        { +new-session+ [ setsid io-error ] }
    } case ;

: setup-priority ( process -- process )
    dup priority>> [
        {
            { +lowest-priority+ [ 20 ] }
            { +low-priority+ [ 10 ] }
            { +normal-priority+ [ 0 ] }
            { +high-priority+ [ -10 ] }
            { +highest-priority+ [ -20 ] }
            { +realtime-priority+ [ -20 ] }
        } case set-priority
    ] when* ;

: reset-fd ( fd -- )
    [ F_SETFL 0 fcntl io-error ] [ F_SETFD 0 fcntl io-error ] bi ;

: redirect-fd ( oldfd fd -- )
    2dup = [ 2drop ] [ dup2 io-error ] if ;

: redirect-file ( obj mode fd -- )
    [ [ normalize-path ] dip file-mode open-file ] dip redirect-fd ;

: redirect-file-append ( obj mode fd -- )
    [ drop path>> normalize-path open-append ] dip redirect-fd ;

: redirect-closed ( obj mode fd -- )
    [ drop "/dev/null" ] 2dip redirect-file ;

: redirect ( obj mode fd -- )
    {
        { [ pick not ] [ 3drop ] }
        { [ pick string? ] [ redirect-file ] }
        { [ pick appender? ] [ redirect-file-append ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick fd? ] [ [ drop fd>> dup reset-fd ] dip redirect-fd ] }
        [ [ underlying-handle ] 2dip redirect ]
    } cond ;

: ?closed ( obj -- obj' )
    dup +closed+ eq? [ drop "/dev/null" ] when ;

: setup-redirection ( process -- process )
    dup stdin>> ?closed read-flags 0 redirect
    dup stdout>> ?closed write-flags 1 redirect
    dup stderr>> dup +stdout+ eq? [
        drop 1 2 dup2 io-error
    ] [
        ?closed write-flags 2 redirect
    ] if ;

: setup-environment ( process -- process )
    dup pass-environment? [
        dup get-environment set-os-envs
    ] when ;

! Ignored signals are not reset to the default handler.
: reset-ignored-signals ( process -- process )
    SIGPIPE SIG_DFL signal drop ;

: fork-process ( process -- pid )
    [ reset-ignored-signals ] [ 2drop 248 _exit ] recover
    [ setup-process-group ] [ 2drop 249 _exit ] recover
    [ setup-priority ] [ 2drop 250 _exit ] recover
    [ setup-redirection ] [ 2drop 251 _exit ] recover
    [ current-directory get cd ] [ 2drop 252 _exit ] recover
    [ setup-environment ] [ 2drop 253 _exit ] recover
    [ get-arguments exec-args-with-path ] [ 2drop 254 _exit ] recover
    255 _exit
    f throw ;

: spawn-process ( process -- pid )
    [ reset-ignored-signals ] [ 2drop 248 _exit ] recover
    [ setup-process-group ] [ 2drop 249 _exit ] recover
    [ setup-priority ] [ 2drop 250 _exit ] recover
    [ setup-redirection ] [ 2drop 251 _exit ] recover
    [ current-directory get cd ] [ 2drop 252 _exit ] recover
    [ setup-environment ] [ 2drop 253 _exit ] recover
    [ get-arguments posix-spawn ] [ drop ] recover ;

M: unix (current-process) getpid ;

M: unix (run-process)
    '[ _ fork-process ] [ ] with-fork ;

M: unix (kill-process)
    [ handle>> SIGTERM ] [ group>> ] bi {
        { +same-group+ [ kill ] }
        { +new-group+ [ killpg ] }
        { +new-session+ [ killpg ] }
    } case io-error ;

: find-process ( handle -- process )
    processes get keys [ handle>> = ] with find nip ;

: code>status ( code -- obj )
    dup WIFSIGNALED [ WTERMSIG sig:signal boa ] [ WEXITSTATUS ] if ;

M: unix (wait-for-processes)
    { int } [ -1 swap WNOHANG waitpid ] with-out-parameters
    swap dup 0 <= [
        2drop t
    ] [
        find-process dup
        [ swap code>status notify-exit f ] [ 2drop f ] if
    ] if ;
