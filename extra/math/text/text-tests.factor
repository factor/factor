USING: math.functions math.text tools.test ;
IN: temporary

[ "Zero" ] [ 0 number>text ] unit-test
[ "Twenty-One" ] [ 21 number>text ] unit-test
[ "One Hundred" ] [ 100 number>text ] unit-test
[ "One Hundred and One" ] [ 101 number>text ] unit-test
[ "One Thousand and One" ] [ 1001 number>text ] unit-test
[ "One Thousand, One Hundred and One" ] [ 1101 number>text ] unit-test
[ "One Million, One Thousand and One" ] [ 1001001 number>text ] unit-test
[ "One Million, One Thousand, One Hundred and One" ] [ 1001101 number>text ] unit-test
[ "One Million, One Hundred and Eleven Thousand, One Hundred and Eleven" ] [ 1111111 number>text ] unit-test
[ "One Duotrigintillion" ] [ 10 99 ^ number>text ] unit-test

[ "Negative One Hundred and Twenty-Three" ] [ -123 number>text ] unit-test
