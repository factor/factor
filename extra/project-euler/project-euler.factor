! Copyright (c) 2007, 2008 Aaron Schaefer, Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: definitions io io.files kernel math math.parser project-euler.ave-time
    sequences vocabs vocabs.loader
    project-euler.001 project-euler.002 project-euler.003 project-euler.004
    project-euler.005 project-euler.006 project-euler.007 project-euler.008
    project-euler.009 project-euler.010 project-euler.011 project-euler.012
    project-euler.013 project-euler.014 project-euler.015 project-euler.016
    project-euler.017 project-euler.018 project-euler.019 project-euler.020
    project-euler.021 project-euler.022 project-euler.023 project-euler.024
    project-euler.025 project-euler.026 project-euler.027 project-euler.028
    project-euler.029 project-euler.030 project-euler.031 project-euler.032
    project-euler.033 project-euler.034 project-euler.035 project-euler.036
    project-euler.037 project-euler.038 project-euler.039 project-euler.040
    project-euler.041 project-euler.042 project-euler.043 project-euler.044
    project-euler.045 project-euler.046 project-euler.047 project-euler.048
    project-euler.052 project-euler.053 project-euler.056 project-euler.059
    project-euler.067 project-euler.075 project-euler.079 project-euler.092
    project-euler.097 project-euler.134 project-euler.169 project-euler.173
    project-euler.175 ;
IN: project-euler

<PRIVATE

: problem-prompt ( -- n )
    "Which problem number from Project Euler would you like to solve?"
    print readln string>number ;

: number>euler ( n -- str )
    number>string 3 CHAR: 0 pad-left ;

: solution-path ( n -- str/f )
    number>euler "project-euler." prepend
    vocab where dup [ first ] when ;

PRIVATE>

: problem-solved? ( n -- ? )
    solution-path ;

: run-project-euler ( -- )
    problem-prompt dup problem-solved? [
        dup number>euler "project-euler." prepend run
        "Answer: " swap dup number? [ number>string ] when append print
        "Source: " swap solution-path append print
    ] [
        drop "That problem has not been solved yet..." print
    ] if ;

MAIN: run-project-euler
