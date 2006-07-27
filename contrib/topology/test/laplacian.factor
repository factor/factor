IN: temporary
USING: hopf kernel laplacian namespaces test topology ;

SYMBOLS: x y z ;

{ x y z } generators set

1 x deg=
1 y deg=
1 z deg=

[ t ] [ x star y z h* = ] unit-test
[ t ] [ y star z x h* = ] unit-test
[ t ] [ z star x y h* = ] unit-test
