! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser strings
words vectors ;

! Union metaclass for dispatch on multiple classes.
SYMBOL: union

union [
    [ ] swap "members" word-property [
        builtin-supertypes append
    ] each
] "builtin-supertypes" set-word-property

union [
    ( generic vtable definition class -- )
    "members" word-property [ >r 3dup r> add-method ] each 3drop
] "add-method" set-word-property

union 30 "priority" set-word-property

union [ 2drop t ] "class<" set-word-property

: union-predicate ( definition -- list )
    [
        [
            \ dup ,
            unswons "predicate" word-property append,
            [ drop t ] ,
            union-predicate ,
            \ ifte ,
        ] make-list
    ] [
        [ drop f ]
    ] ifte* ;

: define-union ( class predicate definition -- )
    #! We have to turn the f object into the f word, same for t.
    [
        [
            [
                [[ f POSTPONE: f ]]
                [[ t POSTPONE: t ]]
            ] assoc dup
        ] keep ?
    ] map
    [ union-predicate define-compound ] keep
    dupd "members" set-word-property
    union define-class ;
