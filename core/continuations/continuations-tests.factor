USING: accessors continuations debugger eval io kernel kernel.private
math math.ratios memory namespaces sequences tools.test vectors words
;
IN: continuations.tests

: (callcc1-test) ( n obj -- n' obj )
    [ 1 - dup ] dip ?push
    over 0 = [ "test-cc" get continue-with ] when
    (callcc1-test) ;

: callcc1-test ( x -- list )
    [
        "test-cc" set V{ } clone (callcc1-test)
    ] callcc1 nip ;

: callcc-namespace-test ( -- ? )
    [
        "test-cc" set
        5 "x" set
        H{ } clone [
            6 "x" set "test-cc" get continue
        ] with-variables
    ] callcc0 "x" get 5 = ;

{ t } [ 10 callcc1-test 10 <iota> reverse >vector = ] unit-test
{ t } [ callcc-namespace-test ] unit-test

[ 5 throw ] [ 5 = ] must-fail-with

{ t } [
    [ "Hello" throw ] ignore-errors
    error get-global
    "Hello" =
] unit-test

{ 4 f } [
    [ 20 5 / ] [ division-by-zero? ] ignore-error/f
    [ 20 0 / ] [ division-by-zero? ] ignore-error/f
] unit-test

"!!! The following error is part of the test" print

{ } [ [ 6 [ 12 [ "2 car" ] ] ] print-error ] unit-test

"!!! The following error is part of the test" print

{ } [ [ [ "2 car" ] eval ] try ] unit-test

[ f throw ] must-fail

! Weird PowerPC bug.
{ } [
    [ "4" throw ] ignore-errors
    gc
    gc
] unit-test

: don't-compile-me ( -- ) ;
: foo ( -- ) get-callstack "c" set don't-compile-me ;
: bar ( -- a b ) 1 foo 2 ;

<< { don't-compile-me foo bar } [ t "no-compile" set-word-prop ] each >>

{ 1 2 } [ bar ] unit-test

{ t } [ \ bar def>> "c" get innermost-frame-executing = ] unit-test

{ 1 } [ "c" get innermost-frame-scan ] unit-test

SYMBOL: always-counter
SYMBOL: error-counter

H{
    { always-counter 0 }
    { error-counter 0 }
} [

    [ ] [ always-counter inc ] [ error-counter inc ] cleanup

    [ 1 ] [ always-counter get ] unit-test
    [ 0 ] [ error-counter get ] unit-test

    [
        [ "a" throw ]
        [ always-counter inc ]
        [ error-counter inc ] cleanup
    ] [ "a" = ] must-fail-with

    [ 2 ] [ always-counter get ] unit-test
    [ 1 ] [ error-counter get ] unit-test

    [
        [ ]
        [ always-counter inc "a" throw ]
        [ error-counter inc ] cleanup
    ] [ "a" = ] must-fail-with

    [ 3 ] [ always-counter get ] unit-test
    [ 1 ] [ error-counter get ] unit-test
] with-variables

{ } [ [ return ] with-return ] unit-test

[ { } [ ] attempt-all ] [ attempt-all-error? ] must-fail-with

{ { 4 } } [ { 2 2 } [ + ] with-datastack ] unit-test

[ with-datastack ] must-infer
