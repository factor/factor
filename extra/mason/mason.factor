! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar continuations debugger io
io.directories io.files kernel math math.order mason.common
mason.email mason.updates mason.notify namespaces threads
combinators io.pathnames io.files.info ;
FROM: mason.build => build ;
IN: mason

SYMBOL: last-email-time

SYMBOL: next-email-time

: send-email-throttled? ( -- ? )
    ! We sent too many errors. See if its time to send a new
    ! one again.
    now next-email-time get-global after?
    [ f next-email-time set-global t ] [ f ] if ;

: throttle-time ( -- dt ) 6 hours ;

: throttle-emails ( -- )
    ! Last e-mail was less than 20 minutes ago. Don't send any
    ! errors for 4 hours.
    throttle-time hence next-email-time set-global
    f last-email-time set-global ;

: maximum-frequency ( -- dt ) 30 minutes ;

: send-email-capped? ( -- ? )
    ! We're about to send an error after sending another one.
    ! See if we should start throttling emails.
    last-email-time get-global
    maximum-frequency ago
    after?
    [ throttle-emails f ] [ t ] if ;

: send-email? ( -- ? )
    {
        { [ next-email-time get-global ] [ send-email-throttled? ] }
        { [ last-email-time get-global ] [ send-email-capped? ] }
        [ now last-email-time set-global t ]
    } cond
    dup [ now last-email-time set-global ] when ;

: email-fatal-error ( error -- )
    send-email? [
        now last-email-time set-global
        error-continuation get call>> email-error
    ] [ drop ] if ;

: build-loop-error ( error -- )
    [ "Build loop error:" print flush error. flush :c flush ]
    [ email-fatal-error ]
    bi ;

: mb ( m -- n ) 1024 * 1024 * ; inline

: sufficient-disk-space? ( -- ? )
    ! We want at least 300Mb to be available before starting
    ! a build.
    current-directory get file-system-info available-space>>
    300 mb > ;

: check-disk-space ( -- )
    sufficient-disk-space? [
        "Less than 300 Mb free disk space." throw
    ] unless ;

: build-loop ( -- )
    ?prepare-build-machine
    notify-heartbeat
    [
        builds/factor [
            check-disk-space
            update-code
            build? [ build ] [ 5 minutes sleep ] if
        ] with-directory
    ] [
        build-loop-error
        5 minutes sleep
    ] recover
    build-loop ;

MAIN: build-loop