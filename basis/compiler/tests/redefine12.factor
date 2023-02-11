USING: kernel tools.test eval ;
IN: compiler.tests.redefine12

! A regression that came about when fixing the
! 'no method on classes-intersect?' bug

GENERIC: g ( a -- b )

M: object g drop t ;

: h ( a -- b ) dup [ g ] when ;

{ f } [ f h ] unit-test
{ t } [ "hi" h ] unit-test

TUPLE: jeah ;

{ } [ "USE: kernel IN: compiler.tests.redefine12 M: jeah g drop f ;" eval( -- ) ] unit-test

{ f } [ T{ jeah } h ] unit-test
