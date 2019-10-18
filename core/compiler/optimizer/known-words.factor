! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: alien arrays errors generic hashtables inference kernel
assocs math math-internals kernel-internals sequences words
parser class-inference vectors strings sbufs io namespaces
assocs quotations intervals sequences-internals ;

! the output of <tuple> has the class which is its first input
\ <tuple> [
    node-in-d first dup value?
    [ value-literal 1array ] [ drop { tuple } ] if
    f
] "output-classes" set-word-prop

! the output of clone has the same type as the input
{ clone (clone) } [
    [
        node-in-d [ value-class* ] map f
    ] "output-classes" set-word-prop
] each

! not [ A ] [ B ] if ==> [ B ] [ A ] if
: (flip-branches) ( #if -- )
    dup node-children reverse swap set-node-children ;

: flip-branches ( not -- #if )
    #! If a not is followed by an #if, flip branches and
    #! remove the not.
    dup node-successor (flip-branches) [ ] splice-quot ;

\ not {
    { [ dup node-successor #if? ] [ flip-branches ] }
} define-optimizers

! eq? on objects of disjoint types is always f
: disjoint-eq? ( node -- ? )
    dup node-classes swap node-in-d
    [ swap at ] map-with
    first2 2dup and [ classes-intersect? not ] [ 2drop f ] if ;

\ eq? {
    { [ dup disjoint-eq? ] [ [ f ] inline-literals ] }
} define-optimizers

! if the result of eq? is t and the second input is a literal,
! the first input is equal to the second
\ eq? [
    dup node-in-d second dup value? [
        swap [
            value-literal 0 `input literal,
            general-t 0 `output class,
        ] set-constraints
    ] [
        2drop
    ] if
] "constraints" set-word-prop

! eq? on the same object is always t
{ eq? bignum= float= number= = } {
    { { @ @ } [ 2drop t ] }
} define-identities

! type applied to an object of a known type can be folded
: known-type? ( node -- ? )
    node-class-first types length 1 number= ;

: fold-known-type ( node -- node )
    dup node-class-first types inline-literals ;

\ type [
    { [ dup known-type? ] [ fold-known-type ] }
] define-optimizers

! if the result of type is n, then the object has type n
{ tag type } [
    [
        num-types get [
            swap [
                [ type>class 0 `input class, ] keep
                0 `output literal,
            ] set-constraints
        ] each-with
    ] "constraints" set-word-prop
] each

! Specializers
{ 1+ 1- sq neg recip sgn truncate } [
    { number } "specializer" set-word-prop
] each

\ 2/ { fixnum } "specializer" set-word-prop

{ min max } [
    { number number } "specializer" set-word-prop
] each

{ vneg norm-sq norm normalize } [
    { array } "specializer" set-word-prop
] each

\ n*v { * array } "specializer" set-word-prop
\ v*n { array * } "specializer" set-word-prop
\ n/v { * array } "specializer" set-word-prop
\ v/n { array * } "specializer" set-word-prop

{ v+ v- v* v/ vmax vmin v. } [
    { array array } "specializer" set-word-prop
] each

{ first first2 first3 first4 }
[ { array } "specializer" set-word-prop ] each

{ peek pop* pop push } [
    { vector } "specializer" set-word-prop
] each

\ push-all
{ { string array } { sbuf vector } }
"specializer" set-word-prop

\ append
{ { string array } { string array } }
"specializer" set-word-prop

\ subseq
{ fixnum fixnum { string array } }
"specializer" set-word-prop

\ reverse-here
{ { string array } }
"specializer" set-word-prop

\ mismatch
{ string string }
"specializer" set-word-prop

\ find-last-sep { string sbuf } "specializer" set-word-prop
