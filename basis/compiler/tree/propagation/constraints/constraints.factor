! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs math math.intervals kernel accessors
sequences namespaces classes classes.algebra
combinators words
compiler.tree
compiler.tree.propagation.info
compiler.tree.propagation.copy ;
IN: compiler.tree.propagation.constraints

! A constraint is a statement about a value.

! Maps constraints to constraints ("A implies B")
SYMBOL: constraints

GENERIC: assume* ( constraint -- )
GENERIC: satisfied? ( constraint -- ? )

M: f assume* drop ;

! satisfied? is inaccurate. It's just used to prevent infinite
! loops so its only implemented for true-constraints and
! false-constraints.
M: object satisfied? drop f ;

: assume ( constraint -- ) dup satisfied? [ drop ] [ assume* ] if ;

! Boolean constraints
TUPLE: true-constraint value ;

: =t ( value -- constriant ) resolve-copy true-constraint boa ;

M: true-constraint assume*
    [ \ f class-not <class-info> swap value>> refine-value-info ]
    [ constraints get assoc-stack [ assume ] when* ]
    bi ;

M: true-constraint satisfied?
    value>> value-info class>> true-class? ;

TUPLE: false-constraint value ;

: =f ( value -- constriant ) resolve-copy false-constraint boa ;

M: false-constraint assume*
    [ \ f <class-info> swap value>> refine-value-info ]
    [ constraints get assoc-stack [ assume ] when* ]
    bi ;

M: false-constraint satisfied?
    value>> value-info class>> false-class? ;

! Class constraints
TUPLE: class-constraint value class ;

: is-instance-of ( value class -- constraint )
    [ resolve-copy ] dip class-constraint boa ;

M: class-constraint assume*
    [ class>> <class-info> ] [ value>> ] bi refine-value-info ;

! Interval constraints
TUPLE: interval-constraint value interval ;

: is-in-interval ( value interval -- constraint )
    [ resolve-copy ] dip interval-constraint boa ;

M: interval-constraint assume*
    [ interval>> <interval-info> ] [ value>> ] bi refine-value-info ;

! Literal constraints
TUPLE: literal-constraint value literal ;

: is-equal-to ( value literal -- constraint )
    [ resolve-copy ] dip literal-constraint boa ;

M: literal-constraint assume*
    [ literal>> <literal-info> ] [ value>> ] bi refine-value-info ;

! Implication constraints
TUPLE: implication p q ;

C: --> implication

: assume-implication ( p q -- )
    [ constraints get [ assoc-stack swap suffix ] 2keep last set-at ]
    [ satisfied? [ assume ] [ drop ] if ] 2bi ;

M: implication assume*
    [ q>> ] [ p>> ] bi assume-implication ;

! Equivalence constraints
TUPLE: equivalence p q ;

C: <--> equivalence

M: equivalence assume*
    [ p>> ] [ q>> ] bi
    [ assume-implication ]
    [ swap assume-implication ] 2bi ;

! Conjunction constraints -- sequences act as conjunctions
M: sequence assume* [ assume ] each ;

: /\ ( p q -- constraint ) 2array ;

! Utilities
: t--> ( constraint boolean-value -- constraint' ) =t swap --> ;

: f--> ( constraint boolean-value -- constraint' ) =f swap --> ;
