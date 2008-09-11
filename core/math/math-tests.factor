USING: kernel math namespaces make tools.test ;
IN: math.tests

[ ] [ 5 [ ] times ] unit-test
[ ] [ 0 [ ] times ] unit-test
[ ] [ -1 [ ] times ] unit-test

[ ] [ 5 [ drop ] each-integer ] unit-test
[ [ 0 1 2 3 4 ] ] [ [ 5 [ , ] each-integer ] [ ] make ] unit-test
[ [ ] ] [ [ -1 [ , ] each-integer ] [ ] make ] unit-test

[ f ] [ 1/0. fp-nan? ] unit-test
[ f ] [ -1/0. fp-nan? ] unit-test
[ t ] [ -0/0. fp-nan? ] unit-test

[ t ] [ 1/0. fp-infinity? ] unit-test
[ t ] [ -1/0. fp-infinity? ] unit-test
[ f ] [ -0/0. fp-infinity? ] unit-test
