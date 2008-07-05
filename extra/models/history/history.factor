USING: kernel models sequences ;
IN: models.history

TUPLE: history back forward ;

: reset-history ( history -- )
    V{ } clone over set-history-back
    V{ } clone swap set-history-forward ;

: <history> ( value -- history )
    history construct-model dup reset-history ;

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
