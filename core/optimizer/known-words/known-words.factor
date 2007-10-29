! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer.known-words
USING: alien arrays generic hashtables inference.dataflow
inference.class kernel assocs math math.private kernel.private
sequences words parser vectors strings sbufs io namespaces
assocs quotations sequences.private io.binary io.crc32
io.buffers io.streams.string layouts splitting math.intervals
math.floats.private tuples tuples.private classes
optimizer.def-use optimizer.backend optimizer.pattern-match
float-arrays combinators.private ;

! the output of <tuple> and <tuple-boa> has the class which is
! its second-to-last input
{ <tuple> <tuple-boa> } [
    [
        node-in-d dup length 2 - swap nth dup value?
        [ value-literal ] [ drop tuple ] if 1array f
    ] "output-classes" set-word-prop
] each

! the output of clone has the same type as the input
{ clone (clone) } [
    [
        node-in-d [ value-class* ] map f
    ] "output-classes" set-word-prop
] each

! not [ A ] [ B ] if ==> [ B ] [ A ] if
: flip-branches? ( #call -- ? ) sole-consumer #if? ;

: (flip-branches) ( #if -- )
    dup node-children reverse swap set-node-children ;

: flip-branches ( #call -- #if )
    #! If a not is followed by an #if, flip branches and
    #! remove the not.
    dup sole-consumer (flip-branches) [ ] splice-quot ;

\ not {
    { [ dup flip-branches? ] [ flip-branches ] }
} define-optimizers

! eq? on objects of disjoint types is always f
: disjoint-eq? ( node -- ? )
    node-input-classes first2 2dup and
    [ classes-intersect? not ] [ 2drop f ] if ;

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
        num-types get swap [
            [
                [ type>class 0 `input class, ] keep
                0 `output literal,
            ] set-constraints
        ] curry each
    ] "constraints" set-word-prop
] each

! Specializers
{ 1+ 1- sq neg recip sgn } [
    { number } "specializer" set-word-prop
] each

\ 2/ { fixnum } "specializer" set-word-prop

{ min max } [
    { number number } "specializer" set-word-prop
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

\ >string { sbuf } "specializer" set-word-prop

\ >array { { string vector } } "specializer" set-word-prop

\ crc32 { string } "specializer" set-word-prop

\ split, { string string } "specializer" set-word-prop

\ memq? { array } "specializer" set-word-prop

\ member? { fixnum string } "specializer" set-word-prop

\ assoc-stack { vector } "specializer" set-word-prop

\ >le { { fixnum bignum } fixnum } "specializer" set-word-prop

\ >be { { fixnum bignum } fixnum } "specializer" set-word-prop

\ search-buffer-until { fixnum fixnum simple-alien string } "specializer" set-word-prop
