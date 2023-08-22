USING: accessors alien assocs classes classes.algebra
classes.predicate classes.union classes.union.private
compiler.units eval io.streams.string kernel math math.private
parser quotations see sequences slots strings tools.test words ;
IN: classes.union.tests

! DEFER: bah
! FORGET: bah
UNION: bah fixnum alien ;
{ bah } [ \ bah? "predicating" word-prop ] unit-test

{ "USING: alien math ;\nIN: classes.union.tests\nUNION: bah fixnum alien ;\n" }
[ [ \ bah see ] with-string-writer ] unit-test

! Test redefinition of classes
UNION: union-1 fixnum float ;

GENERIC: generic-update-test ( x -- y )

M: union-1 generic-update-test drop "union-1" ;

{ f } [ bignum union-1 class<= ] unit-test
{ t } [ union-1 number class<= ] unit-test
{ "union-1" } [ 1.0 generic-update-test ] unit-test

"IN: classes.union.tests USE: math USE: arrays UNION: union-1 rational array ;" eval( -- )

{ t } [ bignum union-1 class<= ] unit-test
{ f } [ union-1 number class<= ] unit-test
{ "union-1" } [ { 1.0 } generic-update-test ] unit-test

"IN: classes.union.tests USE: math PREDICATE: union-1 < integer even? ;" eval( -- )

{ f } [ union-1 union-class? ] unit-test
{ t } [ union-1 predicate-class? ] unit-test
{ "union-1" } [ 8 generic-update-test ] unit-test
[ -7 generic-update-test ] must-fail

! Empty unions were causing problems
GENERIC: empty-union-test ( obj -- obj )

UNION: empty-union-1 ;

M: empty-union-1 empty-union-test ;

UNION: empty-union-2 ;

M: empty-union-2 empty-union-test ;

{ [ drop f ] } [ \ empty-union-1? def>> ] unit-test

! Redefining a class didn't update containing unions
UNION: redefine-bug-1 fixnum ;

UNION: redefine-bug-2 redefine-bug-1 quotation ;

{ t } [ fixnum redefine-bug-2 class<= ] unit-test
{ t } [ quotation redefine-bug-2 class<= ] unit-test

{ } [ "IN: classes.union.tests USE: math UNION: redefine-bug-1 bignum ;" eval( -- ) ] unit-test

{ t } [ bignum redefine-bug-1 class<= ] unit-test
{ f } [ fixnum redefine-bug-2 class<= ] unit-test
{ t } [ bignum redefine-bug-2 class<= ] unit-test

! Too eager with reset-class

[ "IN: classes.union.tests SINGLETON: foo UNION: blah foo ;" <string-reader> "union-reset-test" parse-stream ] must-not-fail

{ t } [ "blah" "classes.union.tests" lookup-word union-class? ] unit-test

{ t } [ "foo?" "classes.union.tests" lookup-word predicate? ] unit-test

[ "IN: classes.union.tests USE: math UNION: blah integer ;" <string-reader> "union-reset-test" parse-stream ] must-not-fail

{ t } [ "blah" "classes.union.tests" lookup-word union-class? ] unit-test

{ f } [ "foo?" "classes.union.tests" lookup-word predicate? ] unit-test

GENERIC: test-generic ( x -- y )

TUPLE: a-tuple ;

UNION: a-union a-tuple ;

M: a-union test-generic ;

{ f } [ \ test-generic "methods" word-prop assoc-empty? ] unit-test

{ } [ [ \ a-tuple forget-class ] with-compilation-unit ] unit-test

{ t } [ \ test-generic "methods" word-prop assoc-empty? ] unit-test

! Fast union predicates

{ t } [ integer union-of-builtins? ] unit-test

{ t } [ \ integer? def>> \ fixnum-bitand swap member? ] unit-test

{ } [ "IN: classes.union.tests USE: math UNION: fast-union-1 fixnum ; UNION: fast-union-2 fast-union-1 bignum ;" eval( -- ) ] unit-test

{ t } [ "fast-union-2?" "classes.union.tests" lookup-word def>> \ fixnum-bitand swap member? ] unit-test

{ } [ "IN: classes.union.tests USE: vectors UNION: fast-union-1 vector ;" eval( -- ) ] unit-test

{ f } [ "fast-union-2?" "classes.union.tests" lookup-word def>> \ fixnum-bitand swap member? ] unit-test

{ { fixnum } } [
    "IN: classes.union.tests USE: math UNION: um fixnum ;" eval( -- )
    "um" "classes.union.tests" lookup-word "members" word-prop
] unit-test

! Test union{

TUPLE: stuff { a union{ integer string } } ;

{ 0 } [ stuff new a>> ] unit-test
{ 3 } [ stuff new 3 >>a a>> ] unit-test
{ "asdf" } [ stuff new "asdf" >>a a>> ] unit-test
[ stuff new 3.4 >>a a>> ] [ bad-slot-value? ] must-fail-with

TUPLE: things { a union{ integer float } } ;

{ 0 } [ stuff new a>> ] unit-test
{ 3 } [ stuff new 3 >>a a>> ] unit-test
{ "asdf" } [ stuff new "asdf" >>a a>> ] unit-test
[ stuff new 3.4 >>a a>> ] [ bad-slot-value? ] must-fail-with

PREDICATE: numba-ova-10 < union{ float integer }
    10 > ;

{ f } [ 100/3 numba-ova-10? ] unit-test
{ t } [ 100 numba-ova-10? ] unit-test
{ t } [ 100.0 numba-ova-10? ] unit-test
{ f } [ 5 numba-ova-10? ] unit-test
{ f } [ 5.75 numba-ova-10? ] unit-test

! Issue #420 lol
[ "IN: issue-420 UNION: omg omg ;" eval( -- ) ]
[ error>> cannot-reference-self? ] must-fail-with

IN: issue-420
UNION: a ;
UNION: b a ;

[ "IN: issue-420 UNION: a b ;" eval( -- ) ]
[ error>> cannot-reference-self? ] must-fail-with
