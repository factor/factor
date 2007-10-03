USING: kernel math namespaces io tools.test sequences vectors
continuations debugger parser memory arrays words
kernel.private ;
IN: temporary

: (callcc1-test)
    swap 1- tuck swap ?push
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
        [
            6 "x" set "test-cc" get continue
        ] with-scope
    ] callcc0 "x" get 5 = ;

[ t ] [ 10 callcc1-test 10 reverse >vector = ] unit-test
[ t ] [ callcc-namespace-test ] unit-test

[ f ] [ [ ] catch ] unit-test

[ 5 ] [ [ 5 throw ] catch ] unit-test

[ t ] [
    [ "Hello" throw ] catch drop
    global [ error get ] bind
    "Hello" =
] unit-test

"!!! The following error is part of the test" print

[ ] [ [ 6 [ 12 [ "2 car" ] ] ] print-error ] unit-test

"!!! The following error is part of the test" print

[ [ "2 car" ] parse ] catch print-error

[ f throw ] unit-test-fails

! Weird PowerPC bug.
[ ] [
    [ "4" throw ] catch drop
    data-gc
    data-gc
] unit-test

[ f ] [ { } kernel-error? ] unit-test
[ f ] [ { "A" "B" } kernel-error? ] unit-test

! ! See how well callstack overflow is handled
! [ clear drop ] unit-test-fails
! 
! : callstack-overflow callstack-overflow f ;
! [ callstack-overflow ] unit-test-fails

: don't-compile-me { } [ ] each ;

: foo callstack "c" set 3 don't-compile-me ;
: bar 1 foo 2 ;

[ 1 3 2 ] [ bar ] unit-test

[ t ] [ \ bar word-def "c" get innermost-frame-quot = ] unit-test

[ 1 ] [ "c" get innermost-frame-scan ] unit-test
