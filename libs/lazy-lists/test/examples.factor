USING: lazy-examples lazy-lists test ;
IN: temporary

[ { 1 3 5 7 } ] [ 4 odds ltake list>array ] unit-test
[ { 0 1 4 9 16 } ] [ first-five-squares ] unit-test
[ { 2 3 5 7 11 13 17 19 23 29 } ] [ first-ten-primes ] unit-test
