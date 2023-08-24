! Copyright (C) 2009 Joe Groff.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes.tuple generalizations kernel
quotations sequences ;
IN: combinators.tuple

<PRIVATE

:: (tuple-slot-quot) ( slot assoc n -- quot )
    slot name>> assoc at [
        slot initial>> :> initial
        { n ndrop initial } >quotation
    ] unless* ;

PRIVATE>

MACRO:: nmake-tuple ( class assoc n -- quot )
    class all-slots [ assoc n (tuple-slot-quot) ] map :> quots
    class <wrapper> :> \class
    { quots n ncleave \class boa } >quotation ;

: 1make-tuple ( x class assoc -- tuple )
    1 nmake-tuple ; inline

: 2make-tuple ( x y class assoc -- tuple )
    2 nmake-tuple ; inline

: 3make-tuple ( x y z class assoc -- tuple )
    3 nmake-tuple ; inline
