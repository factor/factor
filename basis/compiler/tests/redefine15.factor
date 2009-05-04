USING: compiler.units words tools.test math kernel ;
IN: compiler.tests.redefine15

DEFER: word-1

: word-2 ( a -- b ) word-1 ;

[ \ word-1 [ ] (( a -- b )) define-declared ] with-compilation-unit 

[ "a" ] [ "a" word-2 ] unit-test

: word-3 ( a -- b ) 1 + ;

: word-4 ( a -- b c ) 0 swap word-3 swap 1+ ;

[ 1 1 ] [ 0 word-4 ] unit-test

[ \ word-3 [ [ 2 + ] bi@ ] (( a b -- c d )) define-declared ] with-compilation-unit

[ 2 3 ] [ 0 word-4 ] unit-test
