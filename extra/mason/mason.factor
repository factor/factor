! Copyright (C) 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel debugger io io.files threads debugger continuations
namespaces accessors calendar mason.common mason.updates
mason.build mason.email ;
IN: mason

: build-loop-error ( error -- )
    error-continuation get call>> email-error ;

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