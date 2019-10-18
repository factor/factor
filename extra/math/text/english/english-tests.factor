USING: math.functions math.text.english tools.test ;
IN: math.text.english.tests

[ "zero" ] [ 0 number>text ] unit-test
[ "twenty-one" ] [ 21 number>text ] unit-test
[ "one hundred" ] [ 100 number>text ] unit-test
[ "one hundred and one" ] [ 101 number>text ] unit-test
[ "one thousand and one" ] [ 1001 number>text ] unit-test
[ "one thousand, one hundred and one" ] [ 1101 number>text ] unit-test
[ "one million, one thousand and one" ] [ 1001001 number>text ] unit-test
[ "one million, one thousand, one hundred and one" ] [ 1001101 number>text ] unit-test
[ "one million, one hundred and eleven thousand, one hundred and eleven" ] [ 1111111 number>text ] unit-test
[ "one duotrigintillion" ] [ 10 99 ^ number>text ] unit-test

[ "negative one hundred and twenty-three" ] [ -123 number>text ] unit-test
