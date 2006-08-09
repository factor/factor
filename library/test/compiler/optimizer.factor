USING: arrays assembler compiler generic
hashtables inference kernel kernel-internals math
optimizer prettyprint sequences strings test vectors words
sequences-internals ;
IN: temporary

: kill-1
    [ 1 2 3 ] [ + ] over drop drop ; compiled

[ [ 1 2 3 ] ] [ kill-1 ] unit-test

: kill-2
    [ + ] [ 1 2 3 ] over drop nip ; compiled

[ [ 1 2 3 ] ] [ kill-2 ] unit-test

: kill-3
    [ + ] dup over 3drop ;

[ ] [ kill-3 ] unit-test

: kill-4
    [ 1 2 3 ] [ + ] [ - ] pick >r 2drop r> ; compiled

[ [ 1 2 3 ] [ 1 2 3 ] ] [ kill-4 ] unit-test

: kill-5
    [ + ] [ - ] [ 1 2 3 ] pick pick 2drop >r 2drop r> ; compiled

[ [ 1 2 3 ] ] [ kill-5 ] unit-test

: kill-6
    [ 1 2 3 ] [ 4 5 6 ] [ + ] pick >r drop r> ; compiled

[ [ 1 2 3 ] [ 4 5 6 ] [ 1 2 3 ] ] [ kill-6 ] unit-test

: subset? swap [ swap member? ] all-with? ;

: set= 2dup subset? >r swap subset? r> and ;

USE: optimizer

: kill-set dup live-values swap literals hash-diff ;

: kill-set=
    dataflow kill-set hash-keys [ value-literal ] map set= ;

: foo 1 2 3 ;

[ H{ } ] [ \ foo word-def dataflow kill-set ] unit-test

[ t ] [ [ [ 1 ] [ 2 ] ] [ [ 1 ] [ 2 ] if ] kill-set= ] unit-test

[ t ] [ [ [ 1 ] [ 2 ] ] [ [ 1 ] [ 2 ] if ] kill-set= ] unit-test


: literal-kill-test-1 4 cell 2 cells - ; compiled

[ 4 ] [ literal-kill-test-1 drop ] unit-test

: literal-kill-test-2 3 cell 2 cells - ; compiled

[ 3 ] [ literal-kill-test-2 drop ] unit-test

: literal-kill-test-3 10 3 /mod drop ; compiled

[ 3 ] [ literal-kill-test-3 ] unit-test

: literal-kill-test-4
    5 swap [ 3 ] [ dup ] if 2drop ; compiled

[ ] [ t literal-kill-test-4 ] unit-test
[ ] [ f literal-kill-test-4 ] unit-test

: literal-kill-test-5
    5 swap [ 5 ] [ dup ] if 2drop ; compiled

[ ] [ t literal-kill-test-5 ] unit-test
[ ] [ f literal-kill-test-5 ] unit-test

: literal-kill-test-6
    5 swap [ dup ] [ dup ] if 2drop ; compiled

[ ] [ t literal-kill-test-6 ] unit-test
[ ] [ f literal-kill-test-6 ] unit-test

[ t ] [ [
    5 [ dup ] [ dup ] ] \ literal-kill-test-6 word-def kill-set=
] unit-test

: literal-kill-test-7
    [ 1 2 3 ] >r + r> drop ; compiled

[ 4 ] [ 2 2 literal-kill-test-7 ] unit-test

: literal-kill-test-8
    dup [ >r dup slip r> literal-kill-test-8 ] [ 2drop ] if ; inline

[ t ] [
    [ [ ] swap literal-kill-test-8 ] dataflow
    live-values hash-values [ value? ] subset empty?
] unit-test

! Test method inlining
[ f ] [ fixnum { } min-class ] unit-test

[ string ] [
    \ string
    [ integer string array reversed sbuf
    slice vector quotation ]
    [ class-compare ] sort min-class
] unit-test

