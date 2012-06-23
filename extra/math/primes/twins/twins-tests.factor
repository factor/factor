! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: tools.test ;

IN: math.primes.twins

{ { } } [ 3 twin-primes-upto ] unit-test
{ { V{ 3 5 } V{ 5 7 } V{ 11 13 } } } [ 13 twin-primes-upto ] unit-test

{ t } [ 3 5 twin-primes? ] unit-test
{ f } [ 2 4 twin-primes? ] unit-test
{ f } [ 3 7 twin-primes? ] unit-test
