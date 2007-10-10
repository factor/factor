USING: arrays compiler generic hashtables inference kernel
kernel.private math optimizer prettyprint sequences sbufs
strings tools.test vectors words sequences.private quotations
optimizer.backend classes inference.dataflow tuples.private ;
IN: temporary

[ H{ { 1 5 } { 3 4 } { 2 5 } } ] [
    H{ { 1 2 } { 3 4 } } H{ { 2 5 } } union*
] unit-test

[ H{ { 1 4 } { 2 4 } { 3 4 } } ] [
    H{ { 1 2 } { 3 4 } } H{ { 2 3 } } union*
] unit-test

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
: (the-test) ( n -- ) dup 0 > [ 1- (the-test) ] when ; inline
: the-test ( -- n ) 2 dup (the-test) ;

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
: double-label-1 ( a b c -- d )
    [ f double-label-1 ] [ swap nth-unsafe ] if ; inline

: double-label-2 ( a -- b )
    dup array? [ ] [ ] if 0 t double-label-1 ;

[ 0 ] [ 10 double-label-2 ] unit-test

! regression
GENERIC: void-generic ( obj -- * )
: breakage "hi" void-generic ;
[ ] [ \ breakage compile ] unit-test
[ breakage ] unit-test-fails

! regression
: test-0 ( n -- ) dup 0 = [ drop ] [ 1- test-0 ] if ; inline
: test-1 ( n -- ) t [ test-0 ] [ delegate dup [ test-1 ] [ drop ] if ] if ; inline
: test-2 ( -- ) 5 test-1 ;

[ f ] [ f test-2 ] unit-test

: branch-fold-regression-0 ( n -- )
    t [ ] [ 1+ branch-fold-regression-0 ] if ; inline

: branch-fold-regression-1 ( -- )
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
    [ { number } declare 0 + ] dataflow optimize
    [ #push? ] node-exists? not
] unit-test

! compiling <tuple> with a non-literal class failed
[ t ] [ [ <tuple> ] compile-quot word? ] unit-test

GENERIC: foozul
M: reversed foozul ;
M: integer foozul ;
M: slice foozul ;

[ reversed ] [ reversed \ foozul specific-method ] unit-test

! regression
: constant-fold-2 f ; foldable
: constant-fold-3 4 ; foldable

[ f t ] [
    [ constant-fold-2 constant-fold-3 4 = ] compile-1
] unit-test

: constant-fold-4 f ; foldable
: constant-fold-5 f ; foldable

[ f ] [
    [ constant-fold-4 constant-fold-5 or ] compile-1
] unit-test

[ 5 ] [ 5 [ 0 + ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 swap + ] compile-1 ] unit-test

[ 5 ] [ 5 [ 0 - ] compile-1 ] unit-test
[ -5 ] [ 5 [ 0 swap - ] compile-1 ] unit-test
[ 0 ] [ 5 [ dup - ] compile-1 ] unit-test

[ 5 ] [ 5 [ 1 * ] compile-1 ] unit-test
[ 5 ] [ 5 [ 1 swap * ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 * ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 swap * ] compile-1 ] unit-test
[ -5 ] [ 5 [ -1 * ] compile-1 ] unit-test
[ -5 ] [ 5 [ -1 swap * ] compile-1 ] unit-test

[ 5 ] [ 5 [ 1 / ] compile-1 ] unit-test
[ 1/5 ] [ 5 [ 1 swap / ] compile-1 ] unit-test
[ -5 ] [ 5 [ -1 / ] compile-1 ] unit-test

[ 0 ] [ 5 [ 1 mod ] compile-1 ] unit-test
[ 0 ] [ 5 [ 1 rem ] compile-1 ] unit-test

[ 5 ] [ 5 [ -1 bitand ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 bitand ] compile-1 ] unit-test
[ 5 ] [ 5 [ -1 swap bitand ] compile-1 ] unit-test
[ 0 ] [ 5 [ 0 swap bitand ] compile-1 ] unit-test
[ 5 ] [ 5 [ dup bitand ] compile-1 ] unit-test

[ 5 ] [ 5 [ 0 bitor ] compile-1 ] unit-test
[ -1 ] [ 5 [ -1 bitor ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 swap bitor ] compile-1 ] unit-test
[ -1 ] [ 5 [ -1 swap bitor ] compile-1 ] unit-test
[ 5 ] [ 5 [ dup bitor ] compile-1 ] unit-test

[ 5 ] [ 5 [ 0 bitxor ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 swap bitxor ] compile-1 ] unit-test
[ -6 ] [ 5 [ -1 bitxor ] compile-1 ] unit-test
[ -6 ] [ 5 [ -1 swap bitxor ] compile-1 ] unit-test
[ 0 ] [ 5 [ dup bitxor ] compile-1 ] unit-test

[ 0 ] [ 5 [ 0 swap shift ] compile-1 ] unit-test
[ 5 ] [ 5 [ 0 shift ] compile-1 ] unit-test

[ f ] [ 5 [ dup < ] compile-1 ] unit-test
[ t ] [ 5 [ dup <= ] compile-1 ] unit-test
[ f ] [ 5 [ dup > ] compile-1 ] unit-test
[ t ] [ 5 [ dup >= ] compile-1 ] unit-test

[ t ] [ 5 [ dup eq? ] compile-1 ] unit-test
[ t ] [ 5 [ dup = ] compile-1 ] unit-test
[ t ] [ 5 [ dup number= ] compile-1 ] unit-test
[ t ] [ \ vector [ \ vector = ] compile-1 ] unit-test

[ 3 ] [ 10/3 [ { ratio } declare 1 /i ] compile-1 ] unit-test

GENERIC: detect-number ( obj -- obj )
M: number detect-number ;

[ 10 f [ <array> 0 + detect-number ] compile-1 ] unit-test-fails

! Regression
[ 4 [ + ] ] [ 2 2 [ [ + ] [ call ] keep ] compile-1 ] unit-test

! Regression
USE: sorting
USE: sorting.private

: old-binsearch ( elt quot seq -- elt quot i )
    dup length 1 <= [
        slice-from
    ] [
        [ midpoint swap call ] 3keep roll dup zero?
        [ drop dup slice-from swap midpoint@ + ]
        [ partition old-binsearch ] if
    ] if ; inline

[ 10 ] [
    10 20 >vector <flat-slice>
    [ [ - ] swap old-binsearch ] compile-1 2nip
] unit-test

! Regression
[ 1 2 { real imaginary } ] [
    C{ 1 2 }
    [ { real imaginary } [ get-slots ] keep ] compile-1
] unit-test
