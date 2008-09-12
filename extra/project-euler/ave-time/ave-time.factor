! Copyright (c) 2007 Aaron Schaefer.
! See http://factorcode.org/license.txt for BSD license.
USING: continuations io kernel math math.functions math.parser math.statistics
    namespaces tools.time ;
IN: project-euler.ave-time

: collect-benchmarks ( quot n -- seq )
  [
    >r >r datastack r> [ benchmark , ] curry tuck
    [ with-datastack drop ] 2curry r> swap times call
  ] { } make ;

: nth-place ( x n -- y )
    10 swap ^ [ * round ] keep / ;

: ave-time ( quot n -- )
    [ collect-benchmarks ] keep
    swap [ std 2 nth-place ] [ mean round ] bi [
        # " ms ave run time - " % # " SD (" % # " trials)" %
    ] "" make print flush ; inline
