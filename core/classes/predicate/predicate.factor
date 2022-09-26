! Copyright (C) 2004, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes classes.algebra classes.algebra.private classes.private
parser sequences hash-sets
combinators combinators.short-circuit kernel sets words ;
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

: include-disjoints ( disjoint-classes class -- )
    "disjoint" [ union HS{ } set-like ] change-word-prop ;

: define-predicate-class ( class superclass definition -- )
    { [ drop f f predicate-class define-class ]
      [ nip "predicate-definition" set-word-prop ]
      [ drop "disjoint" word-prop? [ swap include-disjoints ] [ drop ] if* ]
      [
          2drop
          [ dup predicate-quot define-predicate ]
          [ update-classes ]
          bi
      ] } 3cleave ;

M: predicate-class reset-class
    [ call-next-method ] [ "predicate-definition" remove-word-prop ] bi ;

M: predicate-class rank-class drop 2 ;

M: predicate-class instance?
    2dup superclass-of instance? [
        "predicate-definition" word-prop call( object -- ? )
    ] [ 2drop f ] if ;

M: predicate-class (flatten-class)
    superclass-of (flatten-class) ;

: make-disjoint ( class classes -- )
    [ clone [ delete ] keep ] keepd
    include-disjoints ;

: define-disjoint ( classes -- )
    [ predicate-class check-instance ] map
    reset-caches
    [ dup >hash-set [ make-disjoint ] curry each ]
    [ [ update-classes ] each ] bi ;

! Check if pclass1 is in the "disjoint" declaration of pclass2
: declared-disjoint? ( pclass1 pclass2 -- ? )
    "disjoint" word-prop in? ;

! Return t if at least one of it defines it as disjoint
: check-disjoint-classes ( class1 pclass2 -- can-intersect? )
    over predicate-class?
    [ { [ declared-disjoint? ]
        [ swap declared-disjoint? ] } 2||
    ]
    [ 2drop f ] if ;

M: predicate-class (classes-intersect?)
    {
        [ superclass-of classes-intersect? ]
        [ check-disjoint-classes not ]
    } 2&&
    ;

SYNTAX: DISJOINT: parse-array-def define-disjoint ;
