! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.

IN: generic
USING: errors hashtables kernel lists math parser strings
vectors words ;

! Complement metaclass, contains all objects not in a certain class.
SYMBOL: complement

complement [
    "complement" word-property builtin-supertypes
    num-types count
    difference
] "builtin-supertypes" set-word-property

complement [
    ( generic vtable definition class -- )
    drop num-types [
        [
            >r 3dup r> builtin-type
            dup [ add-method ] [ 2drop 2drop ] ifte
        ] keep
    ] repeat 3drop
] "add-method" set-word-property

complement 90 "priority" set-word-property

complement [
    swap "complement" word-property
    swap "complement" word-property
    class< not
] "class<" set-word-property

: complement-predicate ( complement -- list )
    "predicate" word-property [ not ] append ;

: define-complement ( class predicate complement -- )
    [ complement-predicate define-compound ] keep
    dupd "complement" set-word-property
    complement define-class ;
