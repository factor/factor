USING: namespaces io tools.test threads kernel
concurrency.combinators concurrency.promises locals math
words ;
IN: threads.tests

3 "x" set
namespace [ [ yield 2 "x" set ] bind ] curry "Test" spawn drop
[ 2 ] [ yield "x" get ] unit-test
[ ] [ [ flush ] "flush test" spawn drop flush ] unit-test
[ ] [ [ "Errors, errors" throw ] "error test" spawn drop ] unit-test
yield

[ ] [ 0.3 sleep ] unit-test
[ "hey" sleep ] must-fail

[ 3 ] [
    [ 3 swap resume-with ] "Test suspend" suspend
] unit-test

[ f ] [ f get-global ] unit-test

{ { 0 3 6 9 12 15 18 21 24 27 } } [
    10 [
        0 "i" tset
        [
            "i" [ yield 3 + ] tchange
        ] times yield
        "i" tget
    ] parallel-map
] unit-test

[ [ 3 throw ] "A" suspend ] [ 3 = ] must-fail-with

:: spawn-namespace-test ( -- )
    [let | p [ <promise> ] g [ gensym ] |
        [
            g "x" set
            [ "x" get p fulfill ] "B" spawn drop
        ] with-scope
        p ?promise g eq?
    ] ;

[ t ] [ spawn-namespace-test ] unit-test
