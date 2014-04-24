! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.result-sets kernel orm.binders
sqlite.db2.types ;
IN: sqlite.orm.types

M: column-binder-in sqlite-bind
    [ value>> ] [ column>> type>> ] bi bind-next-sqlite-type ;

M: column-binder-out get-type
    column>> type>> ;
