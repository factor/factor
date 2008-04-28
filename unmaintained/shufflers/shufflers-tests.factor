USING: shufflers tools.test ;
IN: shufflers.tests

SHUFFLE: abcd 4
[ ] [ 1 2 3 4 abcd- ] unit-test
[ 1 2 1 2 ] [ 1 2 3 abc-abab ] unit-test
[ 4 3 2 1 ] [ 1 2 3 4 abcd-dcba ] unit-test
[ 1 1 1 1 ] [ 1 a-aaaa ] unit-test
