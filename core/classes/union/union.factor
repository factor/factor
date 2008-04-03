! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel assocs combinators classes
namespaces arrays math quotations ;
IN: classes.union

PREDICATE: union-class < class
    "metaclass" word-prop union-class eq? ;

! Union classes for dispatch on multiple classes.
: union-predicate-quot ( members -- quot )
    dup empty? [
        drop [ drop f ]
    ] [
        unclip "predicate" word-prop swap [
            "predicate" word-prop [ dup ] prepend
            [ drop t ]
        ] { } map>assoc alist>quot
    ] if ;

: define-union-predicate ( class -- )
    dup members union-predicate-quot define-predicate ;

M: union-class update-class define-union-predicate ;

: define-union-class ( class members -- )
    [ f swap union-class define-class ]
    [ drop update-classes ]
    2bi ;

M: union-class reset-class
    { "class" "metaclass" "members" } reset-props ;
