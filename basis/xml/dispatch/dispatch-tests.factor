! Copyright (C) 2005, 2009 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
USING: xml io kernel math sequences strings xml.utilities
tools.test math.parser xml.dispatch ;
IN: xml.dispatch.tests

TAGS: calculate ( tag -- n )

: calc-2children ( tag -- n n )
    children-tags first2 [ calculate ] dip calculate ;

TAG: number calculate
    children>string string>number ;
TAG: add calculate
    calc-2children + ;
TAG: minus calculate
    calc-2children - ;
TAG: times calculate
    calc-2children * ;
TAG: divide calculate
    calc-2children / ;
TAG: neg calculate
    children-tags first calculate neg ;

: calc-arith ( string -- n )
    string>xml first-child-tag calculate ;

[ 32 ] [
    "<math><times><add><number>1</number><number>3</number></add><neg><number>-8</number></neg></times></math>"
    calc-arith
] unit-test

\ calc-arith must-infer
