IN: scratchpad
USE: combinators
USE: kernel
USE: math
USE: stack
USE: test

[ slip ] unit-test-fails
[ 1 slip ] unit-test-fails
[ 1 2 slip ] unit-test-fails
[ 1 2 3 slip ] unit-test-fails

[ 5 ] [ [ 2 2 + ] 1 slip + ] unit-test
[ 6 ] [ [ 2 2 + ] 1 1 2slip + + ] unit-test
[ 6 ] [ [ 2 1 + ] 1 1 1 3slip + + + ] unit-test

[ [ ] keep ] unit-test-fails

[ 6 ] [ 2 [ sq ] keep + ] unit-test

[ cond ] unit-test-fails
[ [ [ 1 = ] [ ] ] cond ] unit-test-fails

[   ] [ 3 [ ] cond ] unit-test
[ t ] [ 4 [ [ 1 = ] [ ] [ 4 = ] [ drop t ] [ 2 = ] [ ] ] cond ] unit-test

[ 0 ] [ f [ sq ] [ 0 ] ifte* ] unit-test
[ 4 ] [ 2 [ sq ] [ 0 ] ifte* ] unit-test

[ 0 ] [ f [ 0 ] unless* ] unit-test
[ t ] [ t [ "Hello" ] unless* ] unit-test
