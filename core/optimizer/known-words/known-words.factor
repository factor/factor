! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer.known-words
USING: alien arrays generic hashtables inference.dataflow
inference.class kernel assocs math math.private kernel.private
sequences words parser vectors strings sbufs io namespaces
assocs quotations sequences.private io.binary io.crc32
io.streams.string layouts splitting math.intervals
math.floats.private tuples tuples.private classes
classes.algebra optimizer.def-use optimizer.backend
optimizer.pattern-match optimizer.inlining float-arrays
sequences.private combinators ;

{ <tuple> <tuple-boa> } [
    [
        dup node-in-d peek node-literal
        dup tuple-layout? [ layout-class ] [ drop tuple ] if
        1array f
    ] "output-classes" set-word-prop
] each

\ construct-empty [
    dup node-in-d peek node-literal
    dup class? [ drop tuple ] unless 1array f
] "output-classes" set-word-prop

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
    dup sole-consumer (flip-branches) [ ] f splice-quot ;

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

: literal-member? ( #call -- ? )
    node-in-d peek dup value?
    [ value-literal sequence? ] [ drop f ] if ;

: member-quot ( seq -- newquot )
    [ [ t ] ] { } map>assoc [ drop f ] add [ nip case ] curry ;

: expand-member ( #call -- )
    dup node-in-d peek value-literal member-quot f splice-quot ;

\ member? {
    { [ dup literal-member? ] [ expand-member ] }
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
    node-class-first class-types length 1 number= ;

: fold-known-type ( node -- node )
    dup node-class-first class-types inline-literals ;

\ type [
    { [ dup known-type? ] [ fold-known-type ] }
] define-optimizers

! if the result of type is n, then the object has type n
{ tag type } [
    [
        num-types get swap [
            [
                [ type>class object or 0 `input class, ] keep
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
{ { string sbuf } { array vector } }
"specializer" set-word-prop

\ append
{ { string string } { array array } }
"specializer" set-word-prop

\ subseq
{ { fixnum fixnum string } { fixnum fixnum array } }
"specializer" set-word-prop

\ reverse-here
{ { string } { array } }
"specializer" set-word-prop

\ mismatch
{ string string }
"specializer" set-word-prop

\ find-last-sep { string sbuf } "specializer" set-word-prop

\ >string { sbuf } "specializer" set-word-prop

\ >array { { string } { vector } } "specializer" set-word-prop

\ >vector { { array } { vector } } "specializer" set-word-prop

\ >sbuf { string } "specializer" set-word-prop

\ crc32 { string } "specializer" set-word-prop

\ split, { string string } "specializer" set-word-prop

\ memq? { array } "specializer" set-word-prop

\ member? { fixnum string } "specializer" set-word-prop

\ assoc-stack { vector } "specializer" set-word-prop

\ >le { { fixnum fixnum } { bignum fixnum } } "specializer" set-word-prop

\ >be { { bignum fixnum } { fixnum fixnum } } "specializer" set-word-prop
