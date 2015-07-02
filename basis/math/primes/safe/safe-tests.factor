! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: math.primes.safe math.primes.safe.private tools.test ;
IN: math.primes.safe.tests

[ 863 ] [ 862 next-safe-prime ] unit-test
[ f ] [ 862 safe-prime? ] unit-test
[ t ] [ 7 safe-prime? ] unit-test
[ f ] [ 31 safe-prime? ] unit-test
[ t ] [ 47 safe-prime-candidate? ] unit-test
[ t ] [ 47 safe-prime? ] unit-test
[ t ] [ 863 safe-prime? ] unit-test

[ 47 ] [ 31 next-safe-prime ] unit-test
