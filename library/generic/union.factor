! Copyright (C) 2004, 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: generic
USING: errors hashtables kernel lists namespaces parser
sequences strings words vectors ;

! Union metaclass for dispatch on multiple classes.
SYMBOL: union

union [
    ( generic vtable definition class -- )
    "members" word-prop [ >r 3dup r> add-method ] each 3drop
] "add-method" set-word-prop

: union-predicate ( members -- list )
    [
        [
            \ dup ,
            unswons "predicate" word-prop %
            [ drop t ] ,
            union-predicate ,
            \ ifte ,
        ] make-list
    ] [
        [ drop f ]
    ] ifte* ;

: set-members ( class members -- )
    2dup [ types ] map concat "types" set-word-prop
    "members" set-word-prop ;

: define-union ( class predicate members -- )
    #! We have to turn the f object into the f word, same for t.
    3dup nip set-members pick union define-class
    union-predicate define-predicate ;

PREDICATE: word union metaclass union = ;
