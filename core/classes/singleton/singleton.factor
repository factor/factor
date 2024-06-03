! Copyright (C) 2008, 2010 Doug Coleman, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: classes classes.algebra.private classes.predicate
classes.predicate.private kernel sequences slots words ;
IN: classes.singleton

<PRIVATE

: singleton-predicate-quot ( class -- quot ) [ eq? ] curry ;

PRIVATE>

PREDICATE: singleton-class < predicate-class
    [ "predicate-definition" word-prop ]
    [ singleton-predicate-quot ]
    bi sequence= ;

: define-singleton-class ( word -- )
    \ word over singleton-predicate-quot define-predicate-class ;

M: singleton-class instance? eq? ;

M: singleton-class (classes-intersect?)
    over singleton-class? [ eq? ] [ call-next-method ] if ;

M: singleton-class predicate-quot
    singleton-predicate-quot ;

M: singleton-class initial-value* t ;
