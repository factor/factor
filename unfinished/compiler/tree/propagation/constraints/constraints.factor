! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs math math.intervals kernel accessors
sequences namespaces disjoint-sets classes classes.algebra
combinators words compiler.tree compiler.tree.propagation.info ;
IN: compiler.tree.propagation.constraints

! A constraint is a statement about a value.

! Maps constraints to constraints ("A implies B")
SYMBOL: constraints

GENERIC: assume ( constraint -- )
GENERIC: satisfied? ( constraint -- ? )

! Boolean constraints
TUPLE: true-constraint value ;

: <true-constraint> ( value -- constriant )
    resolve-copy true-constraint boa ;

M: true-constraint assume
    [ constraints get at [ assume ] when* ]
    [ \ f class-not <class-info> swap value>> refine-value-info ]
    bi ;

M: true-constraint satisfied?
    value>> value-info class>> \ f class-not class<= ;

TUPLE: false-constraint value ;

: <false-constraint> ( value -- constriant )
    resolve-copy false-constraint boa ;

M: false-constraint assume
    [ constraints get at [ assume ] when* ]
    [ \ f <class-info> swap value>> refine-value-info ]
    bi ;

M: false-constraint satisfied?
    value>> value-info class>> \ f class<= ;

! Class constraints
TUPLE: class-constraint value class ;

: <class-constraint> ( value class -- constraint )
    [ resolve-copy ] dip class-constraint boa ;

M: class-constraint assume
    [ class>> <class-info> ] [ value>> ] bi refine-value-info ;

! Interval constraints
TUPLE: interval-constraint value interval ;

: <interval-constraint> ( value interval -- constraint )
    [ resolve-copy ] dip interval-constraint boa ;

M: interval-constraint assume
    [ interval>> <interval-info> ] [ value>> ] bi refine-value-info ;

! Literal constraints
TUPLE: literal-constraint value literal ;

: <literal-constraint> ( value literal -- constraint )
    [ resolve-copy ] dip literal-constraint boa ;

M: literal-constraint assume
    [ literal>> <literal-info> ] [ value>> ] bi refine-value-info ;

! Implication constraints
TUPLE: implication p q ;

C: <implication> implication

M: implication assume
    [ q>> ] [ p>> ] bi
    [ constraints get set-at ]
    [ satisfied? [ assume ] [ drop ] if ] 2bi ;

! Conjunction constraints
TUPLE: conjunction p q ;

C: <conjunction> conjunction

M: conjunction assume [ p>> assume ] [ q>> assume ] bi ;

! No-op
M: f assume drop ;

! Utilities
: if-true ( constraint boolean-value -- constraint' )
   <true-constraint> swap <implication> ;

: if-false ( constraint boolean-value -- constraint' )
    <false-constraint> swap <implication> ;

: <conditional> ( true-constr false-constr boolean-value -- constraint )
    tuck [ if-true ] [ if-false ] 2bi* <conjunction> ;
