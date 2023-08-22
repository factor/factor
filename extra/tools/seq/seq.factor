! Copyright (C) 2011 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: combinators command-line io kernel math.order math.parser
ranges namespaces sequences ;

IN: tools.seq

: usage ( -- )
    "Usage: seq [first [incr]] last" print ;

: seq ( a step b -- )
    swap <range> [ number>string print ] each ;

: run-seq ( -- )
    command-line get dup length {
        { 1 [ first string>number [ 1 1 ] dip seq ] }
        { 2 [ first2 [ string>number ] bi@ 2dup before? 1 -1 ? swap seq ] }
        { 3 [ first3 [ string>number ] tri@ seq ] }
        [ 2drop usage ]
    } case ;

MAIN: run-seq
