! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser strings
words vectors ;

! Union metaclass for dispatch on multiple classes.
SYMBOL: union

union [
    [ ] swap "members" word-prop [
        builtin-supertypes append
    ] each
] "builtin-supertypes" set-word-prop

union [
    ( generic vtable definition class -- )
    "members" word-prop [ >r 3dup r> add-method ] each 3drop
] "add-method" set-word-prop

union 30 "priority" set-word-prop

union [ 2drop t ] "class<" set-word-prop

: union-predicate ( definition -- list )
    [
        [
            \ dup ,
            unswons "predicate" word-prop append,
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
    dupd "members" set-word-prop
    union define-class ;

PREDICATE: word union metaclass union = ;
