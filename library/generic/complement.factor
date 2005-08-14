! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

IN: generic
USING: errors hashtables kernel lists math parser strings
sequences vectors words ;

! Complement metaclass, contains all objects not in a certain class.
SYMBOL: complement

complement [
    "complement" word-prop builtin-supertypes
    num-types >list
    seq-diff
] "builtin-supertypes" set-word-prop

complement [
    ( generic vtable definition class -- )
    drop num-types [
        >r 3dup r> builtin-type
        dup [ add-method ] [ 2drop 2drop ] ifte
    ] each 3drop
] "add-method" set-word-prop

complement [ (class<) ] "class<" set-word-prop

: complement-predicate ( complement -- list )
    "predicate" word-prop [ not ] append ;

: define-complement ( class complement -- )
    2dup "complement" set-word-prop
    dupd complement-predicate "predicate" set-word-prop
    complement define-class ;

PREDICATE: word complement metaclass complement = ;
