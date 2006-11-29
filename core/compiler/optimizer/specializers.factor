! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic hashtables kernel kernel-internals math
namespaces sequences vectors words ;

: make-standard-specializer ( quot class picker -- quot )
    over \ object eq? [
        2drop
    ] [
        [
            , "predicate" word-prop % dup , , \ if ,
        ] [ ] make
    ] if ;

: make-math-specializer ( quot picker -- quot )
    [
        , \ tag , num-tags swap <array> , \ dispatch ,
    ] [ ] make ;

: make-specializer ( quot class picker -- quot )
    over number eq? [
        nip make-math-specializer
    ] [
        make-standard-specializer
    ] if ;

: specialized-def ( word -- quot )
    dup word-def swap "specializer" word-prop [
        <reversed> { dup over pick } [
            make-specializer
        ] 2each
    ] when* ;

{ 1+ 1- sq neg recip sgn truncate } [
    { number } "specializer" set-word-prop
] each

{ vneg norm-sq norm normalize } [
    { array } "specializer" set-word-prop
] each

\ n*v { object array } "specializer" set-word-prop
\ v*n { array object } "specializer" set-word-prop
\ n/v { object array } "specializer" set-word-prop
\ v/n { array object } "specializer" set-word-prop

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
