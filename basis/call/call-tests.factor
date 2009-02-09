! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math tools.test call kernel ;
IN: call.tests

[ 3 ] [ 1 2 [ + ] call( x y -- z ) ] unit-test
[ 1 2 [ + ] call( -- z ) ] must-fail
[ 1 2 [ + ] call( x y -- z a ) ] must-fail
[ 1 2 3 { 4 } ] [ 1 2 3 4 [ datastack nip ] call( x -- y ) ] unit-test
[ [ + ] call( x y -- z ) ] must-infer
