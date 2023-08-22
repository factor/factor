! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs classes.algebra
compiler.tree.propagation.copy compiler.tree.propagation.info
kernel namespaces sequences ;
IN: compiler.tree.propagation.constraints

SYMBOL: constraints

GENERIC: assume* ( constraint -- )
GENERIC: satisfied? ( constraint -- ? )

M: f assume* drop ;

M: object satisfied? drop f ;

: assume ( constraint -- ) dup satisfied? [ drop ] [ assume* ] if ;

TUPLE: true-constraint value ;

: =t ( value -- constraint ) resolve-copy true-constraint boa ;

: follow-implications ( constraint -- )
    constraints get assoc-stack [ assume ] when* ;

M: true-constraint assume*
    [ \ f class-not <class-info> swap value>> refine-value-info ]
    [ follow-implications ]
    bi ;

M: true-constraint satisfied?
    value>> value-info*
    [ class>> true-class? ] [ drop f ] if ;

TUPLE: false-constraint value ;

: =f ( value -- constraint ) resolve-copy false-constraint boa ;

M: false-constraint assume*
    [ \ f <class-info> swap value>> refine-value-info ]
    [ follow-implications ]
    bi ;

M: false-constraint satisfied?
    value>> value-info*
    [ class>> false-class? ] [ drop f ] if ;

TUPLE: class-constraint value class ;

: is-instance-of ( value class -- constraint )
    [ resolve-copy ] dip class-constraint boa ;

M: class-constraint assume*
    [ class>> <class-info> ] [ value>> ] bi refine-value-info ;

TUPLE: interval-constraint value interval ;

: is-in-interval ( value interval -- constraint )
    [ resolve-copy ] dip interval-constraint boa ;

M: interval-constraint assume*
    [ interval>> <interval-info> ] [ value>> ] bi refine-value-info ;

TUPLE: literal-constraint value literal ;

: is-equal-to ( value literal -- constraint )
    [ resolve-copy ] dip literal-constraint boa ;

M: literal-constraint assume*
    [ literal>> <literal-info> ] [ value>> ] bi refine-value-info ;

TUPLE: implication p q ;

C: --> implication

: maybe-add ( elt seq -- seq' )
    2dup member? [ nip ] [ swap suffix ] if ;

: assume-implication ( q p -- )
    [ constraints get [ assoc-stack maybe-add ] 2keep last set-at ]
    [ satisfied? [ assume ] [ drop ] if ] 2bi ;

M: implication assume*
    [ q>> ] [ p>> ] bi assume-implication ;

TUPLE: equivalence p q ;

C: <--> equivalence

M: equivalence assume*
    [ p>> ] [ q>> ] bi
    [ assume-implication ]
    [ swap assume-implication ] 2bi ;

! Conjunction constraints -- sequences act as conjunctions
M: sequence assume* [ assume ] each ;

: t--> ( constraint boolean-value -- constraint' ) =t swap --> ;

: f--> ( constraint boolean-value -- constraint' ) =f swap --> ;
