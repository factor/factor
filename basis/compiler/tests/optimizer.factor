USING: accessors arrays compiler.units generic hashtables
stack-checker kernel kernel.private math prettyprint sequences
sbufs strings tools.test vectors words sequences.private
quotations classes classes.algebra classes.tuple.private
continuations growable namespaces hints alien.accessors
compiler.tree.builder compiler.tree.optimizer sequences.deep
compiler ;
IN: optimizer.tests

GENERIC: xyz ( obj -- obj )
M: array xyz xyz ;

[ t ] [ \ xyz optimized>> ] unit-test

! Test predicate inlining
: pred-test-1 ( a -- b c )
    dup fixnum? [
        dup integer? [ "integer" ] [ "nope" ] if
    ] [
        "not a fixnum"
    ] if ;

[ 1 "integer" ] [ 1 pred-test-1 ] unit-test

TUPLE: pred-test ;

: pred-test-2 ( a -- b c )
    dup tuple? [
        dup pred-test? [ "pred-test" ] [ "nope" ] if
    ] [
        "not a tuple"
    ] if ;

[ T{ pred-test } "pred-test" ] [ T{ pred-test } pred-test-2 ] unit-test

: pred-test-3 ( a -- b c )
    dup pred-test? [
        dup tuple? [ "pred-test" ] [ "nope" ] if
    ] [
        "not a tuple"
    ] if ;

[ T{ pred-test } "pred-test" ] [ T{ pred-test } pred-test-3 ] unit-test

: inline-test ( a -- b )
    "nom" = ;

[ t ] [ "nom" inline-test ] unit-test
[ f ] [ "shayin" inline-test ] unit-test
[ f ] [ 3 inline-test ] unit-test

: fixnum-declarations ( a -- b ) >fixnum 24 shift 1234 bitxor ;

[ ] [ 1000000 fixnum-declarations . ] unit-test

! regression

: literal-not-branch ( -- ) 0 not [ ] [ ] if ;

[ ] [ literal-not-branch ] unit-test

! regression

: bad-kill-1 ( a b -- c d e ) [ 3 f ] [ dup bad-kill-1 ] if ; inline recursive
: bad-kill-2 ( a b -- c d ) bad-kill-1 drop ;

[ 3 ] [ t bad-kill-2 ] unit-test

! regression
: (the-test) ( x -- y ) dup 0 > [ 1- (the-test) ] when ; inline recursive
: the-test ( -- x y ) 2 dup (the-test) ;

[ 2 0 ] [ the-test ] unit-test

! regression
: (double-recursion) ( start end -- )
    < [
        6 1 (double-recursion)
        3 2 (double-recursion)
    ] when ; inline recursive

: double-recursion ( -- ) 0 2 (double-recursion) ;

[ ] [ double-recursion ] unit-test

! regression
: double-label-1 ( a b c -- d )
    [ f double-label-1 ] [ swap nth-unsafe ] if ; inline recursive

: double-label-2 ( a -- b )
    dup array? [ ] [ ] if 0 t double-label-1 ;

[ 0 ] [ 10 double-label-2 ] unit-test

! regression
GENERIC: void-generic ( obj -- * )
: breakage ( -- * ) "hi" void-generic ;
[ t ] [ \ breakage optimized>> ] unit-test
[ breakage ] must-fail

! regression
: branch-fold-regression-0 ( m -- n )
    t [ ] [ 1+ branch-fold-regression-0 ] if ; inline recursive

: branch-fold-regression-1 ( -- m )
    10 branch-fold-regression-0 ;

[ 10 ] [ branch-fold-regression-1 ] unit-test

! another regression
: constant-branch-fold-0 ( -- value ) "hey" ; foldable
: constant-branch-fold-1 ( -- ? ) constant-branch-fold-0 "hey" = ; inline
[ 1 ] [ [ constant-branch-fold-1 [ 1 ] [ 2 ] if ] compile-call ] unit-test

