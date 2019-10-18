USING: kernel math namespaces tools.test ;
IN: temporary

[ ] [ 5 [ ] times ] unit-test
[ ] [ 0 [ ] times ] unit-test
[ ] [ -1 [ ] times ] unit-test

[ ] [ 5 [ drop ] each-integer ] unit-test
[ [ 0 1 2 3 4 ] ] [ [ 5 [ , ] each-integer ] [ ] make ] unit-test
[ [ ] ] [ [ -1 [ , ] each-integer ] [ ] make ] unit-test

