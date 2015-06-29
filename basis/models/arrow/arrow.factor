! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models sequences ;
IN: models.arrow

TUPLE: arrow < model quot ;

: <arrow> ( model quot -- arrow )
    f arrow new-model
        swap >>quot
    [ add-dependency ] keep ;

M: arrow model-changed
    [ [ value>> ] [ quot>> ] bi* call( old -- new ) ]
    [ set-model ] bi ;

M: arrow model-activated
    [ dependencies>> ] keep [ model-changed ] curry each ;
