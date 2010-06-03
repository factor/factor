USING: grouping tools.test kernel sequences arrays
math accessors ;
IN: grouping.tests

[ { 1 2 3 } 0 group ] must-fail

[ { "hell" "o wo" "rld" } ] [ "hello world" 4 group ] unit-test

[ { V{ "a" "b" } V{ 0 0 } } ] [
    V{ "a" "b" } clone 2 <groups>
    2 over set-length
    >array
] unit-test

[ 0 ] [ { } 2 <clumps> length ] unit-test
[ 0 ] [ { 1 } 2 <clumps> length ] unit-test
[ 1 ] [ { 1 2 } 2 <clumps> length ] unit-test
[ 2 ] [ { 1 2 3 } 2 <clumps> length ] unit-test

[ { } 2 <circular-clumps> length ] must-fail
[ { 1 } 2 <circular-clumps> length ] must-fail

[ 2 ] [ { 1 2 } 2 <circular-clumps> length ] unit-test
[ 3 ] [ { 1 2 3 } 2 <circular-clumps> length ] unit-test

[ { { 1 2 } { 2 1 }         } ] [ { 1 2   } 2 circular-clump ] unit-test
[ { { 1 2 } { 2 3 } { 3 1 } } ] [ { 1 2 3 } 2 circular-clump ] unit-test

[ 1 ] [ V{ } 2 <clumps> 0 over set-length seq>> length ] unit-test
[ 2 ] [ V{ } 2 <clumps> 1 over set-length seq>> length ] unit-test
[ 3 ] [ V{ } 2 <clumps> 2 over set-length seq>> length ] unit-test

[ { { 1 2 } { 2 3 } } ] [ { 1 2 3 } 2 <sliced-clumps> [ >array ] map ] unit-test

[ f ] [ [ { } { } "Hello" ] all-equal? ] unit-test
[ f ] [ [ { 2 } { } { } ] all-equal? ] unit-test
[ t ] [ [ ] all-equal? ] unit-test
[ t ] [ [ 1234 ] all-equal? ] unit-test
[ f ] [ [ 1.0 1 1 ] all-equal? ] unit-test
[ t ] [ { 1 2 3 4 } [ < ] monotonic? ] unit-test
[ f ] [ { 1 2 3 4 } [ > ] monotonic? ] unit-test

[ { 6 7 8 3 4 5 0 1 2 } ] [ 9 iota >array dup 3 <groups> reverse! drop ] unit-test
