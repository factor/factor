! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler
USING: arrays generic kernel math namespaces sequences words ;

: make-specializer ( quot class picker -- quot )
    over \ object eq? [
        2drop
    ] [
        [
            , "predicate" word-prop % dup , , \ if ,
        ] [ ] make
    ] if ;

: specialized-def ( word -- quot )
    dup word-def swap "specializer" word-prop [
        reverse-slice { dup over pick } [
            make-specializer
        ] 2each
    ] when* ;

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
