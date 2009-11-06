! Copyright (c) 2007, 2008 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations fry io kernel make math math.functions
math.parser math.statistics memory tools.time ;
IN: project-euler.ave-time

: nth-place ( x n -- y )
    10^ [ * round >integer ] keep /f ;

: collect-benchmarks ( quot n -- seq )
    [
        [ datastack ]
        [
            '[ _ gc benchmark 1000 / , ]
            [ '[ _ _ with-datastack drop ] ] keep swap
        ]
        [ 1 - ] tri* swap times call
    ] { } make ; inline

: ave-time ( quot n -- )
    [ collect-benchmarks ] keep swap
    [ std 2 nth-place ] [ mean round >integer ] bi [
        # " ms ave run time - " % # " SD (" % # " trials)" %
    ] "" make print flush ; inline
