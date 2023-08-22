! Copyright (C) 2015 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.error classes.tuple
compiler.units effects eval generic kernel tools.test words ;
IN: classes.error.tests

! Test error classes
ERROR: error-class-test a b c ;

{ "( a b c -- * )" } [ \ error-class-test stack-effect effect>string ] unit-test
{ f } [ \ error-class-test "inline" word-prop ] unit-test

[ "IN: classes.error.tests ERROR: error-x ; : error-x 3 ;" eval( -- ) ]
[ error>> error>> redefine-error? ] must-fail-with

DEFER: error-y

{ } [ [ \ error-y dup class? [ forget-class ] [ drop ] if ] with-compilation-unit ] unit-test

{ } [ "IN: classes.error.tests GENERIC: error-y ( a -- b )" eval( -- ) ] unit-test

{ f } [ \ error-y tuple-class? ] unit-test

{ f } [ \ error-y error-class? ] unit-test

{ t } [ \ error-y generic? ] unit-test

{ } [ "IN: classes.error.tests ERROR: error-y ;" eval( -- ) ] unit-test

{ t } [ \ error-y tuple-class? ] unit-test

{ t } [ \ error-y error-class? ] unit-test

{ f } [ \ error-y generic? ] unit-test

ERROR: base-error x y ;
ERROR: derived-error < base-error z ;

{ ( x y z -- * ) } [ \ derived-error stack-effect ] unit-test
