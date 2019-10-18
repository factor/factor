! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel assocs combinators classes
generic.standard namespaces arrays ;
IN: classes.union

PREDICATE: class union-class
    "metaclass" word-prop union-class eq? ;

! Union classes for dispatch on multiple classes.
: union-predicate-quot ( members -- quot )
    0 (dispatch#) [
        [ [ drop t ] ] { } map>assoc
        object bootstrap-word [ drop f ] 2array add*
        single-combination
    ] with-variable ;

: define-union-predicate ( class -- )
    dup predicate-word
    over members union-predicate-quot
    define-predicate ;

: define-union-class ( class members -- )
    dupd f union-class define-class define-union-predicate ;

M: union-class reset-class
    { "metaclass" "members" } reset-props ;
