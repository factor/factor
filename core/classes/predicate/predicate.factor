! Copyright (C) 2004, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.algebra classes.algebra.private kernel
namespaces make words sequences quotations arrays kernel.private
assocs combinators ;
IN: classes.predicate

PREDICATE: predicate-class < class
    "metaclass" word-prop predicate-class eq? ;

GENERIC: predicate-quot ( class -- quot )

M: predicate-class predicate-quot
    [
        \ dup ,
        [ superclass "predicate" word-prop % ]
        [ "predicate-definition" word-prop , ] bi
        [ drop f ] , \ if ,
    ] [ ] make ;

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
    [ call-next-method ] [ { "predicate-definition" } reset-props ] bi ;

M: predicate-class rank-class drop 1 ;

M: predicate-class instance?
    2dup superclass instance? [
        "predicate-definition" word-prop call( object -- ? )
    ] [ 2drop f ] if ;

M: predicate-class (flatten-class)
    superclass (flatten-class) ;

M: predicate-class (classes-intersect?)
    superclass classes-intersect? ;
