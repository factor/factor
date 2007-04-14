! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.backend io.launcher io.nonblocking io.unix.backend
io.unix.files io.nonblocking sequences kernel namespaces math
system alien.c-types debugger continuations arrays assocs
combinators unix.process strings threads unix
io.unix.launcher.parser accessors io.files ;
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

: reset-fd ( fd -- ) F_SETFL 0 fcntl io-error ;

: redirect-inherit ( obj mode fd -- )
    2nip reset-fd ;

: redirect-file ( obj mode fd -- )
    >r >r normalize-pathname r> file-mode
    open dup io-error r> redirect-fd ;

: redirect-closed ( obj mode fd -- )
    >r >r drop "/dev/null" r> r> redirect-file ;

: redirect-stream ( obj mode fd -- )
    >r drop underlying-handle dup reset-fd r> redirect-fd ;

: redirect ( obj mode fd -- )
    {
        { [ pick not ] [ redirect-inherit ] }
        { [ pick string? ] [ redirect-file ] }
        { [ pick +closed+ eq? ] [ redirect-closed ] }
        { [ pick +inherit+ eq? ] [ redirect-closed ] }
        { [ t ] [ redirect-stream ] }
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

: spawn-process ( process -- * )
    [
        setup-priority
        setup-redirection
        current-directory get cd
        dup pass-environment? [
            dup get-environment set-os-envs
        ] when

        get-arguments exec-args-with-path
        (io-error)
    ] [ 255 exit ] recover ;

M: unix-io current-process-handle ( -- handle ) getpid ;

M: unix-io run-process* ( process -- pid )
    [ spawn-process ] curry [ ] with-fork ;

M: unix-io kill-process* ( pid -- )
    SIGTERM kill io-error ;

: open-pipe ( -- pair )
    2 "int" <c-array> dup pipe zero?
    [ 2 c-int-array> ] [ drop f ] if ;

: setup-stdio-pipe ( stdin stdout -- )
    2dup first close second close
    >r first 0 dup2 drop r> second 1 dup2 drop ;

M: unix-io (process-stream)
    >r open-pipe open-pipe r>
    [ >r setup-stdio-pipe r> spawn-process ] curry
    [ -rot 2dup second close first close ]
    with-fork
    first swap second ;

: find-process ( handle -- process )
    processes get swap [ nip swap handle>> = ] curry
    assoc-find 2drop ;

! Inefficient process wait polling, used on Linux and Solaris.
! On BSD and Mac OS X, we use kqueue() which scales better.
: wait-for-processes ( -- ? )
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

: start-wait-thread ( -- )
    [ wait-for-processes [ 250 sleep ] when t ]
    "Process reaper" spawn-server drop ;
