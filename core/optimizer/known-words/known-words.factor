! Copyright (C) 2005, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer.known-words
USING: accessors alien arrays generic hashtables definitions
inference.dataflow inference.state inference.class kernel assocs
math math.order math.private kernel.private sequences words
parser vectors strings sbufs io namespaces assocs quotations
sequences.private io.binary io.streams.string layouts splitting
math.intervals math.floats.private classes.tuple classes.predicate
classes.tuple.private classes classes.algebra optimizer.def-use
optimizer.backend optimizer.pattern-match optimizer.inlining
sequences.private combinators byte-arrays byte-vectors ;

{ <tuple> <tuple-boa> (tuple) } [
    [
        dup node-in-d peek node-literal
        dup tuple-layout? [ class>> ] [ drop tuple ] if
        1array f
    ] "output-classes" set-word-prop
] each

\ new [
    dup node-in-d peek node-literal
    dup class? [ drop tuple ] unless 1array f
] "output-classes" set-word-prop

! if the input to new is a literal tuple class, we can expand it
: literal-new? ( #call -- ? )
    dup in-d>> first node-literal tuple-class? ;

: new-quot ( class -- quot )
    dup all-slots 1 tail ! delegate slot
    [ [ initial>> literalize , ] each literalize , \ boa , ] [ ] make ;

: expand-new ( #call -- node )
    dup dup in-d>> first node-literal
    [ +inlined+ depends-on ] [ new-quot ] bi
    f splice-quot ;

\ new {
    { [ dup literal-new? ] [ expand-new ] }
} define-optimizers

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

: expand-member ( #call quot -- )
    >r dup node-in-d peek value-literal r> call f splice-quot ;

: bit-member-n 256 ; inline

: bit-member? ( seq -- ? )
    #! Can we use a fast byte array test here?
    {
        { [ dup length 8 < ] [ f ] }
        { [ dup [ integer? not ] contains? ] [ f ] }
        { [ dup [ 0 < ] contains? ] [ f ] }
        { [ dup [ bit-member-n >= ] contains? ] [ f ] }
        [ t ]
    } cond nip ;

: bit-member-seq ( seq -- flags )
    bit-member-n swap [ member? 1 0 ? ] curry B{ } map-as ;

: exact-float? ( f -- ? )
    dup float? [ dup >integer >float = ] [ drop f ] if ; inline

: bit-member-quot ( seq -- newquot )
    [
        [ drop ] % ! drop the sequence itself; we don't use it at run time
        bit-member-seq ,
        [
            {
                { [ over fixnum? ] [ ?nth 1 eq? ] }
                { [ over bignum? ] [ ?nth 1 eq? ] }
                { [ over exact-float? ] [ ?nth 1 eq? ] }
                [ 2drop f ]
            } cond
        ] %
    ] [ ] make ;

: member-quot ( seq -- newquot )
    dup bit-member? [
        bit-member-quot
    ] [
        [ literalize [ t ] ] { } map>assoc
        [ drop f ] suffix [ nip case ] curry
    ] if ;

\ member? {
    { [ dup literal-member? ] [ [ member-quot ] expand-member ] }
} define-optimizers

: memq-quot ( seq -- newquot )
    [ [ dupd eq? ] curry [ drop t ] ] { } map>assoc
    [ drop f ] suffix [ nip cond ] curry ;

\ memq? {
    { [ dup literal-member? ] [ [ memq-quot ] expand-member ] }
} define-optimizers

! if the result of eq? is t and the second input is a literal,
! the first input is equal to the second
\ eq? [
    dup node-in-d second dup value? [
        swap [
            value-literal 0 `input literal,
            \ f class-not 0 `output class,
        ] set-constraints
    ] [
        2drop
    ] if
] "constraints" set-word-prop

! Eliminate instance? checks when the outcome is known at compile time
: (optimize-instance) ( #call -- #call value class/f )
    [ ] [ in-d>> first ] [ dup in-d>> second node-literal ] tri ;

: optimize-instance? ( #call -- ? )
    (optimize-instance) dup class?
    [ optimize-check? ] [ 3drop f ] if ;

: optimize-instance ( #call -- node )
    (optimize-instance) optimize-check ;

\ instance? {
    { [ dup optimize-instance? ] [ optimize-instance ] }
} define-optimizers

! eq? on the same object is always t
{ eq? = } {
    { { @ @ } [ 2drop t ] }
} define-identities

! Specializers
{ first first2 first3 first4 }
[ { array } "specializer" set-word-prop ] each

{ peek pop* pop push } [
    { vector } "specializer" set-word-prop
] each

\ push-all
{ { string sbuf } { array vector } { byte-array byte-vector } }
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

\ split, { string string } "specializer" set-word-prop

\ memq? { array } "specializer" set-word-prop

\ member? { fixnum string } "specializer" set-word-prop

\ assoc-stack { vector } "specializer" set-word-prop

\ >le { { fixnum fixnum } { bignum fixnum } } "specializer" set-word-prop

\ >be { { bignum fixnum } { fixnum fixnum } } "specializer" set-word-prop
