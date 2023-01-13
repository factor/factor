USING: kernel tools.test eval words ;
IN: compiler.tests.redefine18

! Mixin bug found by Doug

GENERIC: g1 ( a -- b )
GENERIC: g2 ( a -- b )

MIXIN: c
SINGLETON: a
INSTANCE: a c

M: c g1 g2 ;
M: a g2 drop a ;

MIXIN: d
INSTANCE: d c

M: d g2 drop d ;

{ } [ "IN: compiler.tests.redefine18 SINGLETON: b INSTANCE: b d" eval( -- ) ] unit-test

{ d } [ "b" "compiler.tests.redefine18" lookup-word g1 ] unit-test

{ } [ "IN: compiler.tests.redefine18 FORGET: b" eval( -- ) ] unit-test
