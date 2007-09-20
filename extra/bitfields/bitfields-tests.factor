USING: tools.test bitfields kernel ;

SAFE-BITFIELD: foo bar:5 baz:10 111 bing:2 ;

[ 21 ] [ 21 852 3 <foo> foo-bar ] unit-test
[ 852 ] [ 21 852 3 <foo> foo-baz ] unit-test
[ 3 ] [ 21 852 3 <foo> foo-bing ] unit-test

[ 23 ] [ 21 852 3 <foo> 23 swap with-foo-bar foo-bar ] unit-test
[ 855 ] [ 21 852 3 <foo> 855 swap with-foo-baz foo-baz ] unit-test
[ 1 ] [ 21 852 3 <foo> 1 swap with-foo-bing foo-bing ] unit-test

[ 100 0 0 <foo> ] unit-test-fails
[ 0 5000 0 <foo> ] unit-test-fails
[ 0 0 10 <foo> ] unit-test-fails

[ 100 0 with-foo-bar ] unit-test-fails
[ 5000 0 with-foo-baz ] unit-test-fails
[ 10 0 with-foo-bing ] unit-test-fails

[ BIN: 00101100000000111111 ] [ BIN: 101 BIN: 1000000001 BIN: 11 <foo> ] unit-test
