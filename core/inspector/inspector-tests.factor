USING: kernel tools.test math namespaces prettyprint
sequences inspector io.streams.string ;
IN: temporary

[ 1 2 3 ] describe
f describe
\ + describe
H{ } describe
H{ } describe

[ "fixnum instance\n" ] [ [ 3 describe ] string-out ] unit-test
