USING: grouping tools.test kernel sequences arrays ;
IN: grouping.tests

[ { 1 2 3 } 0 group ] must-fail

[ { "hell" "o wo" "rld" } ] [ "hello world" 4 group ] unit-test

[ { V{ "a" "b" } V{ f f } } ] [
    V{ "a" "b" } clone 2 <groups>
    2 over set-length
    >array
] unit-test
