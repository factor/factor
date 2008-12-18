! Copyright (C) 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: splitting grouping classes.tuple classes math kernel
sequences arrays accessors ;
IN: tuple-arrays

TUPLE: tuple-array { seq read-only } { class read-only } ;

: <tuple-array> ( length class -- tuple-array )
    [
        new tuple>array 1 tail
        [ <repetition> concat ] [ length ] bi <sliced-groups>
    ] [ ] bi tuple-array boa ;

M: tuple-array nth
    [ seq>> nth ] [ class>> ] bi prefix >tuple ;

M: tuple-array set-nth ( elt n seq -- )
    [ tuple>array 1 tail ] 2dip seq>> set-nth ;

M: tuple-array new-sequence
    class>> <tuple-array> ;

: >tuple-array ( seq -- tuple-array )
    dup empty? [
        0 over first class <tuple-array> clone-like
    ] unless ;

M: tuple-array like 
    drop dup tuple-array? [ >tuple-array ] unless ;

M: tuple-array length seq>> length ;

INSTANCE: tuple-array sequence
