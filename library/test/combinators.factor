IN: temporary
USE: kernel
USE: math
USE: test
USE: io
USE: prettyprint
USE: namespaces

[ slip ] unit-test-fails
[ 1 slip ] unit-test-fails
[ 1 2 slip ] unit-test-fails
[ 1 2 3 slip ] unit-test-fails

[ 5 ] [ [ 2 2 + ] 1 slip + ] unit-test

[ [ ] keep ] unit-test-fails

[ 6 ] [ 2 [ sq ] keep + ] unit-test

[ [ ] 2keep ] unit-test-fails
[ 1 [ ] 2keep ] unit-test-fails
[ 3 1 2 ] [ 1 2 [ 2drop 3 ] 2keep ] unit-test

[ 0 ] [ f [ sq ] [ 0 ] ifte* ] unit-test
[ 4 ] [ 2 [ sq ] [ 0 ] ifte* ] unit-test

[ 0 ] [ f [ 0 ] unless* ] unit-test
[ t ] [ t [ "Hello" ] unless* ] unit-test

[ "2\n" ] [ [ 1 2 [ . ] [ sq . ] ?ifte ] string-out ] unit-test
[ "9\n" ] [ [ 3 f [ . ] [ sq . ] ?ifte ] string-out ] unit-test

[ [ 9 8 7 6 5 4 3 2 1 ] ]
[ [ 10 [ , ] [ 1 - dup dup 0 = [ drop f ] when ] while ] make-list nip ]
unit-test
