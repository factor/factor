IN: compiler.tests.tuples
USING: kernel tools.test compiler.units compiler ;

TUPLE: color red green blue ;

[ T{ color f 1 2 3 } ]
[ 1 2 3 [ color boa ] compile-call ] unit-test

[ T{ color f f f f } ]
[ [ color new ] compile-call ] unit-test
