! Copyright (C) 2011 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.algebra classes.algebra.private
classes.maybe eval generic.single kernel math slots tools.test ;
IN: classes.maybe.tests

{ t } [ 3 maybe{ integer } instance? ] unit-test
{ t } [ f maybe{ integer } instance? ] unit-test
{ f } [ 3.0 maybe{ integer } instance? ] unit-test

TUPLE: maybe-integer-container { something maybe{ integer } } ;

{ f } [ maybe-integer-container new something>> ] unit-test
{ 3 } [ maybe-integer-container new 3 >>something something>> ] unit-test
[ maybe-integer-container new 3.0 >>something ] [ bad-slot-value? ] must-fail-with

TUPLE: self-pointer { next maybe{ self-pointer } } ;

{ T{ self-pointer { next T{ self-pointer } } } }
[ self-pointer new self-pointer new >>next ] unit-test

{ t } [ f maybe{ POSTPONE: f } instance? ] unit-test

PREDICATE: natural < maybe{ integer }
    0 > ;

{ f } [ -1 natural? ] unit-test
{ f } [ 0 natural? ] unit-test
{ t } [ 1 natural? ] unit-test

{ t } [ f maybe{ maybe{ integer } } instance? ] unit-test
{ t } [ 3 maybe{ maybe{ integer } } instance? ] unit-test
{ f } [ 3.03 maybe{ maybe{ integer } } instance? ] unit-test

INTERSECTION: only-f maybe{ integer } POSTPONE: f ;

{ t } [ f only-f instance? ] unit-test
{ f } [ t only-f instance? ] unit-test
{ f } [ 30 only-f instance? ] unit-test

UNION: ?integer-float maybe{ integer } maybe{ float } ;

{ t } [ 30 ?integer-float instance? ] unit-test
{ t } [ 30.0 ?integer-float instance? ] unit-test
{ t } [ f ?integer-float instance? ] unit-test
{ f } [ t ?integer-float instance? ] unit-test

TUPLE: foo ;
GENERIC: lol ( obj -- string )
M: maybe{ foo } lol drop "lol" ;

{ "lol" } [ foo new lol ] unit-test
{ "lol" } [ f lol ] unit-test
[ 3 lol ] [ no-method? ] must-fail-with

TUPLE: foo2 a ;
GENERIC: lol2 ( obj -- string )
M: maybe{ foo } lol2 drop "lol2" ;
M: f lol2 drop "lol22" ;

{ "lol2" } [ foo new lol2 ] unit-test
{ "lol22" } [ f lol2 ] unit-test
[ 3 lol2 ] [ no-method? ] must-fail-with

[ "IN: classes-tests maybe{ 1 2 3 }" eval( -- ) ]
[ error>> not-an-instance? ] must-fail-with
