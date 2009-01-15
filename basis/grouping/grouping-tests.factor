USING: grouping tools.test kernel sequences arrays ;
IN: grouping.tests

[ { 1 2 3 } 0 group ] must-fail

[ { "hell" "o wo" "rld" } ] [ "hello world" 4 group ] unit-test

[ { V{ "a" "b" } V{ 0 0 } } ] [
    V{ "a" "b" } clone 2 <groups>
    2 over set-length
    >array
] unit-test

[ { { 1 2 } { 2 3 } } ] [ { 1 2 3 } 2 <sliced-clumps> [ >array ] map ] unit-test

[ f ] [ [ { } { } "Hello" ] all-equal? ] unit-test
[ f ] [ [ { 2 } { } { } ] all-equal? ] unit-test
[ t ] [ [ ] all-equal? ] unit-test
[ t ] [ [ 1234 ] all-equal? ] unit-test
[ f ] [ [ 1.0 1 1 ] all-equal? ] unit-test
[ t ] [ { 1 2 3 4 } [ < ] monotonic? ] unit-test
[ f ] [ { 1 2 3 4 } [ > ] monotonic? ] unit-test
