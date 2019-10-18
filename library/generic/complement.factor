! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

IN: generic
USING: errors hashtables kernel lists math parser strings
vectors words ;

! Complement metaclass, contains all objects not in a certain class.
SYMBOL: complement

complement [
    "complement" word-prop builtin-supertypes
    num-types count
    difference
] "builtin-supertypes" set-word-prop

complement [
    ( generic vtable definition class -- )
    drop num-types [
        [
            >r 3dup r> builtin-type
            dup [ add-method ] [ 2drop 2drop ] ifte
        ] keep
    ] repeat 3drop
] "add-method" set-word-prop

complement 90 "priority" set-word-prop

complement [
    swap "complement" word-prop
    swap "complement" word-prop
    class< not
] "class<" set-word-prop

: complement-predicate ( complement -- list )
    "predicate" word-prop [ not ] append ;

: define-complement ( class complement -- )
    2dup "complement" set-word-prop
    dupd complement-predicate "predicate" set-word-prop
    complement define-class ;
