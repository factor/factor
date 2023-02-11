! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors models kernel assocs ;
IN: models.mapping

TUPLE: mapping < model assoc ;

: <mapping> ( models -- mapping )
    f mapping new-model
        over values >>dependencies
        swap >>assoc ;

M: mapping model-changed
    nip [ assoc>> [ value>> ] assoc-map ] keep set-model ;

M: mapping model-activated
    dup model-changed ;

M: mapping update-model
    [ value>> ] [ assoc>> ] bi
    [ swapd at set-model ] curry assoc-each ;
