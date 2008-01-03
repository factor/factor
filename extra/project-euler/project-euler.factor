! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: definitions io io.files kernel math.parser sequences vocabs
    vocabs.loader project-euler.ave-time project-euler.common
    project-euler.001 project-euler.002 project-euler.003 project-euler.004
    project-euler.005 project-euler.006 project-euler.007 project-euler.008
    project-euler.009 project-euler.010 project-euler.011 project-euler.012
    project-euler.013 project-euler.014 project-euler.015 project-euler.016
    project-euler.017 project-euler.018 project-euler.019 project-euler.020
    project-euler.021 project-euler.022 project-euler.023 project-euler.024
    project-euler.067 project-euler.134 ;
IN: project-euler

<PRIVATE

: problem-prompt ( -- n )
    "Which problem number from Project Euler would you like to solve?"
    print readln string>number ;

: number>euler ( n -- str )
    number>string 3 CHAR: 0 pad-left ;

: solution-path ( n -- str/f )
    number>euler "project-euler." swap append
    vocab where dup [ first ?resource-path ] when ;

PRIVATE>

: problem-solved? ( n -- ? )
    solution-path ;

: run-project-euler ( -- )
    problem-prompt dup problem-solved? [
        dup number>euler "project-euler." swap append run
        "Answer: " swap number>string append print
        "Source: " swap solution-path append print
    ] [
        drop "That problem has not been solved yet..." print
    ] if ;

MAIN: run-project-euler
