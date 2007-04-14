USING: arrays compiler.units generic hashtables inference kernel
kernel.private math optimizer prettyprint sequences sbufs
strings tools.test vectors words sequences.private quotations
optimizer.backend classes classes.algebra inference.dataflow
tuples.private continuations growable optimizer.inlining
namespaces hints ;
IN: optimizer.tests

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

GENERIC: xyz ( obj -- obj )
M: array xyz xyz ;

[ t ] [ \ xyz compiled? ] unit-test

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

: bad-kill-1 ( a b -- c d e ) [ 3 f ] [ dup bad-kill-1 ] if ; inline
: bad-kill-2 bad-kill-1 drop ;

[ 3 ] [ t bad-kill-2 ] unit-test

! regression
: (the-test) ( x -- y ) dup 0 > [ 1- (the-test) ] when ; inline
: the-test ( -- x y ) 2 dup (the-test) ;

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
[ t ] [ \ breakage compiled? ] unit-test
[ breakage ] must-fail

! regression
: test-0 ( n -- ) dup 0 = [ drop ] [ 1- test-0 ] if ; inline
: test-1 ( n -- ) t [ test-0 ] [ delegate dup [ test-1 ] [ drop ] if ] if ; inline
: test-2 ( -- ) 5 test-1 ;

[ f ] [ f test-2 ] unit-test

: branch-fold-regression-0 ( m -- n )
    t [ ] [ 1+ branch-fold-regression-0 ] if ; inline

: branch-fold-regression-1 ( -- m )
    10 branch-fold-regression-0 ;

[ 10 ] [ branch-fold-regression-1 ] unit-test

! another regression
: constant-branch-fold-0 "hey" ; foldable
: constant-branch-fold-1 constant-branch-fold-0 "hey" = ; inline
[ 1 ] [ [ constant-branch-fold-1 [ 1 ] [ 2 ] if ] compile-call ] unit-test

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
: <tuple>-regression <tuple> ;

[ t ] [ \ <tuple>-regression compiled? ] unit-test

GENERIC: foozul ( a -- b )
M: reversed foozul ;
M: integer foozul ;
M: slice foozul ;

[ reversed ] [ reversed \ foozul specific-method ] unit-test

! regression
: constant-fold-2 f ; foldable
: constant-fold-3 4 ; foldable

[ f t ] [
    [ constant-fold-2 constant-fold-3 4 = ] compile-call
] unit-test

: constant-fold-4 f ; foldable
: constant-fold-5 f ; foldable

[ f ] [
    [ constant-fold-4 constant-fold-5 or ] compile-call
] unit-test

[ 5 ] [ 5 [ 0 + ] compile-call ] unit-test
[ 5 ] [ 5 [ 0 swap + ] compile-call ] unit-test

[ 5 ] [ 5 [ 0 - ] compile-call ] unit-test
[ -5 ] [ 5 [ 0 swap - ] compile-call ] unit-test
[ 0 ] [ 5 [ dup - ] compile-call ] unit-test

[ 5 ] [ 5 [ 1 * ] compile-call ] unit-test
[ 5 ] [ 5 [ 1 swap * ] compile-call ] unit-test
[ 0 ] [ 5 [ 0 * ] compile-call ] unit-test
[ 0 ] [ 5 [ 0 swap * ] compile-call ] unit-test
[ -5 ] [ 5 [ -1 * ] compile-call ] unit-test
[ -5 ] [ 5 [ -1 swap * ] compile-call ] unit-test

[ 0 ] [ 5 [ 1 mod ] compile-call ] unit-test
[ 0 ] [ 5 [ 1 rem ] compile-call ] unit-test

[ 5 ] [ 5 [ -1 bitand ] compile-call ] unit-test
[ 0 ] [ 5 [ 0 bitand ] compile-call ] unit-test
[ 5 ] [ 5 [ -1 swap bitand ] compile-call ] unit-test
[ 0 ] [ 5 [ 0 swap bitand ] compile-call ] unit-test
[ 5 ] [ 5 [ dup bitand ] compile-call ] unit-test

[ 5 ] [ 5 [ 0 bitor ] compile-call ] unit-test
[ -1 ] [ 5 [ -1 bitor ] compile-call ] unit-test
[ 5 ] [ 5 [ 0 swap bitor ] compile-call ] unit-test
[ -1 ] [ 5 [ -1 swap bitor ] compile-call ] unit-test
[ 5 ] [ 5 [ dup bitor ] compile-call ] unit-test

[ 5 ] [ 5 [ 0 bitxor ] compile-call ] unit-test
[ 5 ] [ 5 [ 0 swap bitxor ] compile-call ] unit-test
[ -6 ] [ 5 [ -1 bitxor ] compile-call ] unit-test
[ -6 ] [ 5 [ -1 swap bitxor ] compile-call ] unit-test
[ 0 ] [ 5 [ dup bitxor ] compile-call ] unit-test

