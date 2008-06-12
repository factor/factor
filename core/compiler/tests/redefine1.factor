IN: compiler.tests
USING: compiler compiler.units tools.test math parser kernel
sequences sequences.private classes.mixin generic definitions
arrays words assocs ;

GENERIC: method-redefine-test ( a -- b )

M: integer method-redefine-test 3 + ;

: method-redefine-test-1 ( -- b ) 3 method-redefine-test ;

[ 6 ] [ method-redefine-test-1 ] unit-test

[ ] [ "IN: compiler.tests USE: math M: fixnum method-redefine-test 4 + ;" eval ] unit-test

[ 7 ] [ method-redefine-test-1 ] unit-test

[ ] [ [ fixnum \ method-redefine-test method forget ] with-compilation-unit ] unit-test

[ 6 ] [ method-redefine-test-1 ] unit-test

! Test ripple-up behavior
: hey ( -- ) ;
: there ( -- ) hey ;

[ t ] [ \ hey compiled? ] unit-test
[ t ] [ \ there compiled? ] unit-test
[ ] [ "IN: compiler.tests : hey ( -- ) 3 ;" eval ] unit-test
[ f ] [ \ hey compiled? ] unit-test
[ f ] [ \ there compiled? ] unit-test
[ ] [ "IN: compiler.tests : hey ( -- ) ;" eval ] unit-test
[ t ] [ \ there compiled? ] unit-test

! Just changing the stack effect didn't mark a word for recompilation
DEFER: change-effect

[ ] [ "IN: compiler.tests GENERIC: change-effect ( a -- b )" eval ] unit-test
{ 1 1 } [ change-effect ] must-infer-as

[ ] [ "IN: compiler.tests GENERIC: change-effect ( a -- )" eval ] unit-test
{ 1 0 } [ change-effect ] must-infer-as

: good ( -- ) ;
: bad ( -- ) good ;
: ugly ( -- ) bad ;

[ t ] [ \ good compiled? ] unit-test
[ t ] [ \ bad compiled? ] unit-test
[ t ] [ \ ugly compiled? ] unit-test

[ f ] [ \ good compiled-usage assoc-empty? ] unit-test

[ ] [ "IN: compiler.tests : good ( -- ) 3 ;" eval ] unit-test

[ f ] [ \ good compiled? ] unit-test
[ f ] [ \ bad compiled? ] unit-test
[ f ] [ \ ugly compiled? ] unit-test

[ t ] [ \ good compiled-usage assoc-empty? ] unit-test

[ ] [ "IN: compiler.tests : good ( -- ) ;" eval ] unit-test

[ t ] [ \ good compiled? ] unit-test
[ t ] [ \ bad compiled? ] unit-test
[ t ] [ \ ugly compiled? ] unit-test

[ f ] [ \ good compiled-usage assoc-empty? ] unit-test
