! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs math math.intervals kernel accessors
sequences namespaces disjoint-sets classes classes.algebra
combinators words
compiler.tree compiler.tree.propagation.info
compiler.tree.copy-equiv ;
IN: compiler.tree.propagation.constraints

! A constraint is a statement about a value.

! Maps constraints to constraints ("A implies B")
SYMBOL: constraints

GENERIC: assume ( constraint -- )
GENERIC: satisfied? ( constraint -- ? )
GENERIC: satisfiable? ( constraint -- ? )

! Boolean constraints
TUPLE: true-constraint value ;

: =t ( value -- constriant ) resolve-copy true-constraint boa ;

M: true-constraint assume
    [ constraints get at [ assume ] when* ]
    [ \ f class-not <class-info> swap value>> refine-value-info ]
    bi ;

M: true-constraint satisfied?
    value>> value-info class>> \ f class-not class<= ;

M: true-constraint satisfiable?
    value>> value-info class>> \ f class-not classes-intersect? ;

TUPLE: false-constraint value ;

: =f ( value -- constriant ) resolve-copy false-constraint boa ;

M: false-constraint assume
    [ constraints get at [ assume ] when* ]
    [ \ f <class-info> swap value>> refine-value-info ]
    bi ;

M: false-constraint satisfied?
    value>> value-info class>> \ f class<= ;

M: false-constraint satisfiable?
    value>> value-info class>> \ f classes-intersect? ;

! Class constraints
TUPLE: class-constraint value class ;

: is-instance-of ( value class -- constraint )
    [ resolve-copy ] dip class-constraint boa ;

M: class-constraint assume
    [ class>> <class-info> ] [ value>> ] bi refine-value-info ;

! Interval constraints
TUPLE: interval-constraint value interval ;

: is-in-interval ( value interval -- constraint )
    [ resolve-copy ] dip interval-constraint boa ;

M: interval-constraint assume
    [ interval>> <interval-info> ] [ value>> ] bi refine-value-info ;

! Literal constraints
TUPLE: literal-constraint value literal ;

: is-equal-to ( value literal -- constraint )
    [ resolve-copy ] dip literal-constraint boa ;

M: literal-constraint assume
    [ literal>> <literal-info> ] [ value>> ] bi refine-value-info ;

! Implication constraints
TUPLE: implication p q ;

C: --> implication

M: implication assume
    [ q>> ] [ p>> ] bi
    [ constraints get set-at ]
    [ satisfied? [ assume ] [ drop ] if ] 2bi ;

M: implication satisfiable?
    [ q>> satisfiable? ] [ p>> satisfiable? not ] bi or ;

! Conjunction constraints
TUPLE: conjunction p q ;

C: /\ conjunction

M: conjunction assume [ p>> assume ] [ q>> assume ] bi ;

M: conjunction satisfiable?
    [ p>> satisfiable? ] [ q>> satisfiable? ] bi and ;

! Disjunction constraints
TUPLE: disjunction p q ;

C: \/ disjunction

M: disjunction assume
    {
        { [ dup p>> satisfiable? not ] [ q>> assume ] }
        { [ dup q>> satisfiable? not ] [ p>> assume ] }
        [ drop ]
    } cond ;

M: disjunction satisfiable?
    [ p>> satisfiable? ] [ q>> satisfiable? ] bi or ;

! No-op
M: f assume drop ;

! Utilities
: t--> ( constraint boolean-value -- constraint' ) =t swap --> ;

: f--> ( constraint boolean-value -- constraint' ) =f swap --> ;

: <conditional> ( true-constr false-constr boolean-value -- constraint )
    tuck [ t--> ] [ f--> ] 2bi* /\ ;
