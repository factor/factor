IN: temporary
USING: kernel tools math namespaces prettyprint test
sequences inspector io ;

[ 1 2 3 ] describe
f describe
\ + describe
H{ } describe
H{ } describe

[ "an instance of the fixnum class\n" ] [ [ 3 describe ] string-out ] unit-test
