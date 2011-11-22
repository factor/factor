USING: accessors alien arrays definitions generic assocs
hashtables io kernel math namespaces parser prettyprint
sequences strings tools.test vectors words quotations classes
classes.private classes.union classes.mixin classes.predicate
classes.algebra classes.union.private source-files
compiler.units kernel.private sorting vocabs io.streams.string
eval see math.private slots ;
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

[ [ drop f ] ] [ \ empty-union-1? def>> ] unit-test

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

[ t ] [ "blah" "classes.union.tests" lookup-word union-class? ] unit-test

[ t ] [ "foo?" "classes.union.tests" lookup-word predicate? ] unit-test

[ ] [ "IN: classes.union.tests USE: math UNION: blah integer ;" <string-reader> "union-reset-test" parse-stream drop ] unit-test

[ t ] [ "blah" "classes.union.tests" lookup-word union-class? ] unit-test

[ f ] [ "foo?" "classes.union.tests" lookup-word predicate? ] unit-test

GENERIC: test-generic ( x -- y )

TUPLE: a-tuple ;

UNION: a-union a-tuple ;

M: a-union test-generic ;

[ f ] [ \ test-generic "methods" word-prop assoc-empty? ] unit-test

[ ] [ [ \ a-tuple forget-class ] with-compilation-unit ] unit-test

[ t ] [ \ test-generic "methods" word-prop assoc-empty? ] unit-test

! Fast union predicates

[ t ] [ integer union-of-builtins? ] unit-test

[ t ] [ \ integer? def>> \ fixnum-bitand swap member? ] unit-test

[ ] [ "IN: classes.union.tests USE: math UNION: fast-union-1 fixnum ; UNION: fast-union-2 fast-union-1 bignum ;" eval( -- ) ] unit-test

[ t ] [ "fast-union-2?" "classes.union.tests" lookup-word def>> \ fixnum-bitand swap member? ] unit-test

[ ] [ "IN: classes.union.tests USE: vectors UNION: fast-union-1 vector ;" eval( -- ) ] unit-test

[ f ] [ "fast-union-2?" "classes.union.tests" lookup-word def>> \ fixnum-bitand swap member? ] unit-test

! Test maybe

[ t ] [ 3 maybe: integer instance? ] unit-test
[ t ] [ f maybe: integer instance? ] unit-test
[ f ] [ 3.0 maybe: integer instance? ] unit-test

TUPLE: maybe-integer-container { something maybe: integer } ;

[ f ] [ maybe-integer-container new something>> ] unit-test
[ 3 ] [ maybe-integer-container new 3 >>something something>> ] unit-test
[ maybe-integer-container new 3.0 >>something ] [ bad-slot-value? ] must-fail-with

TUPLE: self-pointer { next maybe: self-pointer } ;

[ T{ self-pointer { next T{ self-pointer } } } ]
[ self-pointer new self-pointer new >>next ] unit-test

[ t ] [ f maybe: f instance? ] unit-test

PREDICATE: natural < maybe: integer
    0 > ;

[ f ] [ -1 natural? ] unit-test
[ f ] [ 0 natural? ] unit-test
[ t ] [ 1 natural? ] unit-test

[ "USE: math maybe: maybe: integer" eval( -- obj ) ] [ error>> bad-slot-value? ] must-fail-with

INTERSECTION: only-f maybe: integer POSTPONE: f ;

[ t ] [ f only-f instance? ] unit-test
[ f ] [ t only-f instance? ] unit-test
[ f ] [ 30 only-f instance? ] unit-test

UNION: ?integer-float maybe: integer maybe: float ;

[ t ] [ 30 ?integer-float instance? ] unit-test
[ t ] [ 30.0 ?integer-float instance? ] unit-test
[ t ] [ f ?integer-float instance? ] unit-test
[ f ] [ t ?integer-float instance? ] unit-test
