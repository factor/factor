! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words sequences kernel assocs combinators classes
namespaces arrays math quotations ;
IN: classes.intersection

PREDICATE: intersection-class < class
    "metaclass" word-prop intersection-class eq? ;

: intersection-predicate-quot ( members -- quot )
    dup empty? [
        drop [ drop t ]
    ] [
        unclip "predicate" word-prop swap [
            "predicate" word-prop [ dup ] swap [ not ] 3append
            [ drop f ]
        ] { } map>assoc alist>quot
    ] if ;

: define-intersection-predicate ( class -- )
    dup participants intersection-predicate-quot define-predicate ;

M: intersection-class update-class define-intersection-predicate ;

: define-intersection-class ( class participants -- )
    [ f f rot intersection-class define-class ]
    [ drop update-classes ]
    2bi ;

M: intersection-class reset-class
    { "class" "metaclass" "participants" } reset-props ;

M: intersection-class rank-class drop 2 ;
