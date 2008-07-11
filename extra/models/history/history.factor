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
    swap model-value dup [ swap push ] [ 2drop ] if ;

: go-back/forward ( history to from -- )
    dup empty?
    [ 3drop ]
    [ >r dupd (add-history) r> pop swap set-model ] if ;

: go-back ( history -- )
    dup history-forward over history-back go-back/forward ;

: go-forward ( history -- )
    dup history-back over history-forward go-back/forward ;

: add-history ( history -- )
    dup history-forward delete-all
    dup history-back (add-history) ;
