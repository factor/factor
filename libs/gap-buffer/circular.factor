USING: kernel sequences math generic sequences-internals ;
IN: circular

! a circular sequence wraps another sequence, but begins at an arbitrary
! element in the underlying sequence.
TUPLE: circular start ;

C: circular ( seq -- circular )
    0 over set-circular-start [ set-delegate ] keep ;

: circular@ ( n circular -- n seq )
    [ tuck circular-start + swap length mod ] keep delegate ;

M: circular nth ( n seq -- elt ) bounds-check circular@ nth ;

M: circular nth-unsafe ( n seq -- elt ) circular@ nth-unsafe ;

M: circular set-nth ( elt n seq -- ) bounds-check circular@ set-nth ;

M: circular set-nth-unsafe ( elt n seq -- ) circular@ set-nth-unsafe ;

: change-circular-start ( n circular -- )
    #! change start to (start + n) mod length
    [ circular@ drop ] keep set-circular-start ;

