USING: kernel tools.test generic generic.standard ;
IN: classes.intersection.tests

TUPLE: a ;
TUPLE: a1 < a ; TUPLE: a2 < a ; TUPLE: a3 < a2 ;
MIXIN: b
INSTANCE: a3 b
INSTANCE: a1 b
INTERSECTION: c a2 b ;

GENERIC: x ( a -- b )

M: c x drop c ;
M: a x drop a ;

[ a ] [ T{ a } x ] unit-test
[ a ] [ T{ a1 } x ] unit-test
[ a ] [ T{ a2 } x ] unit-test

[ t ] [ T{ a3 } c? ] unit-test
[ t ] [ T{ a3 } \ x effective-method M\ c x eq? nip ] unit-test
[ c ] [ T{ a3 } x ] unit-test

! More complex case
TUPLE: t1 ;
TUPLE: t2 < t1 ; TUPLE: t3 < t1 ;
TUPLE: t4 < t2 ; TUPLE: t5 < t2 ;

UNION: m t4 t5 t3 ;
INTERSECTION: i t2 m ;

GENERIC: g ( a -- b )

M: i g drop i ;
M: t4 g drop t4 ;

[ t4 ] [ T{ t4 } g ] unit-test
[ i ] [ T{ t5 } g ] unit-test