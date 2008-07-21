! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays assocs math math.intervals kernel accessors
sequences namespaces disjoint-sets classes classes.algebra
combinators words compiler.tree ;
IN: compiler.tree.propagation.constraints

! A constraint is a statement about a value.

! We need a notion of equality which doesn't recurse so cannot
! infinite loop on circular data
GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: number eql? number= ;

! Maps constraints to constraints
SYMBOL: constraints

TUPLE: literal-constraint literal value ;

C: <literal-constraint> literal-constraint

M: literal-constraint equal?
    over literal-constraint? [
        [ [ literal>> ] bi@ eql? ]
        [ [ value>>   ] bi@ =    ]
        2bi and
    ] [ 2drop f ] if ;

TUPLE: class-constraint class value ;

C: <class-constraint> class-constraint

TUPLE: interval-constraint interval value ;

C: <interval-constraint> interval-constraint

GENERIC: apply-constraint ( constraint -- )
GENERIC: constraint-satisfied? ( constraint -- ? )

: `input ( n -- value ) node get in-d>> nth ;
: `output ( n -- value ) node get out-d>> nth ;
: class, ( class value -- ) <class-constraint> , ;
: literal, ( literal value -- ) <literal-constraint> , ;
: interval, ( interval value -- ) <interval-constraint> , ;

M: f apply-constraint drop ;

: make-constraints ( node quot -- constraint )
    [ swap node set call ] { } make ; inline

: set-constraints ( node quot -- )
    make-constraints
    unclip [ 2array ] reduce
    apply-constraint ; inline

: assume ( constraint -- )
    constraints get at [ apply-constraint ] when* ;

! Disjoint set of copy equivalence
SYMBOL: copies

: is-copy-of ( val copy -- ) copies get equate ;

: are-copies-of ( vals copies -- ) [ is-copy-of ] 2each ;

: resolve-copy ( copy -- val ) copies get representative ;

: introduce-value ( val -- ) copies get add-atom ;

! Current value --> literal mapping
SYMBOL: value-literals

! Current value --> interval mapping
SYMBOL: value-intervals

! Current value --> class mapping
SYMBOL: value-classes

: value-interval ( value -- interval/f )
    resolve-copy value-intervals get at ;

: set-value-interval ( interval value -- )
    resolve-copy value-intervals get set-at ;

: intersect-value-interval ( interval value -- )
    resolve-copy value-intervals get [ interval-intersect ] change-at ;

M: interval-constraint apply-constraint
    [ interval>> ] [ value>> ] bi intersect-value-interval ;

: set-class-interval ( class value -- )
    over class? [
        [ "interval" word-prop ] dip over
        [ resolve-copy set-value-interval ] [ 2drop ] if
    ] [ 2drop ] if ;

: value-class ( value -- class )
    resolve-copy value-classes get at null or ;

: set-value-class ( class value -- )
    resolve-copy over [
        dup value-intervals get at [
            2dup set-class-interval
        ] unless
        2dup <class-constraint> assume
    ] when
    value-classes get set-at ;

: intersect-value-class ( class value -- )
    resolve-copy value-classes get [ class-and ] change-at ;

M: class-constraint apply-constraint
    [ class>> ] [ value>> ] bi intersect-value-class ;

: literal-interval ( value -- interval/f )
    dup real? [ [a,a] ] [ drop f ] if ;

: value-literal ( value -- obj ? )
    resolve-copy value-literals get at* ;

: set-value-literal ( literal value -- )
    resolve-copy {
        [ [ class ] dip set-value-class ]
        [ [ literal-interval ] dip set-value-interval ]
        [ <literal-constraint> assume ]
        [ value-literals get set-at ]
    } 2cleave ;

M: literal-constraint apply-constraint
    [ literal>> ] [ value>> ] bi set-value-literal ;

M: literal-constraint constraint-satisfied?
    dup value>> value-literal
    [ swap literal>> eql? ] [ 2drop f ] if ;

M: class-constraint constraint-satisfied?
    [ value>> value-class ] [ class>> ] bi class<= ;

M: pair apply-constraint
    first2
    [ constraints get set-at ]
    [ constraint-satisfied? [ apply-constraint ] [ drop ] if ] 2bi ;

M: pair constraint-satisfied?
    first constraint-satisfied? ;
