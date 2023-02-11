! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs classes classes.algebra
classes.algebra.private classes.builtin classes.private
combinators kernel make sequences splitting words ;
IN: classes.intersection

PREDICATE: intersection-class < class
    "metaclass" word-prop intersection-class eq? ;

<PRIVATE

: intersection-predicate-quot ( participants -- quot )
    [
        [ drop t ]
    ] [
        unclip predicate-def swap [
            predicate-def [ dup ] [ not ] surround
            [ drop f ]
        ] { } map>assoc alist>quot
    ] if-empty ;

: define-intersection-predicate ( class -- )
    dup class-participants intersection-predicate-quot define-predicate ;

M: intersection-class update-class define-intersection-predicate ;

M: intersection-class rank-class drop 5 ;

M: intersection-class instance?
    "participants" word-prop [ instance? ] with all? ;

M: anonymous-intersection instance?
    participants>> [ instance? ] with all? ;

M: intersection-class normalize-class
    class-participants <anonymous-intersection> normalize-class ;

M: intersection-class (flatten-class)
    class-participants <anonymous-intersection> (flatten-class) ;

! Horribly inefficient and inaccurate
: intersect-flattened-classes ( seq1 seq2 -- seq3 )
    ! Only keep those in seq1 that intersect something in seq2.
    [ [ classes-intersect? ] with any? ] curry filter ;

M: anonymous-intersection (flatten-class)
    participants>> [ full-cover ] [
        [ flatten-class ]
        [ intersect-flattened-classes ] map-reduce
        %
    ] if-empty ;

M: anonymous-intersection class-name
    participants>> [ class-name ] map join-words ;

M: anonymous-intersection predicate-def
    participants>> intersection-predicate-quot ;

PRIVATE>

: define-intersection-class ( class participants -- )
    [ [ f f ] dip intersection-class define-class ]
    [ drop update-classes ]
    2bi ;
