! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.algebra classes.predicate kernel
sequences words ;
IN: classes.singleton

PREDICATE: singleton-class < predicate-class
    [ "predicate-definition" word-prop ]
    [ [ eq? ] curry ] bi sequence= ;

: define-singleton-class ( word -- )
    \ word over [ eq? ] curry define-predicate-class ;

M: singleton-class instance? eq? ;

M: singleton-class (classes-intersect?)
    over singleton-class? [ eq? ] [ call-next-method ] if ;
