! Copyright (C) 2008, 2009 Doug Coleman, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.algebra classes.algebra.private
classes.predicate kernel sequences words ;
IN: classes.singleton

: singleton-predicate-quot ( class -- quot ) [ eq? ] curry ;

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