[ f ] [
    \ fixnum
    [ fixnum integer letter ]
    [ class-compare ] sort min-class
] unit-test

[ fixnum ] [
    \ fixnum
    [ fixnum integer object ]
    [ class-compare ] sort min-class
] unit-test

[ integer ] [
    \ fixnum
    [ integer float object ]
    [ class-compare ] sort min-class
] unit-test

[ object ] [
    \ word
    [ integer float object ]
    [ class-compare ] sort min-class
] unit-test

GENERIC: xyz
M: array xyz xyz ;

[ ] [ \ xyz compile ] unit-test

! Test predicate inlining
: pred-test-1
    dup fixnum? [
        dup integer? [ "integer" ] [ "nope" ] if
    ] [
        "not a fixnum"
    ] if ; compiled

[ 1 "integer" ] [ 1 pred-test-1 ] unit-test

TUPLE: pred-test ;

: pred-test-2
    dup tuple? [
        dup pred-test? [ "pred-test" ] [ "nope" ] if
    ] [
        "not a tuple"
    ] if ; compiled

[ T{ pred-test } "pred-test" ] [ T{ pred-test } pred-test-2 ] unit-test

: pred-test-3
    dup pred-test? [
        dup tuple? [ "pred-test" ] [ "nope" ] if
    ] [
        "not a tuple"
    ] if ; compiled

[ T{ pred-test } "pred-test" ] [ T{ pred-test } pred-test-3 ] unit-test

! : inline-test
!     "nom" = ; compiled
! 
! [ t ] [ "nom" inline-test ] unit-test
! [ f ] [ "shayin" inline-test ] unit-test
! [ f ] [ 3 inline-test ] unit-test

: fixnum-declarations >fixnum 24 shift 1234 bitxor ; compiled

[ ] [ 1000000 fixnum-declarations . ] unit-test

! regression

: literal-not-branch 0 not [ ] [ ] if ; compiled

[ ] [ literal-not-branch ] unit-test

! regression

: bad-kill-1 [ 3 f ] [ dup bad-kill-1 ] if ; inline
: bad-kill-2 bad-kill-1 drop ; compiled

[ 3 ] [ t bad-kill-2 ] unit-test

! regression
: (the-test) dup 0 > [ 1- (the-test) ] when ; inline
: the-test 2 dup (the-test) ; compiled

[ 2 0 ] [ the-test ] unit-test

! regression
: (double-recursion) ( start end -- )
    < [
        6 1 (double-recursion)
        3 2 (double-recursion)
    ] when ; inline

: double-recursion 0 2 (double-recursion) ; compiled

[ ] [ double-recursion ] unit-test

! regression
: double-label-1
    [ f double-label-1 ] [ swap nth-unsafe ] if ; inline
: double-label-2
    dup array? [ ] [ ] if 0 t double-label-1 ; compiled

[ 0 ] [ 10 double-label-2 ] unit-test

! regression
GENERIC: void-generic
: breakage "hi" void-generic ;
[ ] [ \ breakage compile ] unit-test
[ breakage ] unit-test-fails

! regression
: test-0 dup 0 = [ drop ] [ 1- test-0 ] if ; inline
: test-1 t [ test-0 ] [ delegate dup [ test-1 ] [ drop ] if ] if ; inline
: test-2 5 test-1 ; compiled

[ f ] [ f test-2 ] unit-test

: branch-fold-regression-0
    t [ ] [ 1+ branch-fold-regression-0 ] if ; inline

: branch-fold-regression-1
    10 branch-fold-regression-0 ; compiled

[ 10 ] [ branch-fold-regression-1 ] unit-test

! another regression
: constant-branch-fold-0 "hey" ; foldable
: constant-branch-fold-1 constant-branch-fold-0 "hey" = ; inline
[ 1 ] [ [ constant-branch-fold-1 [ 1 ] [ 2 ] if ] compile-1 ] unit-test
