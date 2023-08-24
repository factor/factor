! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
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
    swap value>> [ swap push ] [ drop ] if* ;

:: go-back/forward ( history to from -- )
    from empty? [
        history to (add-history)
        from pop history set-model
    ] unless ;

: go-back ( history -- )
    dup [ forward>> ] [ back>> ] bi go-back/forward ;

: go-forward ( history -- )
    dup [ back>> ] [ forward>> ] bi go-back/forward ;

: add-history ( history -- )
    dup forward>> delete-all
    dup back>> (add-history) ;
