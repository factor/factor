! (c)2009 Joe Groff, see bsd license
USING: booleans tools.test ;
IN: booleans.tests

[ t ] [ t boolean? ] unit-test
[ t ] [ f boolean? ] unit-test
[ f ] [ 1 boolean? ] unit-test
