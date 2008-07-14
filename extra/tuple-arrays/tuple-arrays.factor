! Copyright (C) 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: splitting grouping classes.tuple classes math kernel
sequences arrays accessors ;
IN: tuple-arrays

TUPLE: tuple-array seq class ;

: <tuple-array> ( length example -- tuple-array )
    [ tuple>array length 1- [ * { } new-sequence ] keep <sliced-groups> ]
    [ class ] bi tuple-array boa ;

M: tuple-array nth
    [ seq>> nth ] [ class>> ] bi prefix >tuple ;

: deconstruct ( tuple -- seq )
    tuple>array 1 tail ;

M: tuple-array set-nth ( elt n seq -- )
    >r >r deconstruct r> r> seq>> set-nth ;

M: tuple-array new-sequence
    class>> new <tuple-array> ;

: >tuple-array ( seq -- tuple-array/seq )
    dup empty? [
        0 over first <tuple-array> clone-like
    ] unless ;

M: tuple-array like 
    drop dup tuple-array? [ >tuple-array ] unless ;

M: tuple-array length seq>> length ;

INSTANCE: tuple-array sequence
