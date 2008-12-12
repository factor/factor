USING: kernel literals tools.test ;
IN: literals.tests

<<
: five 5 ;
: seven-eleven 7 11 ;
: six-six-six 6 6 6 ;
>>

[ { 5 } ] [ { $ five } ] unit-test
[ { 7 11 } ] [ { $ seven-eleven } ] unit-test
[ { 6 6 6 } ] [ { $ six-six-six } ] unit-test
