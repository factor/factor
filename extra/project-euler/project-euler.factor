! Copyright (c) 2007-2010 Aaron Schaefer, Samuel Tardieu.
! See https://factorcode.org/license.txt for BSD license.
USING: io kernel math.parser prettyprint sequences
vocabs.loader ;
IN: project-euler

<PRIVATE

: problem-prompt ( -- n )
    "Which problem number from Project Euler would you like to solve?"
    print flush readln string>number ;

: number>euler ( n -- str )
    number>string 3 CHAR: 0 pad-head ;

: solution-path ( n -- str/f )
    number>euler "project-euler." prepend vocab-source-path ;

PRIVATE>

: problem-solved? ( n -- ? )
    solution-path ;

: run-project-euler ( -- )
    problem-prompt dup problem-solved? [
        "Answer: " write
        dup number>euler "project-euler." prepend run
        "Source: " write solution-path .
    ] [
        drop "That problem has not been solved yet..." print
    ] if ;

MAIN: run-project-euler
