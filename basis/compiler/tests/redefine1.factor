USING: accessors compiler compiler.units tools.test math parser
kernel sequences sequences.private classes.mixin generic
definitions arrays words assocs eval ;
IN: compiler.tests

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

[ t ] [ \ hey optimized>> ] unit-test
[ t ] [ \ there optimized>> ] unit-test
[ ] [ "IN: compiler.tests : hey ( -- ) 3 ;" eval ] unit-test
[ f ] [ \ hey optimized>> ] unit-test
[ f ] [ \ there optimized>> ] unit-test
[ ] [ "IN: compiler.tests : hey ( -- ) ;" eval ] unit-test
[ t ] [ \ there optimized>> ] unit-test

: good ( -- ) ;
: bad ( -- ) good ;
: ugly ( -- ) bad ;

[ t ] [ \ good optimized>> ] unit-test
[ t ] [ \ bad optimized>> ] unit-test
[ t ] [ \ ugly optimized>> ] unit-test

[ f ] [ \ good compiled-usage assoc-empty? ] unit-test

[ ] [ "IN: compiler.tests : good ( -- ) 3 ;" eval ] unit-test

[ f ] [ \ good optimized>> ] unit-test
[ f ] [ \ bad optimized>> ] unit-test
[ f ] [ \ ugly optimized>> ] unit-test

[ t ] [ \ good compiled-usage assoc-empty? ] unit-test

[ ] [ "IN: compiler.tests : good ( -- ) ;" eval ] unit-test

[ t ] [ \ good optimized>> ] unit-test
[ t ] [ \ bad optimized>> ] unit-test
[ t ] [ \ ugly optimized>> ] unit-test

[ f ] [ \ good compiled-usage assoc-empty? ] unit-test
