USING: kernel literals math tools.test ;
IN: literals.tests

<<
: five 5 ;
: seven-eleven 7 11 ;
: six-six-six 6 6 6 ;
>>

[ { 5 } ] [ { $ five } ] unit-test
[ { 7 11 } ] [ { $ seven-eleven } ] unit-test
[ { 6 6 6 } ] [ { $ six-six-six } ] unit-test

[ { 8 8 8 } ] [ { $[ six-six-six [ 2 + ] tri@ ] } ] unit-test
