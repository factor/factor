! Copyright (C) 2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: math.distances tools.test ;

IN: math.distances.tests

{ 1 } [ "hello" "jello" hamming-distance ] unit-test
