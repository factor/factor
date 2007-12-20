! Copyright (c) 2007 Aaron Schaefer
! See http://factorcode.org/license.txt for BSD license.
USING: arrays effects inference io kernel math math.functions math.parser
    math.statistics namespaces sequences tools.time ;
IN: project-euler.ave-time

<PRIVATE

: clean-stack ( quot -- )
    infer dup effect-out swap effect-in - [ drop ] times ;

: ave-benchmarks ( seq -- pair )
    flip [ mean round ] map ;

PRIVATE>

: collect-benchmarks ( quot n -- seq )
    [
        1- [ [ benchmark ] keep -rot 2array , [ clean-stack ] keep ] times
    ] curry { } make >r benchmark 2array r> swap add ; inline

: ave-time ( quot n -- )
    [ collect-benchmarks ] keep swap ave-benchmarks [
        dup second # " ms run / " % first # " ms GC ave time - " % # " trials" %
    ] "" make print flush ; inline
