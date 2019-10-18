! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test math.primes.lucas-lehmer ;
IN: math.primes.lucas-lehmer.tests

[ t ] [ 2 lucas-lehmer ] unit-test
[ t ] [ 3 lucas-lehmer ] unit-test
[ f ] [ 4 lucas-lehmer ] unit-test
[ t ] [ 5 lucas-lehmer ] unit-test
[ f ] [ 6 lucas-lehmer ] unit-test
[ f ] [ 11 lucas-lehmer ] unit-test
[ t ] [ 13 lucas-lehmer ] unit-test
[ t ] [ 61 lucas-lehmer ] unit-test
