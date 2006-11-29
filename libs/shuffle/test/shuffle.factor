USING: shuffle kernel math test ;

[ 2 3 4 1 ] [ 1 2 3 4 roll ] unit-test
[ 1 2 3 4 ] [ 2 3 4 1 -roll ] unit-test
[ 1 2 3 4 1 ] [ 1 2 3 4 reach ] unit-test
[ { 910 911 912 } ] [ 10 900 3 [ + + ] map-with2 ] unit-test
[ 8 ] [ 5 6 7 8 3nip ] unit-test
