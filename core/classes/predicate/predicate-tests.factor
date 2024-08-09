USING: accessors assocs classes classes.algebra compiler.units
eval generic.single kernel math strings tools.test words ;
IN: classes.predicate.tests

PREDICATE: negative < integer 0 < ;
PREDICATE: positive < integer 0 > ;

{ t } [ negative integer class< ] unit-test
{ t } [ positive integer class< ] unit-test
{ f } [ integer negative class< ] unit-test
{ f } [ integer positive class< ] unit-test
{ f } [ negative negative class< ] unit-test
{ f } [ positive negative class< ] unit-test

{ t } [ predicate{ integer [ 0 < ] } integer class< ] unit-test
{ t } [ predicate{ integer [ 0 > ] } integer class< ] unit-test
{ f } [ integer predicate{ integer [ 0 < ] } class< ] unit-test
{ f } [ integer predicate{ integer [ 0 > ] } class< ] unit-test
{ f } [ predicate{ integer [ 0 < ] } predicate{ integer [ 0 < ] } class< ] unit-test
{ f } [ predicate{ integer [ 0 > ] } predicate{ integer [ 0 < ] } class< ] unit-test

GENERIC: abs ( n -- n )
M: integer abs ;
M: negative abs -1 * ;
M: positive abs ;

{ 10 } [ -10 abs ] unit-test
{ 10 } [ 10 abs ] unit-test
{ 0 } [ 0 abs ] unit-test

GENERIC: anonymous-abs ( n -- n )
M: integer anonymous-abs ;
M: predicate{ integer [ 0 < ] } anonymous-abs -1 * ;
M: predicate{ integer [ 0 > ] } anonymous-abs ;

{ 10 } [ -10 anonymous-abs ] unit-test
{ 10 } [ 10 anonymous-abs ] unit-test
{ 0 } [ 0 anonymous-abs ] unit-test

! Bug report from Bruno Deferrari
TUPLE: tuple-a slot ;
TUPLE: tuple-b < tuple-a ;

PREDICATE: tuple-c < tuple-b slot>> ;

GENERIC: ptest ( tuple -- x )
M: tuple-a ptest drop tuple-a ;
M: tuple-c ptest drop tuple-c ;

{ tuple-a } [ tuple-b new ptest ] unit-test
{ tuple-c } [ tuple-b new t >>slot ptest ] unit-test

PREDICATE: tuple-d < tuple-a slot>> ;

GENERIC: ptest' ( tuple -- x )
M: tuple-a ptest' drop tuple-a ;
M: tuple-d ptest' drop tuple-d ;

{ tuple-a } [ tuple-b new ptest' ] unit-test
{ tuple-d } [ tuple-b new t >>slot ptest' ] unit-test

PREDICATE: bad-inheritance-predicate < string ;
[
    "IN: classes.predicate.tests PREDICATE: bad-inheritance-predicate < bad-inheritance-predicate ;" eval( -- )
] [ error>> bad-inheritance? ] must-fail-with

PREDICATE: bad-inheritance-predicate2 < string ;
PREDICATE: bad-inheritance-predicate3 < bad-inheritance-predicate2 ;
[
    "IN: classes.predicate.tests PREDICATE: bad-inheritance-predicate2 < bad-inheritance-predicate3 ;" eval( -- )
] [ error>> bad-inheritance? ] must-fail-with

! This must not fail
PREDICATE: tup < string ;
UNION: u tup ;

{ } [ "IN: classes.predicate.tests PREDICATE: u < tup ;" eval( -- ) ] unit-test

! Changing the metaclass of the predicate superclass should work
GENERIC: change-meta-test ( a -- b )

TUPLE: change-meta-test-class length ;

PREDICATE: change-meta-test-predicate < change-meta-test-class length>> 2 > ;

M: change-meta-test-predicate change-meta-test length>> ;

{ f } [ \ change-meta-test "methods" word-prop assoc-empty? ] unit-test

[ T{ change-meta-test-class f 0 } change-meta-test ] [ no-method? ] must-fail-with
{ 7 } [ T{ change-meta-test-class f 7 } change-meta-test ] unit-test

{ } [ "IN: classes.predicate.tests USE: arrays UNION: change-meta-test-class array ;" eval( -- ) ] unit-test

! Should not have changed
{ change-meta-test-class } [ change-meta-test-predicate superclass-of ] unit-test
[ { } change-meta-test ] [ no-method? ] must-fail-with
{ 4 } [ { 1 2 3 4 } change-meta-test ] unit-test

{ } [ [ \ change-meta-test-class forget-class ] with-compilation-unit ] unit-test

{ f } [ change-meta-test-predicate class? ] unit-test

{ t } [ \ change-meta-test "methods" word-prop assoc-empty? ] unit-test
