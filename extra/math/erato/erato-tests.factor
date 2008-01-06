! Copyright (c) 2007 Samuel Tardieu.
! See http://factorcode.org/license.txt for BSD license.
USING: lazy-lists math.erato tools.test ;
IN: temporary

[ { 2 3 5 7 11 13 17 19 } ] [ 20 lerato list>array ] unit-test
