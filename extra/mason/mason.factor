! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors calendar continuations debugger debugger io
io.directories io.files kernel mason.build mason.common
mason.email mason.updates namespaces threads ;
IN: mason

: build-loop-error ( error -- )
    [ "Build loop error:" print flush error. flush ]
    [ error-continuation get call>> email-error ] bi ;

: build-loop-fatal ( error -- )
    "FATAL BUILDER ERROR:" print
    error. flush ;

: build-loop ( -- )
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