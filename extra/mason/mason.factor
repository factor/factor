! Copyright (C) 2008, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar continuations debugger io
io.directories io.files kernel mason.common
mason.email mason.updates mason.notify namespaces threads ;
FROM: mason.build => build ;
IN: mason

: build-loop-error ( error -- )
    [ "Build loop error:" print flush error. flush :c flush ]
    [ error-continuation get call>> email-error ] bi ;

: build-loop-fatal ( error -- )
    "FATAL BUILDER ERROR:" print
    error. flush ;

: build-loop ( -- )
    notify-heartbeat
    ?prepare-build-machine
    [
        [
            builds/factor set-current-directory
            new-code-available? [ build ] when
        ] [
            build-loop-error
        ] recover
    ] [
        build-loop-fatal
    ] recover
    5 minutes sleep
    build-loop ;

MAIN: build-loop