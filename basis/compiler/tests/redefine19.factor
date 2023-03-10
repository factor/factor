USING: kernel classes.mixin compiler.units tools.test generic ;
IN: compiler.tests.redefine19

GENERIC: g ( a -- b )

MIXIN: m1 M: m1 g drop 1 ;
MIXIN: m2 M: m2 g drop 2 ;

TUPLE: c ;

INSTANCE: c m2

: foo ( -- b ) c new g ;

{ 2 } [ foo ] unit-test

{ } [ [ c m1 add-mixin-instance ] with-compilation-unit ] unit-test

{ { m2 m1 } } [ \ g dispatch-order ] unit-test

{ 1 } [ foo ] unit-test

{ } [ [ c m1 remove-mixin-instance ] with-compilation-unit ] unit-test