! another regression
: foo ( -- value ) f ;
: bar ( -- ? ) foo 4 4 = and ;
[ f ] [ bar ] unit-test

! compiling <tuple> with a non-literal class failed
: <tuple>-regression ( class -- tuple ) <tuple> ;

[ t ] [ \ <tuple>-regression optimized>> ] unit-test

GENERIC: foozul ( a -- b )
M: reversed foozul ;
M: integer foozul ;
M: slice foozul ;

[ t ] [
    reversed \ foozul specific-method
    reversed \ foozul method
    eq?
] unit-test

! regression
: constant-fold-2 ( -- value ) f ; foldable
: constant-fold-3 ( -- value ) 4 ; foldable

[ f t ] [
    [ constant-fold-2 constant-fold-3 4 = ] compile-call
] unit-test

: constant-fold-4 ( -- value ) f ; foldable
: constant-fold-5 ( -- value ) f ; foldable

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
USE: binary-search
USE: binary-search.private

: old-binsearch ( elt quot: ( -- ) seq -- elt quot i )
    dup length 1 <= [
        from>>
    ] [
        [ midpoint swap call ] 3keep roll dup zero?
        [ drop dup from>> swap midpoint@ + ]
        [ drop dup midpoint@ head-slice old-binsearch ] if
    ] if ; inline recursive

[ 10 ] [
    10 20 >vector <flat-slice>
    [ [ - ] swap old-binsearch ] compile-call 2nip
] unit-test

! Regression
: empty-compound ( -- ) ;

: node-successor-f-bug ( x -- * )
    [ 3 throw ] [ empty-compound ] compose [ 3 throw ] if ;

[ t ] [ \ node-successor-f-bug optimized>> ] unit-test

[ ] [ [ new ] build-tree optimize-tree drop ] unit-test

[ ] [ [ <tuple> ] build-tree optimize-tree drop ] unit-test

! Regression
: lift-throw-tail-regression ( obj -- obj str )
    dup integer? [ "an integer" ] [
        dup string? [ "a string" ] [
            "error" throw
        ] if
    ] if ;

[ t ] [ \ lift-throw-tail-regression optimized>> ] unit-test
[ 3 "an integer" ] [ 3 lift-throw-tail-regression ] unit-test
[ "hi" "a string" ] [ "hi" lift-throw-tail-regression ] unit-test

: lift-loop-tail-test-1 ( a quot: ( -- ) -- )
    over even? [
        [ [ 3 - ] dip call ] keep lift-loop-tail-test-1
    ] [
        over 0 < [
            2drop
        ] [
            [ [ 2 - ] dip call ] keep lift-loop-tail-test-1
        ] if
    ] if ; inline recursive

: lift-loop-tail-test-2 ( -- a b c )
    10 [ ] lift-loop-tail-test-1 1 2 3 ;

\ lift-loop-tail-test-2 must-infer

[ 1 2 3 ] [ lift-loop-tail-test-2 ] unit-test

! Forgot a recursive inline check
: recursive-inline-hang ( a -- a )
    dup array? [ recursive-inline-hang ] when ;

HINTS: recursive-inline-hang array ;

: recursive-inline-hang-1 ( -- a )
    { } recursive-inline-hang ;

[ t ] [ \ recursive-inline-hang-1 optimized>> ] unit-test

DEFER: recursive-inline-hang-3

: recursive-inline-hang-2 ( a -- a )
    dup array? [ recursive-inline-hang-3 ] when ;

HINTS: recursive-inline-hang-2 array ;

: recursive-inline-hang-3 ( a -- a )
    dup array? [ recursive-inline-hang-2 ] when ;

HINTS: recursive-inline-hang-3 array ;

! Regression
[ ] [ { 3append-as } compile ] unit-test

! Wow
: counter-example ( a b c d -- a' b' c' d' )
    dup 0 > [ 1 - [ rot 2 * ] dip counter-example ] when ; inline recursive

