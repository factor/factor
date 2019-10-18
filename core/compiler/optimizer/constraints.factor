! Copyright (C) 2004, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays generic assocs hashtables inference kernel
math namespaces sequences words parser intervals ;
IN: class-inference

! A constraint is a statement about a value.

! We need a notion of equality which doesn't recurse so cannot
! infinite loop on circular data
GENERIC: eql? ( obj1 obj2 -- ? )
M: object eql? eq? ;
M: number eql? number= ;

! Maps constraints to constraints
SYMBOL: constraints

TUPLE: literal-constraint literal value ;

M: literal-constraint equal?
    over literal-constraint? [
        2dup
        [ literal-constraint-literal ] 2apply eql? >r
        [ literal-constraint-value ] 2apply = r> and
    ] [
        2drop f
    ] if ;

TUPLE: class-constraint class value ;

TUPLE: interval-constraint interval value ;

GENERIC: apply-constraint ( constraint -- )
GENERIC: constraint-satisfied? ( constraint -- ? )

: `input node get node-in-d nth ;
: `output node get node-out-d nth ;
: class, <class-constraint> , ;
: literal, <literal-constraint> , ;
: interval, <interval-constraint> , ;

M: f apply-constraint drop ;

: make-constraints ( node quot -- constraint )
    [ swap node set call ] { } make ; inline

: set-constraints ( node quot -- )
    make-constraints
    unclip [ 2array ] reduce
    apply-constraint ; inline

: assume ( constraint -- )
    constraints get at [ apply-constraint ] when* ;
