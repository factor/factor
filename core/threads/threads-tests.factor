USING: namespaces io tools.test threads kernel ;
IN: temporary

3 "x" set
[ yield 2 "x" set ] in-thread
[ 2 ] [ yield "x" get ] unit-test
[ ] [ [ flush ] in-thread flush ] unit-test
[ ] [ [ "Errors, errors" throw ] in-thread ] unit-test
yield

[ ] [ 0.3 sleep ] unit-test
[ "hey" sleep ] unit-test-fails
