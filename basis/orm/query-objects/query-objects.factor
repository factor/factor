! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors db2.query-objects kernel orm.binders sequences
orm.persistent ;
IN: orm.query-objects

: column-binder>qualified-column-name ( column-binder -- string )
    column>>
    [ persistent>> table-name>> ] [ column-name>> ] bi "." glue ;

M: column-binder-out >qualified-column-name
    column-binder>qualified-column-name ;

M: column-binder-in >qualified-column-name
    column-binder>qualified-column-name ;

M: persistent >table-as table-name>> ;


M: column-binder-in binder-operator
    drop " = " ;

M: column-binder-in flatten-binder ;
