USING: accessors generic kernel math math.order slots tools.test ;
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

{ a } [ T{ a } x ] unit-test
{ a } [ T{ a1 } x ] unit-test
{ a } [ T{ a2 } x ] unit-test

{ t } [ T{ a3 } c? ] unit-test
{ t } [ T{ a3 } \ x effective-method M\ c x eq? nip ] unit-test
{ c } [ T{ a3 } x ] unit-test

! More complex case
TUPLE: t1 ;
TUPLE: t2 < t1 ; TUPLE: t3 < t1 ;
TUPLE: t4 < t2 ; TUPLE: t5 < t2 ;

UNION: m t4 t5 t3 ;
INTERSECTION: i t2 m ;

GENERIC: g ( a -- b )

M: i g drop i ;
M: t4 g drop t4 ;

{ t4 } [ T{ t4 } g ] unit-test
{ i } [ T{ t5 } g ] unit-test

PREDICATE: odd-integer < integer odd? ;

! [ "TUPLE: omg { a intersection{ fixnum odd-integer } initial: 2 } ;" eval( -- ) ]
! [ bad-initial-value? ] must-fail-with

TUPLE: omg { a intersection{ fixnum odd-integer } initial: 1 } ;

{ 1 } [ omg new a>> ] unit-test
{ 3 } [ omg new 3 >>a a>> ] unit-test
[ omg new 1.2 >>a a>> ] [ bad-slot-value? ] must-fail-with

PREDICATE: odd/float-between-10-20 < union{ odd-integer float }
    10 20 between? ;

{ t } [ 17 odd/float-between-10-20? ] unit-test
{ t } [ 17.4 odd/float-between-10-20? ] unit-test
{ f } [ 18 odd/float-between-10-20? ] unit-test
{ f } [ 5 odd/float-between-10-20? ] unit-test
{ f } [ 5.75 odd/float-between-10-20? ] unit-test