[ 0 ] [ 5 [ 0 swap shift ] compile-call ] unit-test
[ 5 ] [ 5 [ 0 shift ] compile-call ] unit-test

[ f ] [ 5 [ dup < ] compile-call ] unit-test
[ t ] [ 5 [ dup <= ] compile-call ] unit-test
[ f ] [ 5 [ dup > ] compile-call ] unit-test
[ t ] [ 5 [ dup >= ] compile-call ] unit-test

[ t ] [ 5 [ dup eq? ] compile-call ] unit-test
[ t ] [ 5 [ dup = ] compile-call ] unit-test
[ t ] [ 5 [ dup number= ] compile-call ] unit-test
[ t ] [ \ vector [ \ vector = ] compile-call ] unit-test

GENERIC: detect-number ( obj -- obj )
M: number detect-number ;

[ 10 f [ <array> 0 + detect-number ] compile-call ] must-fail

! Regression
[ 4 [ + ] ] [ 2 2 [ [ + ] [ call ] keep ] compile-call ] unit-test

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
    [ [ - ] swap old-binsearch ] compile-call 2nip
] unit-test

! Regression
TUPLE: silly-tuple a b ;

[ 1 2 { silly-tuple-a silly-tuple-b } ] [
    T{ silly-tuple f 1 2 }
    [
        { silly-tuple-a silly-tuple-b } [ get-slots ] keep
    ] compile-call
] unit-test

! Regression
: empty-compound ;

: node-successor-f-bug ( x -- * )
    [ 3 throw ] [ empty-compound ] compose [ 3 throw ] if ;

[ t ] [ \ node-successor-f-bug compiled? ] unit-test

[ ] [ [ construct-empty ] dataflow optimize drop ] unit-test

[ ] [ [ <tuple> ] dataflow optimize drop ] unit-test

! Make sure we have sane heuristics
: should-inline? method flat-length 10 <= ;

[ t ] [ \ fixnum \ shift should-inline? ] unit-test
[ f ] [ \ array \ equal? should-inline? ] unit-test
[ f ] [ \ sequence \ hashcode* should-inline? ] unit-test
[ t ] [ \ array \ nth-unsafe should-inline? ] unit-test
[ t ] [ \ growable \ nth-unsafe should-inline? ] unit-test
[ t ] [ \ sbuf \ set-nth-unsafe should-inline? ] unit-test

! Regression
: lift-throw-tail-regression
    dup integer? [ "an integer" ] [
        dup string? [ "a string" ] [
            "error" throw
        ] if
    ] if ;

[ t ] [ \ lift-throw-tail-regression compiled? ] unit-test
[ 3 "an integer" ] [ 3 lift-throw-tail-regression ] unit-test
[ "hi" "a string" ] [ "hi" lift-throw-tail-regression ] unit-test

: lift-loop-tail-test-1 ( a quot -- )
    over even? [
        [ >r 3 - r> call ] keep lift-loop-tail-test-1
    ] [
        over 0 < [
            2drop
        ] [
            [ >r 2 - r> call ] keep lift-loop-tail-test-1
        ] if
    ] if ; inline

: lift-loop-tail-test-2
    10 [ ] lift-loop-tail-test-1 1 2 3 ;

[ 1 2 3 ] [ lift-loop-tail-test-2 ] unit-test

! Make sure we don't lose
GENERIC: generic-inline-test ( x -- y )
M: integer generic-inline-test ;

: generic-inline-test-1
    1
    generic-inline-test
    generic-inline-test
    generic-inline-test
    generic-inline-test
    generic-inline-test
    generic-inline-test
    generic-inline-test
    generic-inline-test
    generic-inline-test
    generic-inline-test ;

[ { t f } ] [
    \ generic-inline-test-1 word-def dataflow
    [ optimize-1 , optimize-1 , drop ] { } make
] unit-test

! Forgot a recursive inline check
: recursive-inline-hang ( a -- a )
    dup array? [ recursive-inline-hang ] when ;

HINTS: recursive-inline-hang array ;

: recursive-inline-hang-1
    { } recursive-inline-hang ;

[ t ] [ \ recursive-inline-hang-1 compiled? ] unit-test

DEFER: recursive-inline-hang-3

: recursive-inline-hang-2 ( a -- a )
    dup array? [ recursive-inline-hang-3 ] when ;

HINTS: recursive-inline-hang-2 array ;

: recursive-inline-hang-3 ( a -- a )
    dup array? [ recursive-inline-hang-2 ] when ;

HINTS: recursive-inline-hang-3 array ;


