! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors calendar combinators.short-circuit
constructors eval kernel math strings tools.test ;
IN: constructors.tests

TUPLE: stock-spread stock spread timestamp ;

CONSTRUCTOR: <stock-spread> stock-spread ( stock spread -- stock-spread )
    now >>timestamp ;

SYMBOL: AAPL

{ t } [
    AAPL 1234 <stock-spread>
    {
        [ stock>> AAPL eq? ]
        [ spread>> 1234 = ]
        [ timestamp>> timestamp? ]
    } 1&&
] unit-test

TUPLE: ct1 a ;
TUPLE: ct2 < ct1 b ;
TUPLE: ct3 < ct2 c ;
TUPLE: ct4 < ct3 d ;

CONSTRUCTOR: <ct1> ct1 ( a -- obj ) ;

CONSTRUCTOR: <ct2> ct2 ( a b -- obj ) ;

CONSTRUCTOR: <ct3> ct3 ( a b c -- obj ) ;

CONSTRUCTOR: <ct4> ct4 ( a b c d -- obj ) ;

{ 1000 } [ 1000 <ct1> a>> ] unit-test
{ 0 } [ 0 0 <ct2> a>> ] unit-test
{ 0 } [ 0 0 0 <ct3> a>> ] unit-test
{ 0 } [ 0 0 0 0 <ct4> a>> ] unit-test


TUPLE: monster
    { name string read-only } { hp integer } { max-hp integer read-only }
    { computed integer read-only }
    lots of extra slots that make me not want to use boa, maybe they get set later
    { stop initial: 18 } ;

TUPLE: a-monster < monster ;

TUPLE: b-monster < monster ;

<<
SLOT-CONSTRUCTOR: a-monster
>>

: <a-monster> ( name hp max-hp -- obj )
    2dup +
    a-monster( name hp max-hp computed ) ;

: <b-monster> ( name hp max-hp -- obj )
    2dup +
    { "name" "hp" "max-hp" "computed" } \ b-monster slots>boa ;

{ 20 } [ "Norm" 10 10 <a-monster> computed>> ] unit-test
{ 18 } [ "Norm" 10 10 <a-monster> stop>> ] unit-test

{ 22 } [ "Phil" 11 11 <b-monster> computed>> ] unit-test
{ 18 } [ "Phil" 11 11 <b-monster> stop>> ] unit-test

[
    "USE: constructors
IN: constructors.tests
TUPLE: foo a b ;
CONSTRUCTOR: <foo> foo ( a a -- obj )" eval( -- )
] [
    error>> repeated-constructor-parameters?
] must-fail-with

[
    "USE: constructors
IN: constructors.tests
TUPLE: foo a b ;
CONSTRUCTOR: <foo> foo ( a c -- obj )" eval( -- )
] [
    error>> unknown-constructor-parameters?
] must-fail-with
