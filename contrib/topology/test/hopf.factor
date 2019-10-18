IN: temporary
USING: topology hopf io test ;

SYMBOLS: x1 x2 x3 u ;

1 x1 deg=
1 x2 deg=
1 x3 deg=
2 u deg=

x1 x2 x3 h* h* u d=

[ "2x1.x2.x3.u\n" ] [ [ u u h* d h. ] string-out ] unit-test

x1 x2 h* x3 d=
[ { 1 2 2 1 } ] [ { x1 x2 x3 } H* ] unit-test

SYMBOLS: x y z ;

1 x deg=
1 y deg=
1 z deg=
x y h* z d=
y z h* x d=
z x h* y d=

[ { 1 0 0 1 } ] [ { x y z } H* ] unit-test
