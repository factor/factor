! Copyright (C) 2004, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra 
classes.algebra.private classes.private kernel words ;
IN: classes.predicate

PREDICATE: predicate-class < class
    "metaclass" word-prop predicate-class eq? ;

<PRIVATE

GENERIC: predicate-quot ( class -- quot )

M: predicate-class predicate-quot
    [ superclass-of predicate-def ]
    [ "predicate-definition" word-prop ] bi
    '[ dup @ _ [ drop f ] if ] ;

PRIVATE>

: define-predicate-class ( class superclass definition -- )
    [ drop f f predicate-class define-class ]
    [ nip "predicate-definition" set-word-prop ]
    [
        2drop
        [ dup predicate-quot define-predicate ]
        [ update-classes ]
        bi
    ] 3tri ;

M: predicate-class reset-class
    [ call-next-method ] [ "predicate-definition" remove-word-prop ] bi ;

M: predicate-class rank-class drop 2 ;

M: predicate-class instance?
    2dup superclass-of instance? [
        "predicate-definition" word-prop call( object -- ? )
    ] [ 2drop f ] if ;

M: predicate-class (flatten-class)
    superclass-of (flatten-class) ;

M: predicate-class (classes-intersect?)
    superclass-of classes-intersect? ;

M: anonymous-predicate predicate-def
    [ class>> ] [ predicate>> ] bi
    '[ dup _ instance? _ [ drop f ] if ] ;

M: anonymous-predicate instance?
    2dup class>> instance?
    [ predicate>> call( object -- ? ) ] [ 2drop f ] if ;

M: anonymous-predicate class-name
    class>> class-name ;
