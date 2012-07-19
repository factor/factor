USING: namespaces io tools.test threads threads.private kernel
concurrency.combinators concurrency.promises locals math
words calendar sequences fry ;
IN: threads.tests

3 "x" set
[ 2 "x" set ] "Test" spawn drop
[ 2 ] [ yield "x" get ] unit-test
[ ] [ [ flush ] "flush test" spawn drop flush ] unit-test
[ ] [ [ "Errors, errors" throw ] "error test" spawn drop ] unit-test
yield

[ ] [ 0.3 sleep ] unit-test
[ "hey" sleep ] must-fail

[ 3 ] [ 3 self resume-with "Test suspend" suspend ] unit-test

[ f ] [ f get-global ] unit-test

{ { 0 3 6 9 12 15 18 21 24 27 } } [
    10 iota [
        0 "i" tset
        [
            "i" [ yield 3 + ] tchange
        ] times yield
        "i" tget
    ] parallel-map
] unit-test

:: spawn-namespace-test ( -- ? )
    <promise> :> p gensym :> g
    g "x" [
        [ "x" get p fulfill ] "B" spawn drop
    ] with-variable
    p ?promise g eq? ;

[ t ] [ spawn-namespace-test ] unit-test

[ "a" [ 1 1 + ] spawn 100 sleep ] must-fail

[ ] [ 0.1 seconds sleep ] unit-test

! Test thread-local variables
<promise> "p" set

5 "x" tset

[ 5 ] [ "x" tget ] unit-test

[ ] [ "x" [ 1 + ] tchange ] unit-test

[ 6 ] [ "x" tget ] unit-test

! Are they truly thread-local?
[ "x" tget "p" get fulfill ] in-thread

[ f ] [ "p" get ?promise ] unit-test

! Test system traps inside threads
[ ] [ [ dup ] in-thread yield ] unit-test

! The start-context-and-delete primitive wasn't rewinding the
! callstack properly.

! This got fixed for x86-64 but the problem remained on x86-32.

! The unit test asserts that the callstack is empty from the
! quotation passed to start-context-and-delete.

[ 3 ] [
    <promise> [
        '[
            _ [
                [ callstack swap fulfill stop ] start-context-and-delete
            ] start-context-and-delete
        ] in-thread
    ] [ ?promise callstack>array length ] bi
] unit-test
