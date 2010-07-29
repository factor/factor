! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel assocs combinators classes
classes.private classes.algebra classes.algebra.private
namespaces arrays math quotations definitions ;
IN: classes.union

PREDICATE: union-class < class
    "metaclass" word-prop union-class eq? ;

<PRIVATE

: union-predicate-quot ( members -- quot )
    [
        [ drop f ]
    ] [
        unclip "predicate" word-prop swap [
            "predicate" word-prop [ dup ] prepend
            [ drop t ]
        ] { } map>assoc alist>quot
    ] if-empty ;

: define-union-predicate ( class -- )
    dup members union-predicate-quot define-predicate ;

M: union-class update-class define-union-predicate ;

: (define-union-class) ( class members -- )
    f swap f union-class make-class-props (define-class) ;

PRIVATE>

: define-union-class ( class members -- )
    [ (define-union-class) ]
    [ drop changed-conditionally ]
    [ drop update-classes ]
    2tri ;

M: union-class rank-class drop 7 ;

M: union-class instance?
    "members" word-prop [ instance? ] with any? ;

M: union-class normalize-class
    members <anonymous-union> normalize-class ;

M: union-class (flatten-class)
    members <anonymous-union> (flatten-class) ;
