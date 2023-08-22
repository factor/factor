! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar continuations debugger io
io.directories io.pathnames io.sockets io.streams.string kernel
make mason.build mason.common mason.config mason.disk
mason.email mason.notify mason.updates namespaces prettyprint
sequences threads ;
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
            should-build? [ do-build ] [ 5 minutes sleep ] if
        ] with-directory
    ] [
        error-continuation get call>> build-loop-error
        5 minutes sleep
    ] recover

    build-loop ;

: check-host ( user host -- )
    "@" glue [
        scp-command get ,
        "resource:LICENSE.txt" absolute-path canonicalize-path ,
        ":" append ,
    ] { } make short-running-process ;

: check-hosts ( -- )
    branch-username get branch-host get check-host
    package-username get package-host get check-host
    image-username get image-host get check-host
    upload-docs? get [
        docs-username get docs-host get check-host
    ] when ;

: run-mason ( -- )
    check-hosts
    [ heartbeat-loop ] "Heartbeat loop" spawn
    [ build-loop ] "Build loop" spawn
    stop ;

MAIN: run-mason
