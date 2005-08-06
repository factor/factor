IN: temporary
USING: generic kernel-internals strings vectors ;
USE: test
USE: assembler
USE: compiler
USE: compiler-frontend
USE: inference
USE: words
USE: math
USE: kernel
USE: lists
USE: sequences

! Some dataflow tests
[ 3 ] [ 1 2 3 (subst-value) ] unit-test
[ 1 ] [ 1 2 2 (subst-value) ] unit-test

[ { "one" "one" "three" "three" } ]
[
    { "one" "two" "three" } { 1 2 3 } { 1 1 3 3 }
    clone [ (subst-values) ] keep
] unit-test

[ << meet f { "one" 2 3 } >> ]
[ "one" 1 << meet f { 1 2 3 } >> clone (subst-value) ] unit-test

! Literal kill tests
: kill-set*
    dataflow kill-set [ literal-value ] map ;

: foo 1 2 3 ;

[ [ ] ] [ \ foo word-def dataflow kill-set ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] kill-set* ] unit-test

[ [ [ 1 ] [ 2 ] ] ] [ [ [ 1 ] [ 2 ] ifte ] kill-set* ] unit-test

[ [ t t f ] ] [
    [ 1 2 3 ] [ <literal> ] map
    [ [ literal-value 2 <= ] subset ] keep in-d-node <#drop> kill-mask
] unit-test

: literal-kill-test-1 4 compiled-offset cell 2 * - ; compiled

[ 4 ] [ literal-kill-test-1 drop ] unit-test

: literal-kill-test-2 3 compiled-offset cell 2 * - ; compiled

[ 3 ] [ literal-kill-test-2 drop ] unit-test

: literal-kill-test-3 10 3 /mod drop ; compiled

[ 3 ] [ literal-kill-test-3 ] unit-test

[ [ [ 3 ] [ dup ] ] ] [ [ [ 3 ] [ dup ] ifte drop ] kill-set* ] unit-test

: literal-kill-test-4
    5 swap [ 3 ] [ dup ] ifte 2drop ; compiled

[ ] [ t literal-kill-test-4 ] unit-test
[ ] [ f literal-kill-test-4 ] unit-test

[ [ [ 3 ] [ dup ] ] ] [ \ literal-kill-test-4 word-def kill-set* ] unit-test

: literal-kill-test-5
    5 swap [ 5 ] [ dup ] ifte 2drop ; compiled

[ ] [ t literal-kill-test-5 ] unit-test
[ ] [ f literal-kill-test-5 ] unit-test

[ [ [ 5 ] [ dup ] ] ] [ \ literal-kill-test-5 word-def kill-set* ] unit-test

: literal-kill-test-6
    5 swap [ dup ] [ dup ] ifte 2drop ; compiled

[ ] [ t literal-kill-test-6 ] unit-test
[ ] [ f literal-kill-test-6 ] unit-test

[ [ 5 [ dup ] [ dup ] ] ] [ \ literal-kill-test-6 word-def kill-set* ] unit-test

: literal-kill-test-7
    [ 1 2 3 ] >r + r> drop ; compiled

[ 4 ] [ 2 2 literal-kill-test-7 ] unit-test

! Test method inlining
[ string ] [
    \ string
    [ range repeated integer string mirror array reversed sbuf
    slice vector diagonal general-list ]
    min-class
] unit-test

[ f ] [
    \ fixnum
    [ fixnum integer letter ]
    min-class
] unit-test

[ fixnum ] [
    \ fixnum
    [ fixnum integer object ]
    min-class
] unit-test

[ integer ] [
    \ fixnum
    [ integer float object ]
    min-class
] unit-test

[ object ] [
    \ word
    [ integer float object ]
    min-class
] unit-test

GENERIC: xyz
M: cons xyz xyz ;

[ ] [ \ xyz compile ] unit-test

! Test predicate inlining
: pred-test-1
    dup cons? [
        dup general-list? [ "general-list" ] [ "nope" ] ifte
    ] [
        "not a cons"
    ] ifte ; compiled

[ [[ 1 2 ]] "general-list" ] [ [[ 1 2 ]] pred-test-1 ] unit-test

: pred-test-2
    dup fixnum? [
        dup integer? [ "integer" ] [ "nope" ] ifte
    ] [
        "not a fixnum"
    ] ifte ; compiled

[ 1 "integer" ] [ 1 pred-test-2 ] unit-test

TUPLE: pred-test ;

: pred-test-3
    dup tuple? [
        dup pred-test? [ "pred-test" ] [ "nope" ] ifte
    ] [
        "not a tuple"
    ] ifte ; compiled

[ << pred-test >> "pred-test" ] [ << pred-test >> pred-test-3 ] unit-test

: pred-test-4
    dup pred-test? [
        dup tuple? [ "pred-test" ] [ "nope" ] ifte
    ] [
        "not a tuple"
    ] ifte ; compiled

[ << pred-test >> "pred-test" ] [ << pred-test >> pred-test-4 ] unit-test
