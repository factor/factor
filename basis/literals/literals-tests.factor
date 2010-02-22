USING: kernel literals math tools.test ;
IN: literals.tests

<<
: six-six-six ( -- a b c ) 6 6 6 ;
>>

: five ( -- a ) 5 ;
: seven-eleven ( -- b c ) 7 11 ;

[ { 5 } ] [ { $ five } ] unit-test
[ { 7 11 } ] [ { $ seven-eleven } ] unit-test
[ { 6 6 6 } ] [ { $ six-six-six } ] unit-test

[ { 6 6 6 7 } ] [ { $ six-six-six 7 } ] unit-test

[ { 8 8 8 } ] [ { $[ six-six-six [ 2 + ] tri@ ] } ] unit-test

[ { 0.5 2.0 } ] [ { $[ 1.0 2.0 / ] 2.0 } ] unit-test

[ { 1.0 { 0.5 1.5 } 4.0 } ] [ { 1.0 { $[ 1.0 2.0 / ] 1.5 } $[ 2.0 2.0 * ] } ] unit-test

CONSTANT: constant-a 3

[ { 3 10 "ftw" } ] [ ${ constant-a 10 "ftw" } ] unit-test

: sixty-nine ( -- a b ) 6 9 ;

[ { 6 9 } ] [ ${ sixty-nine } ] unit-test
