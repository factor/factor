! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel assocs combinators classes
generic.standard namespaces arrays math quotations ;
IN: classes.union

PREDICATE: union-class < class
    "metaclass" word-prop union-class eq? ;

! Union classes for dispatch on multiple classes.
: small-union-predicate-quot ( members -- quot )
    dup empty? [
        drop [ drop f ]
    ] [
        unclip first "predicate" word-prop swap
        [ >r "predicate" word-prop [ dup ] prepend r> ]
        assoc-map alist>quot
    ] if ;

: big-union-predicate-quot ( members -- quot )
    [ small-union-predicate-quot ] [ dup ]
    class-hash-dispatch-quot ;

: union-predicate-quot ( members -- quot )
    [ [ drop t ] ] { } map>assoc
    dup length 4 <= [
        small-union-predicate-quot
    ] [
        flatten-methods
        big-union-predicate-quot
    ] if ;

: define-union-predicate ( class -- )
    dup members union-predicate-quot define-predicate ;

M: union-class update-predicate define-union-predicate ;

: define-union-class ( class members -- )
    dupd f union-class define-class define-union-predicate ;

M: union-class reset-class
    { "metaclass" "members" } reset-props ;
