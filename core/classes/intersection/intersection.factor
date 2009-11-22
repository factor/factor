! Copyright (C) 2004, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: words accessors sequences kernel assocs combinators classes
classes.algebra classes.algebra.private classes.builtin
namespaces arrays math quotations ;
IN: classes.intersection

PREDICATE: intersection-class < class
    "metaclass" word-prop intersection-class eq? ;

: intersection-predicate-quot ( members -- quot )
    [
        [ drop t ]
    ] [
        unclip "predicate" word-prop swap [
            "predicate" word-prop [ dup ] [ not ] surround
            [ drop f ]
        ] { } map>assoc alist>quot
    ] if-empty ;

: define-intersection-predicate ( class -- )
    dup participants intersection-predicate-quot define-predicate ;

M: intersection-class update-class define-intersection-predicate ;

: define-intersection-class ( class participants -- )
    [ [ f f ] dip intersection-class define-class ]
    [ drop update-classes ]
    2bi ;

M: intersection-class rank-class drop 2 ;

M: intersection-class instance?
    "participants" word-prop [ instance? ] with all? ;

M: intersection-class (flatten-class)
    participants <anonymous-intersection> (flatten-class) ;

! Horribly inefficient and inaccurate
: intersect-flattened-classes ( seq1 seq2 -- seq3 )
    ! Only keep those in seq1 that intersect something in seq2.
    [ [ classes-intersect? ] with any? ] curry filter ;

M: anonymous-intersection (flatten-class)
    participants>> [ full-cover ] [
        [ flatten-class keys ]
        [ intersect-flattened-classes ] map-reduce
        [ dup set ] each
    ] if-empty ;
