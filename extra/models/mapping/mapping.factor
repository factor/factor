USING: models kernel assocs ;
IN: models.mapping

TUPLE: mapping assoc ;

: <mapping> ( models -- mapping )
    f mapping construct-model
    over values over set-model-dependencies
    tuck set-mapping-assoc ;

M: mapping model-changed
    nip
    dup mapping-assoc [ model-value ] assoc-map
    swap delegate set-model ;

M: mapping model-activated dup model-changed ;

M: mapping update-model
    dup model-value swap mapping-assoc
    [ swapd at set-model ] curry assoc-each ;
