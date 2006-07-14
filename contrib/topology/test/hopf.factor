IN: temporary
USING: topology hopf io test ;

SYMBOLS: x1 x2 x3 u ;

1 x1 deg=
1 x2 deg=
1 x3 deg=
2 u deg=

x1 x2 x3 h* h* u d=

[ "2x1.x2.x3.u\n" ] [ [ u u h* d h. ] string-out ] unit-test
