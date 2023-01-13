USING: compiler.test compiler.units tools.test kernel kernel.private
sequences.private math.private math combinators strings alien
arrays memory vocabs parser eval quotations compiler.errors
definitions generic.single ;
IN: compiler.tests.simple

! Test empty word
{ } [ [ ] compile-call ] unit-test

! Test literals
{ 1 } [ [ 1 ] compile-call ] unit-test
{ 31 } [ [ 31 ] compile-call ] unit-test
{ 255 } [ [ 255 ] compile-call ] unit-test
{ -1 } [ [ -1 ] compile-call ] unit-test
{ 65536 } [ [ 65536 ] compile-call ] unit-test
{ -65536 } [ [ -65536 ] compile-call ] unit-test
{ "hey" } [ [ "hey" ] compile-call ] unit-test

! Calls
: no-op ( -- ) ;

{ } [ [ no-op ] compile-call ] unit-test
{ 3 } [ [ no-op 3 ] compile-call ] unit-test
{ 3 } [ [ 3 no-op ] compile-call ] unit-test

: bar ( -- value ) 4 ;

{ 4 } [ [ bar no-op ] compile-call ] unit-test
{ 4 3 } [ [ no-op bar 3 ] compile-call ] unit-test
{ 3 4 } [ [ 3 no-op bar ] compile-call ] unit-test

{ } [ no-op ] unit-test

! Conditionals

{ 1 } [ t [ [ 1 ] [ 2 ] if ] compile-call ] unit-test
{ 2 } [ f [ [ 1 ] [ 2 ] if ] compile-call ] unit-test
{ 1 3 } [ t [ [ 1 ] [ 2 ] if 3 ] compile-call ] unit-test
{ 2 3 } [ f [ [ 1 ] [ 2 ] if 3 ] compile-call ] unit-test

{ "hi" } [ 0 [ { [ "hi" ] [ "bye" ] } dispatch ] compile-call ] unit-test
{ "bye" } [ 1 [ { [ "hi" ] [ "bye" ] } dispatch ] compile-call ] unit-test

{ "hi" 3 } [ 0 [ { [ "hi" ] [ "bye" ] } dispatch 3 ] compile-call ] unit-test
{ "bye" 3 } [ 1 [ { [ "hi" ] [ "bye" ] } dispatch 3 ] compile-call ] unit-test

{ 4 1 } [ 0 [ { [ bar 1 ] [ 3 1 ] } dispatch ] compile-call ] unit-test
{ 3 1 } [ 1 [ { [ bar 1 ] [ 3 1 ] } dispatch ] compile-call ] unit-test
{ 4 1 3 } [ 0 [ { [ bar 1 ] [ 3 1 ] } dispatch 3 ] compile-call ] unit-test
{ 3 1 3 } [ 1 [ { [ bar 1 ] [ 3 1 ] } dispatch 3 ] compile-call ] unit-test

{ 2 3 } [ 1 [ { [ gc 1 ] [ gc 2 ] } dispatch 3 ] compile-call ] unit-test

! Labels

: recursive-test ( ? -- ) [ f recursive-test ] when ; inline recursive

{ } [ t [ recursive-test ] compile-call ] unit-test

{ } [ t recursive-test ] unit-test

! Make sure error reporting works

! [ [ dup ] compile-call ] must-fail
! [ [ drop ] compile-call ] must-fail

! Regression

[ [ get-callstack ] compile-call ] must-not-fail

! Regression

: empty ( -- ) ;

{ "b" } [ 1 [ empty { [ "a" ] [ "b" ] } dispatch ] compile-call ] unit-test

: dummy-if-1 ( -- ) t [ ] [ ] if ;

{ } [ dummy-if-1 ] unit-test

: dummy-if-2 ( -- ) f [ ] [ ] if ;

{ } [ dummy-if-2 ] unit-test

: dummy-if-3 ( -- n ) t [ 1 ] [ 2 ] if ;

{ 1 } [ dummy-if-3 ] unit-test

: dummy-if-4 ( -- n ) f [ 1 ] [ 2 ] if ;

{ 2 } [ dummy-if-4 ] unit-test

: dummy-if-5 ( -- n ) 0 dup 1 fixnum<= [ drop 1 ] [ ] if ;

{ 1 } [ dummy-if-5 ] unit-test

: dummy-if-6 ( n -- n )
    dup 1 fixnum<= [
        drop 1
    ] [
        1 fixnum- dup 1 fixnum- fixnum+
    ] if ;

{ 17 } [ 10 dummy-if-6 ] unit-test

: dead-code-rec ( -- obj )
    t [
        3.2
    ] [
        dead-code-rec
    ] if ;

{ 3.2 } [ dead-code-rec ] unit-test

: one-rec ( ? -- obj ) [ f one-rec ] [ "hi" ] if ;

