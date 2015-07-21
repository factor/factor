! Copyright (C) 2009 Jason W. Merrill.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors effects kernel lexer math.ranges parser
sequences words ;
IN: math.derivatives.syntax

SYNTAX: DERIVATIVE: scan-object dup stack-effect in>> length [1,b]
    [ drop scan-object ] map ";" expect
    "derivative" set-word-prop ;
