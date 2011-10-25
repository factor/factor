! Copyright (c) 2007-2010 Aaron Schaefer, Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: definitions io io.files io.pathnames kernel math math.parser
    prettyprint project-euler.ave-time sequences vocabs vocabs.loader
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
    project-euler.049 project-euler.050 project-euler.051 project-euler.052
    project-euler.053 project-euler.054 project-euler.055 project-euler.056
    project-euler.057 project-euler.058 project-euler.059 project-euler.062
    project-euler.063 project-euler.065 project-euler.067 project-euler.069
    project-euler.070 project-euler.071 project-euler.072 project-euler.073
    project-euler.074 project-euler.075 project-euler.076 project-euler.079
    project-euler.081 project-euler.085 project-euler.089 project-euler.092
    project-euler.097 project-euler.099 project-euler.100 project-euler.102
    project-euler.112 project-euler.116 project-euler.117 project-euler.124
    project-euler.134 project-euler.148 project-euler.150 project-euler.151
    project-euler.164 project-euler.169 project-euler.173 project-euler.175
    project-euler.186 project-euler.188 project-euler.190 project-euler.203
    project-euler.206 project-euler.215 project-euler.255 project-euler.265 ;
IN: project-euler

<PRIVATE

: problem-prompt ( -- n )
    "Which problem number from Project Euler would you like to solve?"
    print readln string>number ;

: number>euler ( n -- str )
    number>string 3 CHAR: 0 pad-head ;

: solution-path ( n -- str/f )
    number>euler "project-euler." prepend
    lookup-vocab where dup [ first <pathname> ] when ;

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
