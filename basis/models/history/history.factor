! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel models sequences ;
IN: models.history

TUPLE: history < model back forward ;

: reset-history ( history -- history )
    V{ } clone >>back
    V{ } clone >>forward ; inline

: <history> ( value -- history )
    history new-model
        reset-history ;

: (add-history) ( history to -- )
    swap value>> dup [ swap push ] [ 2drop ] if ;

: go-back/forward ( history to from -- )
    [ 2drop ]
    [ [ dupd (add-history) ] dip pop swap set-model ] if-empty ;

: go-back ( history -- )
    dup [ forward>> ] [ back>> ] bi go-back/forward ;

: go-forward ( history -- )
    dup [ back>> ] [ forward>> ] bi go-back/forward ;

: add-history ( history -- )
    dup forward>> delete-all
    dup back>> (add-history) ;
