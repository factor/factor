USING: alien arrays definitions generic assocs hashtables io
kernel math namespaces parser prettyprint sequences strings
tools.test vectors words quotations classes
classes.private classes.union classes.mixin classes.predicate
classes.algebra vectors definitions source-files
compiler.units kernel.private sorting vocabs io.streams.string
eval see ;
IN: classes.union.tests

! DEFER: bah
! FORGET: bah
UNION: bah fixnum alien ;
[ bah ] [ \ bah? "predicating" word-prop ] unit-test

[ "USING: alien math ;\nIN: classes.union.tests\nUNION: bah fixnum alien ;\n" ]
[ [ \ bah see ] with-string-writer ] unit-test

! Test redefinition of classes
UNION: union-1 fixnum float ;

GENERIC: generic-update-test ( x -- y )

M: union-1 generic-update-test drop "union-1" ;

[ f ] [ bignum union-1 class<= ] unit-test
[ t ] [ union-1 number class<= ] unit-test
[ "union-1" ] [ 1.0 generic-update-test ] unit-test

"IN: classes.union.tests USE: math USE: arrays UNION: union-1 rational array ;" eval( -- )

[ t ] [ bignum union-1 class<= ] unit-test
[ f ] [ union-1 number class<= ] unit-test
[ "union-1" ] [ { 1.0 } generic-update-test ] unit-test

"IN: classes.union.tests USE: math PREDICATE: union-1 < integer even? ;" eval( -- )

[ f ] [ union-1 union-class? ] unit-test
[ t ] [ union-1 predicate-class? ] unit-test
[ "union-1" ] [ 8 generic-update-test ] unit-test
[ -7 generic-update-test ] must-fail

! Empty unions were causing problems
GENERIC: empty-union-test ( obj -- obj )

UNION: empty-union-1 ;

M: empty-union-1 empty-union-test ;

UNION: empty-union-2 ;

M: empty-union-2 empty-union-test ;

! Redefining a class didn't update containing unions
UNION: redefine-bug-1 fixnum ;

UNION: redefine-bug-2 redefine-bug-1 quotation ;

[ t ] [ fixnum redefine-bug-2 class<= ] unit-test
[ t ] [ quotation redefine-bug-2 class<= ] unit-test

[ ] [ "IN: classes.union.tests USE: math UNION: redefine-bug-1 bignum ;" eval( -- ) ] unit-test

[ t ] [ bignum redefine-bug-1 class<= ] unit-test
[ f ] [ fixnum redefine-bug-2 class<= ] unit-test
[ t ] [ bignum redefine-bug-2 class<= ] unit-test

! Too eager with reset-class

[ ] [ "IN: classes.union.tests SINGLETON: foo UNION: blah foo ;" <string-reader> "union-reset-test" parse-stream drop ] unit-test

[ t ] [ "blah" "classes.union.tests" lookup union-class? ] unit-test

[ t ] [ "foo?" "classes.union.tests" lookup predicate? ] unit-test

[ ] [ "IN: classes.union.tests USE: math UNION: blah integer ;" <string-reader> "union-reset-test" parse-stream drop ] unit-test

[ t ] [ "blah" "classes.union.tests" lookup union-class? ] unit-test

[ f ] [ "foo?" "classes.union.tests" lookup predicate? ] unit-test

GENERIC: test-generic ( x -- y )

TUPLE: a-tuple ;

UNION: a-union a-tuple ;

M: a-union test-generic ;

[ f ] [ \ test-generic "methods" word-prop assoc-empty? ] unit-test

[ ] [ [ \ a-tuple forget-class ] with-compilation-unit ] unit-test

[ t ] [ \ test-generic "methods" word-prop assoc-empty? ] unit-test
