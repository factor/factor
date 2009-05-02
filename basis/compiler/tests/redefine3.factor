IN: compiler.tests.redefine3
USING: accessors compiler compiler.units tools.test math parser
kernel sequences sequences.private classes.mixin generic
definitions arrays words assocs eval ;

GENERIC: sheeple ( obj -- x )

M: object sheeple drop "sheeple" ;

MIXIN: empty-mixin

M: empty-mixin sheeple drop "wake up" ;

: sheeple-test ( -- string ) { } sheeple ;

[ "sheeple" ] [ sheeple-test ] unit-test
[ t ] [ \ sheeple-test optimized? ] unit-test
[ t ] [ object \ sheeple method \ sheeple-test "compiled-uses" word-prop key? ] unit-test
[ f ] [ empty-mixin \ sheeple method \ sheeple-test "compiled-uses" word-prop key? ] unit-test

[ ] [ "IN: compiler.tests.redefine3 USE: arrays INSTANCE: array empty-mixin" eval( -- ) ] unit-test

[ "wake up" ] [ sheeple-test ] unit-test
[ f ] [ object \ sheeple method \ sheeple-test "compiled-uses" word-prop key? ] unit-test
[ t ] [ empty-mixin \ sheeple method \ sheeple-test "compiled-uses" word-prop key? ] unit-test

[ ] [ [ array empty-mixin remove-mixin-instance ] with-compilation-unit ] unit-test

[ "sheeple" ] [ sheeple-test ] unit-test
[ t ] [ \ sheeple-test optimized? ] unit-test
[ t ] [ object \ sheeple method \ sheeple-test "compiled-uses" word-prop key? ] unit-test
[ f ] [ empty-mixin \ sheeple method \ sheeple-test "compiled-uses" word-prop key? ] unit-test
