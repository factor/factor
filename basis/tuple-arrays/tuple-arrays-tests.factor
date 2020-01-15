USING: tuple-arrays sequences tools.test namespaces kernel
math accessors classes classes.tuple eval classes.struct ;
IN: tuple-arrays.tests

SYMBOL: mat
TUPLE: foo bar ; final
C: <foo> foo
TUPLE-ARRAY: foo

{ 2 } [ 2 <foo-array> dup mat set length ] unit-test
{ T{ foo } } [ mat get first ] unit-test
{ T{ foo f 2 } } [ T{ foo f 2 } 0 mat get [ set-nth ] keep first ] unit-test
{ t } [ { T{ foo f 1 } T{ foo f 2 } } >foo-array dup mat set foo-array? ] unit-test
{ T{ foo f 3 } t }
[ mat get [ bar>> 2 + <foo> ] map [ first ] keep foo-array? ] unit-test

{ 2 } [ 2 <foo-array> dup mat set length ] unit-test
{ T{ foo } } [ mat get first ] unit-test
{ T{ foo f 1 } } [ T{ foo f 1 } 0 mat get [ set-nth ] keep first ] unit-test

TUPLE: baz { bing integer } bong ; final
TUPLE-ARRAY: baz

{ 0 } [ 1 <baz-array> first bing>> ] unit-test
{ f } [ 1 <baz-array> first bong>> ] unit-test

TUPLE: broken x ; final
: broken ( -- ) ;

TUPLE-ARRAY: broken

{ 100 } [ 100 <broken-array> length ] unit-test

! Can't define a tuple array for a non-tuple class
[ "IN: tuple-arrays.tests USING: tuple-arrays words ; TUPLE-ARRAY: word" eval( -- ) ]
[ error>> not-an-instance? ]
must-fail-with

! Can't define a tuple array for a non-final class
TUPLE: non-final x ;

[ "IN: tuple-arrays.tests USE: tuple-arrays TUPLE-ARRAY: non-final" eval( -- ) ]
[ error>> not-final? ]
must-fail-with

! Empty tuple
TUPLE: empty-tuple ; final

TUPLE-ARRAY: empty-tuple

{ 100 } [ 100 <empty-tuple-array> length ] unit-test
{ T{ empty-tuple } } [ 100 <empty-tuple-array> first ] unit-test
{ } [ T{ empty-tuple } 100 <empty-tuple-array> set-first ] unit-test

! Changing a tuple into a struct shouldn't break the tuple array to the point
! of crashing Factor
TUPLE: tuple-to-struct x ; final

TUPLE-ARRAY: tuple-to-struct

{ f } [ tuple-to-struct struct-class? ] unit-test

! This shouldn't crash
{ } [
    "IN: tuple-arrays.tests
    USING: alien.c-types classes.struct ;
    STRUCT: tuple-to-struct { x int } ;"
    eval( -- )
] unit-test

{ t } [ tuple-to-struct struct-class? ] unit-test
