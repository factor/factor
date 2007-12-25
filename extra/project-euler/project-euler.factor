! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: io io.files kernel math.parser namespaces sequences strings
    vocabs vocabs.loader system project-euler.ave-time
    project-euler.001 project-euler.002 project-euler.003 project-euler.004
    project-euler.005 project-euler.006 project-euler.007 project-euler.008
    project-euler.009 project-euler.010 project-euler.011 project-euler.012
    project-euler.013 project-euler.014 project-euler.015 project-euler.016
    project-euler.017 project-euler.018 project-euler.019 project-euler.020
    project-euler.067 ;
IN: project-euler

<PRIVATE

: problem-prompt ( -- n )
    "Which problem number from Project Euler would you like to solve?"
    print readln string>number ;

: number>euler ( n -- str )
    number>string string>digits 3 0 pad-left [ number>string ] map concat ;

: solution-path ( n -- str )
    number>euler dup [
        "project-euler" vocab-root ?resource-path %
        os "windows" = [
            "\\project-euler\\" % % "\\" % % ".factor" %
        ] [
            "/project-euler/" % % "/" % % ".factor" %
        ] if
    ] "" make ;

PRIVATE>

: problem-solved? ( n -- ? )
    solution-path exists? ;

: run-project-euler ( -- )
    problem-prompt dup problem-solved? [
        dup number>euler "project-euler." swap append run
        "Answer: " swap number>string append print
        "Source: " swap solution-path append print
    ] [
        drop "That problem has not been solved yet..." print
    ] if ;

MAIN: run-project-euler
