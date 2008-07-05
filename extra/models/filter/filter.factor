USING: models kernel ;
IN: models.filter

TUPLE: filter model quot ;

: <filter> ( model quot -- filter )
    f filter construct-model
    [ set-filter-quot ] keep
    [ set-filter-model ] 2keep
    [ add-dependency ] keep ;

M: filter model-changed
    swap model-value over filter-quot call
    swap set-model ;

M: filter model-activated dup filter-model swap model-changed ;
