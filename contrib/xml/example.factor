! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
IN: xml-arith
USING: xml io kernel math sequences strings ;

PROCESS: calculate ( tag -- n )

: calc-2children ( tag -- n n )
    children-tags first2 >r calculate r> calculate ;

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

