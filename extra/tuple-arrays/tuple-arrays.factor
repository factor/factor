! Copyright (C) 2007 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: splitting tuples classes math kernel sequences arrays ;
IN: tuple-arrays

TUPLE: tuple-array example ;

: prepare-example ( tuple -- seq n )
    dup class over delegate [ 1array ] [ f 2array ] if
    swap tuple>array length over length - ;

: <tuple-array> ( length example -- tuple-array )
    prepare-example [ rot * { } new ] keep
    <sliced-groups> tuple-array construct-delegate
    [ set-tuple-array-example ] keep ;

: reconstruct ( seq example -- tuple )
    swap append >tuple ;

M: tuple-array nth
    [ delegate nth ] keep
    tuple-array-example reconstruct ;

: deconstruct ( tuple example -- seq )
    >r tuple>array r> length tail-slice ;

M: tuple-array set-nth ( elt n seq -- )
    tuck >r >r tuple-array-example deconstruct r> r>
    delegate set-nth ;

M: tuple-array new tuple-array-example >tuple <tuple-array> ;

: >tuple-array ( seq -- tuple-array/seq )
    dup empty? [
        0 over first <tuple-array> clone-like
    ] unless ;

M: tuple-array like 
    drop dup tuple-array? [ >tuple-array ] unless ;

INSTANCE: tuple-array sequence
