! (c) 2009 Joe Groff bsd license
USING: kernel math prettyprint prettyprint.callables
tools.test ;
IN: prettyprint.callables.tests

[ [ dip ] ] [ [ dip ] simplify-callable ] unit-test
[ [ [ + ] dip ] ] [ [ [ + ] dip ] simplify-callable ] unit-test
[ [ + 5 ] ] [ [ 5 [ + ] dip ] simplify-callable ] unit-test
[ [ + ] ] [ [ [ + ] call ] simplify-callable ] unit-test
[ [ call ] ] [ [ call ] simplify-callable ] unit-test
[ [ 5 + ] ] [ [ 5 [ + ] curry call ] simplify-callable ] unit-test
[ [ 4 5 + ] ] [ [ 4 5 [ + ] 2curry call ] simplify-callable ] unit-test
[ [ 4 5 6 + ] ] [ [ 4 5 6 [ + ] 3curry call ] simplify-callable ] unit-test
[ [ + . ] ] [ [ [ + ] [ . ] compose call ] simplify-callable ] unit-test
[ [ . + ] ] [ [ [ + ] [ . ] prepose call ] simplify-callable ] unit-test
