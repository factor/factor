! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel namespaces math system sequences debugger
continuations arrays assocs combinators alien.c-types strings
threads accessors
io io.backend io.launcher io.nonblocking io.files
io.files.private io.unix.files io.unix.backend
io.unix.launcher.parser
unix unix.process ;
IN: io.unix.launcher

! Search unix first
USE: unix

: get-arguments ( process -- seq )
    command>> dup string? [ tokenize-command ] when ;

: assoc>env ( assoc -- env )
    [ "=" swap 3append ] { } assoc>map ;

: setup-priority ( process -- process )
    dup priority>> [
        H{
            { +lowest-priority+ 20 }
            { +low-priority+ 10 }
            { +normal-priority+ 0 }
            { +high-priority+ -10 }
            { +highest-priority+ -20 }
            { +realtime-priority+ -20 }
        } at set-priority
    ] when* ;

: redirect-fd ( oldfd fd -- )
    2dup = [ 2drop ] [ dupd dup2 io-error close ] if ;

: reset-fd ( fd -- )
    #! We drop the error code because on *BSD, fcntl of
    #! /dev/null fails.
    [ F_SETFL 0 fcntl drop ]
    [ F_SETFD 0 fcntl drop ] bi ;

: redirect-inherit ( obj mode fd -- )
    2nip reset-fd ;

: redirect-file ( obj mode fd -- )
    >r >r normalize-path r> file-mode
    open-file r> redirect-fd ;

: redirect-file-append ( obj mode fd -- )
    >r drop path>> normalize-path open-append r> redirect-fd ;

: redirect-closed ( obj mode fd -- )
    >r >r drop "/dev/null" r> r> redirect-file ;

: redirect ( obj mode fd -- )
    {
        { [ pick not ] [ redirect-inherit ] }
        { [ pick string? ] [ redirect-file ] }
        { [ pick appender? ] [ redirect-file-append ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick integer? ] [ >r drop dup reset-fd r> redirect-fd ] }
        [ >r >r underlying-handle r> r> redirect ]
    } cond ;

: ?closed dup +closed+ eq? [ drop "/dev/null" ] when ;

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

: spawn-process ( process -- * )
    [ setup-priority ] [ 250 _exit ] recover
    [ setup-redirection ] [ 251 _exit ] recover
    [ current-directory get (normalize-path) cd ] [ 252 _exit ] recover
    [ setup-environment ] [ 253 _exit ] recover
    [ get-arguments exec-args-with-path ] [ 254 _exit ] recover
    255 _exit ;

M: unix current-process-handle ( -- handle ) getpid ;

M: unix run-process* ( process -- pid )
    [ spawn-process ] curry [ ] with-fork ;

M: unix kill-process* ( pid -- )
    SIGTERM kill io-error ;

: find-process ( handle -- process )
    processes get swap [ nip swap handle>> = ] curry
    assoc-find 2drop ;

M: unix wait-for-processes ( -- ? )
    -1 0 <int> tuck WNOHANG waitpid
    dup 0 <= [
        2drop t
    ] [
        find-process dup [
            swap *int WEXITSTATUS notify-exit f
        ] [
            2drop f
        ] if
    ] if ;
