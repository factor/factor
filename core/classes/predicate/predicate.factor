! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra classes.algebra.private classes.private
continuations kernel words ;
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

ERROR: compile-time-predicate-uses-undefined-words class ;
: try-instance? ( object class -- ? )
    [ instance? ]
    [ dup undefined-word? [ compile-time-predicate-uses-undefined-words ] [ rethrow ] if ]
    recover ;

M: predicate-class (classes-intersect?)
    2dup superclass-of classes-intersect?
    [ over wrapper?
      [ [ wrapped>> ] dip try-instance? ]
      [ 2drop t ] if ]
    [ 2drop f ] if
    ;
