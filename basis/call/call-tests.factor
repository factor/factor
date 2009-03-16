! Copyright (C) 2009 Daniel Ehrenberg.
! See http://factorcode.org/license.txt for BSD license.
USING: math tools.test call call.private kernel accessors ;
IN: call.tests

[ 3 ] [ 1 2 [ + ] call( x y -- z ) ] unit-test
[ 1 2 [ + ] call( -- z ) ] must-fail
[ 1 2 [ + ] call( x y -- z a ) ] must-fail
[ 1 2 3 { 1 2 3 4 } ] [ 1 2 3 4 [ datastack nip ] call( x -- y ) ] unit-test
[ [ + ] call( x y -- z ) ] must-infer

[ 3 ] [ 1 2 \ + execute( x y -- z ) ] unit-test
[ 1 2 \ + execute( -- z ) ] must-fail
[ 1 2 \ + execute( x y -- z a ) ] must-fail
[ \ + execute( x y -- z ) ] must-infer

: compile-execute(-test-1 ( a b -- c ) \ + execute( a b -- c ) ;

[ t ] [ \ compile-execute(-test-1 optimized>> ] unit-test
[ 4 ] [ 1 3 compile-execute(-test-1 ] unit-test

: compile-execute(-test-2 ( a b w -- c ) execute( a b -- c ) ;

[ t ] [ \ compile-execute(-test-2 optimized>> ] unit-test
[ 4 ] [ 1 3 \ + compile-execute(-test-2 ] unit-test
[ 5 ] [ 1 4 \ + compile-execute(-test-2 ] unit-test
[ -3 ] [ 1 4 \ - compile-execute(-test-2 ] unit-test
[ 5 ] [ 1 4 \ + compile-execute(-test-2 ] unit-test

[ t ] [ \ + (( a b -- c )) execute-effect-unsafe? ] unit-test
[ t ] [ \ + (( a b c -- d e )) execute-effect-unsafe? ] unit-test
[ f ] [ \ + (( a b c -- d )) execute-effect-unsafe? ] unit-test
[ f ] [ \ call (( x -- )) execute-effect-unsafe? ] unit-test
