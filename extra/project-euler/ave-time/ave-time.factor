! Copyright (c) 2007 Aaron Schaefer
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators io kernel math math.functions math.parser
    math.statistics namespaces sequences tools.time ;
IN: project-euler.ave-time

: collect-benchmarks ( quot n -- seq )
  [
    >r >r datastack r> [ benchmark , ] curry tuck
    [ with-datastack drop ] 2curry r> swap times call
  ] { } make ;

: ave-time ( quot n -- )
    [ collect-benchmarks ] keep swap mean round [
        # " ms run time - " % # " trials" %
    ] "" make print flush ; inline
