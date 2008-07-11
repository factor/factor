! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors models kernel ;
IN: models.filter

TUPLE: filter < model model quot ;

: <filter> ( model quot -- filter )
    f filter new-model
        swap >>quot
        over >>model
        [ add-dependency ] keep ;

M: filter model-changed
    [ [ value>> ] [ quot>> ] bi* call ] [ nip ] 2bi set-model ;

M: filter model-activated [ model>> ] keep model-changed ;
