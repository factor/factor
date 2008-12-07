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
