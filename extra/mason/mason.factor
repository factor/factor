! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar continuations debugger io
io.directories io.pathnames io.sockets io.streams.string kernel
mason.config mason.disk mason.email mason.notify mason.updates
namespaces prettyprint threads ;
FROM: mason.build => build ;
IN: mason

: heartbeat-loop ( -- )
    notify-heartbeat
    5 minutes sleep
    heartbeat-loop ;

: fatal-error-body ( error callstack -- string )
    [
        "Fatal error on " write host-name print nl
        [ error. ] [ callstack. ] bi*
    ] with-string-writer ;

: build-loop-error ( error callstack -- )
    fatal-error-body
     "build loop error"
     email-fatal ;

: build-loop ( -- )
    [
        builds-dir get make-directories
        builds-dir get [
            check-disk-space
            update-sources
            build? [ build ] [ 5 minutes sleep ] if
        ] with-directory
    ] [
        error-continuation get call>> build-loop-error
        5 minutes sleep
    ] recover

    build-loop ;

: mason ( -- )
    [ heartbeat-loop ] "Heartbeat loop" spawn
    [ build-loop ] "Build loop" spawn
    stop ;

MAIN: mason
