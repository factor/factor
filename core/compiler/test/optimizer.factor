USING: arrays compiler generic
hashtables inference kernel kernel-internals math
optimizer prettyprint sequences sbufs strings test vectors words
sequences-internals quotations ;
IN: temporary

! Test method inlining
[ f ] [ fixnum { } min-class ] unit-test

[ string ] [
    \ string
    [ integer string array reversed sbuf
    slice vector quotation ]
    sort-classes min-class
] unit-test

[ fixnum ] [
    \ fixnum
    [ fixnum integer object ]
    sort-classes min-class
] unit-test

[ integer ] [
    \ fixnum
    [ integer float object ]
    sort-classes min-class
] unit-test

[ object ] [
    \ word
    [ integer float object ]
    sort-classes min-class
] unit-test

[ reversed ] [
    \ reversed
    [ integer reversed slice ]
    sort-classes min-class
] unit-test

FORGET: xyz
GENERIC: xyz ( obj -- obj )
M: array xyz xyz ;

[ ] [ \ xyz compile ] unit-test

! Test predicate inlining
: pred-test-1
    dup fixnum? [
        dup integer? [ "integer" ] [ "nope" ] if
    ] [
        "not a fixnum"
    ] if ;

[ 1 "integer" ] [ 1 pred-test-1 ] unit-test

TUPLE: pred-test ;

: pred-test-2
    dup tuple? [
        dup pred-test? [ "pred-test" ] [ "nope" ] if
    ] [
        "not a tuple"
    ] if ;

[ T{ pred-test } "pred-test" ] [ T{ pred-test } pred-test-2 ] unit-test

: pred-test-3
    dup pred-test? [
        dup tuple? [ "pred-test" ] [ "nope" ] if
    ] [
        "not a tuple"
    ] if ;

[ T{ pred-test } "pred-test" ] [ T{ pred-test } pred-test-3 ] unit-test

: inline-test
    "nom" = ;

[ t ] [ "nom" inline-test ] unit-test
[ f ] [ "shayin" inline-test ] unit-test
[ f ] [ 3 inline-test ] unit-test

: fixnum-declarations >fixnum 24 shift 1234 bitxor ;

[ ] [ 1000000 fixnum-declarations . ] unit-test

! regression

: literal-not-branch 0 not [ ] [ ] if ;

[ ] [ literal-not-branch ] unit-test

! regression

: bad-kill-1 [ 3 f ] [ dup bad-kill-1 ] if ; inline
: bad-kill-2 bad-kill-1 drop ;

[ 3 ] [ t bad-kill-2 ] unit-test

! regression
: (the-test) dup 0 > [ 1- (the-test) ] when ; inline
: the-test 2 dup (the-test) ;

[ 2 0 ] [ the-test ] unit-test

! regression
: (double-recursion) ( start end -- )
    < [
        6 1 (double-recursion)
        3 2 (double-recursion)
    ] when ; inline

: double-recursion 0 2 (double-recursion) ;

[ ] [ double-recursion ] unit-test

! regression
: double-label-1
    [ f double-label-1 ] [ swap nth-unsafe ] if ; inline
: double-label-2
    dup array? [ ] [ ] if 0 t double-label-1 ;

[ 0 ] [ 10 double-label-2 ] unit-test

! regression
GENERIC: void-generic ( obj -- * )
: breakage "hi" void-generic ;
[ ] [ \ breakage compile ] unit-test
[ breakage ] unit-test-fails

! regression
: test-0 dup 0 = [ drop ] [ 1- test-0 ] if ; inline
: test-1 t [ test-0 ] [ delegate dup [ test-1 ] [ drop ] if ] if ; inline
: test-2 5 test-1 ;

[ f ] [ f test-2 ] unit-test

: branch-fold-regression-0
    t [ ] [ 1+ branch-fold-regression-0 ] if ; inline

: branch-fold-regression-1
    10 branch-fold-regression-0 ;

[ 10 ] [ branch-fold-regression-1 ] unit-test

! another regression
: constant-branch-fold-0 "hey" ; foldable
: constant-branch-fold-1 constant-branch-fold-0 "hey" = ; inline
[ 1 ] [ [ constant-branch-fold-1 [ 1 ] [ 2 ] if ] compile-1 ] unit-test

! another regression
: foo f ;
: bar foo 4 4 = and ;
[ f ] [ bar ] unit-test

! ensure identities are working in some form
[ t ] [
    [ 0 + ] dataflow optimize [ #push? not ] all-nodes?
] unit-test

! compiling <tuple> with a non-literal class failed
[ t ] [ [ <tuple> ] compile-quot word? ] unit-test

GENERIC: foozul
M: reversed foozul ;
M: integer foozul ;
M: slice foozul ;

[ reversed ] [ reversed \ foozul specific-method ] unit-test