{ "hi" } [ t one-rec ] unit-test

: after-if-test ( -- n )
    t [ ] [ ] if 5 ;

{ 5 } [ after-if-test ] unit-test

DEFER: countdown-b

: countdown-a ( n -- ) dup 0 eq? [ drop ] [ 1 fixnum- countdown-b ] if ;
: countdown-b ( n -- ) dup 0 eq? [ drop ] [ 1 fixnum- countdown-a ] if ;

{ } [ 10 countdown-b ] unit-test

: dummy-when-1 ( -- ) t [ ] when ;

{ } [ dummy-when-1 ] unit-test

: dummy-when-2 ( -- ) f [ ] when ;

{ } [ dummy-when-2 ] unit-test

: dummy-when-3 ( a -- b ) dup [ dup fixnum* ] when ;

{ 16 } [ 4 dummy-when-3 ] unit-test
{ f } [ f dummy-when-3 ] unit-test

: dummy-when-4 ( a b -- a b ) dup [ dup dup fixnum* fixnum* ] when swap ;

{ 64 f } [ f 4 dummy-when-4 ] unit-test
{ f t } [ t f dummy-when-4 ] unit-test

: dummy-when-5 ( a -- b ) f [ dup fixnum* ] when ;

{ f } [ f dummy-when-5 ] unit-test

: dummy-unless-1 ( -- ) t [ ] unless ;

{ } [ dummy-unless-1 ] unit-test

: dummy-unless-2 ( -- ) f [ ] unless ;

{ } [ dummy-unless-2 ] unit-test

: dummy-unless-3 ( a -- b ) dup [ drop 3 ] unless ;

{ 3 } [ f dummy-unless-3 ] unit-test
{ 4 } [ 4 dummy-unless-3 ] unit-test

! Test cond expansion
{ "even" } [
    [
        2 {
            { [ dup 2 mod 0 = ] [ drop "even" ] }
            { [ dup 2 mod 1 = ] [ drop "odd" ] }
        } cond
    ] compile-call
] unit-test

{ "odd" } [
    [
        3 {
            { [ dup 2 mod 0 = ] [ drop "even" ] }
            { [ dup 2 mod 1 = ] [ drop "odd" ] }
        } cond
    ] compile-call
] unit-test

{ "neither" } [
    [
        3 {
            { [ dup string? ] [ drop "string" ] }
            { [ dup float? ] [ drop "float" ] }
            { [ dup alien? ] [ drop "alien" ] }
            [ drop "neither" ]
        } cond
    ] compile-call
] unit-test

{ 3 } [
    [
        3 {
            { [ dup fixnum? ] [ ] }
            [ drop t ]
        } cond
    ] compile-call
] unit-test

GENERIC: single-combination-test ( obj1 obj2 -- obj )

M: object single-combination-test drop ;
M: f single-combination-test nip ;
M: array single-combination-test drop ;
M: integer single-combination-test drop ;

{ 2 3 } [ 2 3 t single-combination-test ] unit-test
{ 2 3 } [ 2 3 4 single-combination-test ] unit-test
{ 2 f } [ 2 3 f single-combination-test ] unit-test

DEFER: single-combination-test-2

: single-combination-test-4 ( obj -- obj )
    dup [ single-combination-test-2 ] when ;

: single-combination-test-3 ( obj -- obj )
    drop 3 ;

GENERIC: single-combination-test-2 ( obj -- obj )
M: object single-combination-test-2 single-combination-test-3 ;
M: f single-combination-test-2 single-combination-test-4 ;

{ 3 } [ t single-combination-test-2 ] unit-test
{ 3 } [ 3 single-combination-test-2 ] unit-test
{ f } [ f single-combination-test-2 ] unit-test

! Regression
{ 100 } [ [ 100 [ [ ] times ] keep ] compile-call ] unit-test

! Regression
10 [
    [ "compiler.tests.foo" forget-vocab ] with-compilation-unit
    { t } [
        "USING: prettyprint words accessors ;
        IN: compiler.tests.foo
        : (recursive) ( -- ) (recursive) (recursive) ; inline recursive
        : recursive ( -- ) (recursive) ;
        \\ (recursive) word-optimized?" eval( -- obj )
    ] unit-test
] times

! This should not compile
GENERIC: bad-effect-test ( a -- )
M: quotation bad-effect-test call ; inline
: bad-effect-test* ( -- ) [ 1 2 3 ] bad-effect-test ;

[ bad-effect-test* ] [ not-compiled? ] must-fail-with

! Don't want compiler error to stick around
{ } [ [ M\ quotation bad-effect-test forget ] with-compilation-unit ] unit-test

! Make sure time bombs literalize
[ [ \ + call ] compile-call ] [ no-method? ] must-fail-with
