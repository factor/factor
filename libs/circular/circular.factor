! Copyright (C) 2005, 2006 Alex Chapman, Daniel Ehrenberg
! See http;//factorcode.org/license.txt for BSD license
USING: kernel sequences math generic sequences-internals strings ;
IN: circular

! a circular sequence wraps another sequence, but begins at an arbitrary
! element in the underlying sequence.
TUPLE: circular start ;

C: circular ( seq -- circular )
    0 over set-circular-start [ set-delegate ] keep ;

: +wrap ( x y n -- z )
    >r + r> 2dup >= [ - ] [ drop ] if ; inline

: circular@ ( n circular -- n seq )
    [ [ circular-start ] keep delegate length +wrap ] keep delegate ;

M: circular nth ( n seq -- elt ) bounds-check circular@ nth ;

M: circular nth-unsafe ( n seq -- elt ) circular@ nth-unsafe ;

M: circular set-nth ( elt n seq -- ) bounds-check circular@ set-nth ;

M: circular set-nth-unsafe ( elt n seq -- ) circular@ set-nth-unsafe ;

: change-circular-start ( n circular -- )
    #! change start to (start + n) mod length
    [ circular@ drop ] keep set-circular-start ;

: push-circular ( elt circular -- )
    [ 0 swap set-nth-unsafe ] keep
    1 swap change-circular-start ;

: <circular-string> ( n -- circular )
    0 <string> <circular> ;
