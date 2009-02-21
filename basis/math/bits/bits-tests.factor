! Copyright (C) 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test math.bits sequences arrays ;
IN: math.bits.tests

[ t ] [ BIN: 111111 3 <bits> second ] unit-test
[ { t t t } ] [ BIN: 111111 3 <bits> >array ] unit-test
[ f ] [ BIN: 111101 3 <bits> second ] unit-test
[ { f f t } ] [ BIN: 111100 3 <bits> >array ] unit-test
[ 3 ] [ BIN: 111111 3 <bits> length ] unit-test
[ 6 ] [ BIN: 111111 make-bits length ] unit-test
[ 0 ] [ 0 make-bits length ] unit-test
[ 2 ] [ 3 make-bits length ] unit-test
[ 2 ] [ -3 make-bits length ] unit-test
[ 1 ] [ 1 make-bits length ] unit-test
[ 1 ] [ -1 make-bits length ] unit-test
