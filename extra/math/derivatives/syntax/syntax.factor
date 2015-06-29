! Copyright (C) 2009 Jason W. Merrill.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel parser words effects accessors sequences
    math.ranges ;

IN: math.derivatives.syntax

SYNTAX: DERIVATIVE: scan-object dup stack-effect in>> length [1,b]
    [ drop scan-object ] map
    "derivative" set-word-prop ;
