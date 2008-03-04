USING: namespaces io tools.test threads kernel ;
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