: counter-example' ( -- a' b' c' d' )
    1 2 3.0 3 counter-example ;

[ 2 4 6.0 0 ] [ counter-example' ] unit-test

: member-test ( obj -- ? ) { + - * / /i } member? ;

\ member-test must-infer
[ ] [ \ member-test build-tree-from-word optimize-tree drop ] unit-test
[ t ] [ \ + member-test ] unit-test
[ f ] [ \ append member-test ] unit-test

! Infinite expansion
TUPLE: cons car cdr ;

UNION: improper-list cons POSTPONE: f ;

PREDICATE: list < improper-list
    [ cdr>> list instance? ] [ t ] if* ;

[ t ] [
    T{ cons f 1 T{ cons f 2 T{ cons f 3 f } } }
    [ list instance? ] compile-call
] unit-test

! Regression
: interval-inference-bug ( obj -- obj x )
    dup "a" get { array-capacity } declare >=
    [ dup "b" get { array-capacity } declare >= [ 3 ] [ 4 ] if ] [ 5 ] if ;

\ interval-inference-bug must-infer

[ ] [ 1 "a" set 2 "b" set ] unit-test
[ 2 3 ] [ 2 interval-inference-bug ] unit-test
[ 1 4 ] [ 1 interval-inference-bug ] unit-test
[ 0 5 ] [ 0 interval-inference-bug ] unit-test

: aggressive-flush-regression ( a -- b )
    f over [ <array> drop ] dip 1 + ;

[ 1.0 aggressive-flush-regression drop ] must-fail

[ 1 [ "hi" + drop ] compile-call ] must-fail

[ "hi" f [ <array> drop ] compile-call ] must-fail

TUPLE: some-tuple x ;

: allot-regression ( a -- b )
    [ ] curry some-tuple boa ;

[ T{ some-tuple f [ 3 ] } ] [ 3 allot-regression ] unit-test

[ 1 ] [ B{ 0 0 0 0 } [ 0 alien-signed-4 1+ ] compile-call ] unit-test
[ 1 ] [ B{ 0 0 0 0 } [ 0 alien-unsigned-4 1+ ] compile-call ] unit-test
[ 1 ] [ B{ 0 0 0 0 0 0 0 0 } [ 0 alien-signed-8 1+ ] compile-call ] unit-test
[ 1 ] [ B{ 0 0 0 0 0 0 0 0 } [ 0 alien-unsigned-8 1+ ] compile-call ] unit-test
[ 1 ] [ B{ 0 0 0 0 0 0 0 0 } [ 0 alien-signed-cell 1+ ] compile-call ] unit-test
[ 1 ] [ B{ 0 0 0 0 0 0 0 0 } [ 0 alien-unsigned-cell 1+ ] compile-call ] unit-test

: deep-find-test ( seq -- ? ) [ 5 = ] deep-find ;

[ 5 ] [ { 1 2 { 3 { 4 5 } } } deep-find-test ] unit-test
[ f ] [ { 1 2 { 3 { 4 } } } deep-find-test ] unit-test

[ B{ 0 1 2 3 4 5 6 7 } ] [ [ 8 [ ] B{ } map-as ] compile-call ] unit-test

[ 0 ] [ 1234 [ { fixnum } declare -64 shift ] compile-call ] unit-test

! Loop detection problem found by doublec
SYMBOL: counter

DEFER: loop-bbb

: loop-aaa ( -- )
    counter inc counter get 2 < [ loop-bbb ] when ; inline recursive

: loop-bbb ( -- )
    [ loop-aaa ] with-scope ; inline recursive

: loop-ccc ( -- ) loop-bbb ;

[ 0 ] [ 0 counter set loop-ccc counter get ] unit-test

! Type inference issue
[ 4 3 ] [
    1 >bignum 2 >bignum
    [ { bignum integer } declare [ shift ] keep 1+ ] compile-call
] unit-test
