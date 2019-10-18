! Copyright (C) 2005, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: optimizer
USING: arrays errors generic hashtables inference kernel
math math-internals kernel-internals sequences words parser
class-inference vectors strings sbufs io ;

! the output of <tuple> has the class which is its first input
\ <tuple> [
    node-in-d first dup value?
    [ value-literal 1array ] [ drop { tuple } ] if
] "output-classes" set-word-prop

! the output of clone has the same type as the input
{ clone (clone) } [
    [
        node-in-d [ value-class* ] map
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
    [ swap ?hash ] map-with
    first2 2dup and [ classes-intersect? not ] [ 2drop f ] if ;

\ eq? {
    { [ dup disjoint-eq? ] [ [ f ] inline-literals ] }
} define-optimizers

! if the result of eq? is t and the second input is a literal,
! the first input is equal to the second
\ eq? [
    dup node-in-d second dup value? [
        [
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
    0 node-class# types length 1 number= ;

: fold-known-type ( node -- node )
    dup 0 node-class# types first 1array inline-literals ;

\ type [
    { [ dup known-type? ] [ fold-known-type ] }
] define-optimizers

! if the result of type is n, then the object has type n
{ tag type } [
    [
        num-types [
            [
                [ type>class 0 `input class, ] keep
                0 `output literal,
            ] set-constraints
        ] each-with
    ] "constraints" set-word-prop
] each

! Adding 1 to a small fixnum outputs a fixnum
\ fixnum+ [
    [
        fixnum 0 `output class,
        small 0 `input class,
        1 1 `input literal,
    ] set-constraints
] "constraints" set-word-prop

! fixnum+ >fixnum becomes fixnum+fast
: consumed-by? ( node word -- ? )
    swap node-out-d first used-by dup length 1 = [
        first dup #call? >r node-param eq? r> and
    ] [
        2drop f
    ] if ;

\ fixnum+ [
    {
        [ dup \ >fixnum consumed-by? ]
        [ [ fixnum+fast ] splice-quot ]
    }
] define-optimizers

{ + bignum+ float+ fixnum+fast } {
    { { @ 0 } [ drop ] }
    { { 0 @ } [ nip ]  }
} define-identities

{ fixnum+ } {
    { { @ 0 } [ drop ] }
    { { 0 @ } [ nip ]  }
    { { small 1 } [ drop 1 fixnum+fast ] }
    { { 1 small } [ nip 1 fixnum+fast ] }
} define-identities

! Some rules like adding two fixnums yields an integer, adding
! 1 to a small yields a fixnum, etc.
: math-closure ( class -- newclass )
    { fixnum integer rational real number object }
    [ class< ] find-with nip ;

\ 1+ [
    node-in-d first value-class* dup small eq?
    [ drop fixnum ]
    [ integer math-class-max math-closure ] if
    1array
] "output-classes" set-word-prop

! fixnum- >fixnum becomes fixnum-fast
\ fixnum- [
    {
        [ dup \ >fixnum consumed-by? ]
        [ [ fixnum-fast ] splice-quot ]
    }
] define-optimizers

{ - fixnum- bignum- float- fixnum-fast } {
    { { @ 0 } [ drop ]    }
    { { @ @ } [ 2drop 0 ] }
} define-identities

! if a is less than b and b is a fixnum, then a is small
\ < [
    [
        small 0 `input class,
        fixnum 0 `input class,
        fixnum 1 `input class,
        general-t 0 `output class,
    ] set-constraints
] "constraints" set-word-prop

\ fixnum< [
    [
        small 0 `input class,
        general-t 0 `output class,
    ] set-constraints
] "constraints" set-word-prop

{ < fixnum< bignum< float< } {
    { { @ @ } [ 2drop f ] }
} define-identities

{ <= fixnum<= bignum<= float<= } {
    { { @ @ } [ 2drop t ] }
} define-identities

! if a is not >= than b and b is a fixnum, then a is small
\ >= [
    [
        small 0 `input class,
        fixnum 0 `input class,
        fixnum 1 `input class,
        \ f 0 `output class,
    ] set-constraints
] "constraints" set-word-prop

\ fixnum>= [
    [
        small 0 `input class,
        \ f 0 `output class,
    ] set-constraints
] "constraints" set-word-prop
    
{ > fixnum> bignum> float>= } {
    { { @ @ } [ 2drop f ] }
} define-identities

{ >= fixnum>= bignum>= float>= } {
    { { @ @ } [ 2drop t ] }
} define-identities

! More identities
{ * fixnum* bignum* float* } {
    { { @ 1 }  [ drop ]          }
    { { 1 @ }  [ nip ]           }
    { { @ 0 }  [ nip ]           }
    { { 0 @ }  [ drop ]          }
    { { @ -1 } [ drop 0 swap - ] }
    { { -1 @ } [ nip 0 swap - ]  }
} define-identities

{ / fixnum/i bignum/i float/f } {
    { { @ 1 }  [ drop ]          }
    { { @ -1 } [ drop 0 swap - ] }
} define-identities

{ fixnum-mod bignum-mod } {
    { { @ 1 }  [ 2drop 0 ] }
} define-identities

{ bitand fixnum-bitand bignum-bitand } {
    { { @ -1 } [ drop ] }
    { { -1 @ } [ nip  ] }
    { { @ @ }  [ drop ] }
    { { @ 0 }  [ nip  ] }
    { { 0 @ }  [ drop ] }
} define-identities

{ bitor fixnum-bitor bignum-bitor } {
    { { @ 0 }  [ drop ] }
    { { 0 @ }  [ nip  ] }
    { { @ @ }  [ drop ] }
    { { @ -1 } [ nip  ] }
    { { -1 @ } [ drop ] }
} define-identities

{ bitxor fixnum-bitxor bignum-bitxor } {
    { { @ 0 }  [ drop ]        }
    { { 0 @ }  [ nip  ]        }
    { { @ -1 } [ drop bitnot ] }
    { { -1 @ } [ nip  bitnot ] }
    { { @ @ }  [ 2drop 0 ]     }
} define-identities

{ shift fixnum-shift bignum-shift } {
    { { 0 @ } [ drop ] }
    { { @ 0 } [ drop ] }
} define-identities

! Handle this better later on
{
    { >fixnum fixnum }
    { >bignum bignum }
    { >float float }
} [
    first2 1array [ nip ] curry "output-classes" set-word-prop
] each

! Specializers
{ 1+ 1- sq neg recip sgn truncate } [
    { number } "specializer" set-word-prop
] each

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

{ hash* remove-hash set-hash } [
    { hashtable } "specializer" set-word-prop
] each

{ first first2 first3 first4 }
[ { array } "specializer" set-word-prop ] each

{ peek pop* pop push } [
    { vector } "specializer" set-word-prop
] each

\ nappend
{ { string array } { sbuf vector } }
"specializer" set-word-prop

\ append
{ { string array } { string array } }
"specializer" set-word-prop

\ subseq
{ fixnum fixnum { string array } }
"specializer" set-word-prop

\ nreverse
{ { string array } }
"specializer" set-word-prop

\ mismatch
{ string string }
"specializer" set-word-prop

\ find-last-sep { string sbuf } "specializer" set-word-prop
