! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations fry io kernel make math math.functions math.parser
    math.statistics memory tools.time ;
IN: project-euler.ave-time

: collect-benchmarks ( quot n -- seq )
    [
        [ datastack ]
        [ '[ _ gc benchmark , ] tuck '[ _ _ with-datastack drop ] ]
        [ 1- ] tri* swap times call
    ] { } make ;

: nth-place ( x n -- y )
    10 swap ^ [ * round ] keep / ;

: ave-time ( quot n -- )
    [ collect-benchmarks ] keep swap
    [ std 2 nth-place ] [ mean round ] bi [
        # " ms ave run time - " % # " SD (" % # " trials)" %
    ] "" make print flush ; inline
