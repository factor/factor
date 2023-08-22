USING: kernel math.functions math.parser math.text.english
sequences tools.test ;

{ "zero" } [ 0 number>text ] unit-test
{ "twenty-one" } [ 21 number>text ] unit-test
{ "one hundred" } [ 100 number>text ] unit-test
{ "one hundred and one" } [ 101 number>text ] unit-test
{ "one thousand and one" } [ 1001 number>text ] unit-test
{ "one thousand, one hundred and one" } [ 1101 number>text ] unit-test
{ "one million, one thousand and one" } [ 1001001 number>text ] unit-test
{ "one million, one thousand, one hundred and one" } [ 1001101 number>text ] unit-test
{ "one million, one hundred and eleven thousand, one hundred and eleven" } [ 1111111 number>text ] unit-test
{ "one duotrigintillion" } [ 10 99 ^ number>text ] unit-test
{ "one noveducentillion" } [ 630 10^ number>text ] unit-test

{ "negative one hundred and twenty-three" } [ -123 number>text ] unit-test

{ "0th" } [ 0 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "1st" } [ 1 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "2nd" } [ 2 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "3rd" } [ 3 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "4th" } [ 4 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "5th" } [ 5 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "6th" } [ 6 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "7th" } [ 7 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "10th" } [ 10 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "11th" } [ 11 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "12th" } [ 12 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "13th" } [ 13 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "101st" } [ 101 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "110th" } [ 110 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "111th" } [ 111 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "112th" } [ 112 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "113th" } [ 113 [ number>string ] [ ordinal-suffix ] bi append ] unit-test

{ "-101st" } [ -101 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "-110th" } [ -110 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "-111th" } [ -111 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "-112th" } [ -112 [ number>string ] [ ordinal-suffix ] bi append ] unit-test
{ "-113th" } [ -113 [ number>string ] [ ordinal-suffix ] bi append ] unit-test

{ "th" } [ 13.5 ordinal-suffix ] unit-test
{ "th" } [ 9+1/3 ordinal-suffix ] unit-test
