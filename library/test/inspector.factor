IN: temporary
USING: kernel inspector math namespaces prettyprint test
sequences ;

V{ } clone inspector-stack set

[[ "hello" "world" ]] (inspect)

[ "hello" ] [ 0 inspector-slots get nth ] unit-test
[ "world" ] [ 1 inspector-slots get nth ] unit-test

[ 1 2 3 ] (inspect)
f (inspect)
\ + (inspect)
H{ } (inspect)
H{ } describe
