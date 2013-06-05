! Copyright (C) 2013 Loryn Jenkins.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.combinators 
    tools.test ;
IN: math.combinators.tests

[ 0 ] [ -3 [ drop 0 ] when-negative ] unit-test
[ -2 ] [ -3 [ 1 + ] when-negative ] unit-test
[ 2 ] [ 2 [ 0 ] when-negative ] unit-test

[ 0 ] [ 3 [ drop 0 ] when-positive ] unit-test
[ 4 ] [ 3 [ 1 + ] when-positive ] unit-test
[ -2 ] [ -2 [ 0 ] when-positive ] unit-test