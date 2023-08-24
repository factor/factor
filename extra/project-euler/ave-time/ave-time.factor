! Copyright (c) 2007, 2008 Aaron Schaefer.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators.smart formatting io kernel math math.functions
math.statistics memory sequences tools.time ;
IN: project-euler.ave-time

MACRO: collect-benchmarks ( quot n -- seq )
    swap '[ _ [ [ [ _ nullary ] preserving ] gc benchmark 6 10^ / ] replicate ] ;

: ave-time ( quot n -- )
    [
        collect-benchmarks
        [ mean round >integer ]
        [ std ] bi
    ] keep
    "%d ms ave run time - %.2f SD (%d trials)\n" printf flush ; inline
