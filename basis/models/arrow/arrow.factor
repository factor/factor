! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors kernel models sequences ;
IN: models.arrow

TUPLE: arrow < model quot ;

: new-arrow ( model quot class -- arrow )
    f swap new-model
    swap >>quot
    [ add-dependency ] keep ;

: <arrow> ( model quot -- arrow )
    arrow new-arrow ;

: compute-arrow-value ( model observer -- value )
    [ value>> ] [ quot>> ] bi* call( old -- new ) ; inline

M: arrow model-changed
    [ compute-arrow-value ] [ set-model ] bi ;

M: arrow model-activated
    [ dependencies>> ] keep [ model-changed ] curry each ;

TUPLE: ?arrow < arrow ;

: <?arrow> ( model quot -- ?arrow )
    ?arrow new-arrow ;

M: ?arrow model-changed
    [ compute-arrow-value ] [ ?set-model ] bi ;
