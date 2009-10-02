! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel random.sfmt sequences tools.test ;
IN: random.sfmt.tests

[ ] [ 100 <sfmt-19937> drop ] unit-test
[ 1096298955 ]
[ 100 <sfmt-19937> generate generate state>> first first ] unit-test
