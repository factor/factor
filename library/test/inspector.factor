IN: temporary
USING: inspector math namespaces prettyprint test ;

[[ "hello" "world" ]] inspect

[ "hello" ] [ 0 get ] unit-test
[ "world" ] [ 1 get ] unit-test

[ 1 2 3 ] inspect
f inspect
\ + inspect
