USING: arrays classes.mixin compiler.crossref compiler.units eval
generic kernel sequences tools.test words ;
IN: compiler.tests.redefine3

GENERIC: sheeple ( obj -- x )

M: object sheeple drop "sheeple" ; inline

MIXIN: empty-mixin

M: empty-mixin sheeple drop "wake up" ; inline

: sheeple-test ( -- string ) { } sheeple ;

: compiled-use? ( key word -- ? )
    load-dependencies member-eq? ;

{ "sheeple" } [ sheeple-test ] unit-test
{ t } [ \ sheeple-test word-optimized? ] unit-test
{ t } [ object \ sheeple lookup-method \ sheeple-test compiled-use? ] unit-test
{ f } [ empty-mixin \ sheeple lookup-method \ sheeple-test compiled-use? ] unit-test

{ } [ "IN: compiler.tests.redefine3 USE: arrays INSTANCE: array empty-mixin" eval( -- ) ] unit-test

{ "wake up" } [ sheeple-test ] unit-test
{ f } [ object \ sheeple lookup-method \ sheeple-test compiled-use? ] unit-test
{ t } [ empty-mixin \ sheeple lookup-method \ sheeple-test compiled-use? ] unit-test

{ } [ [ array empty-mixin remove-mixin-instance ] with-compilation-unit ] unit-test

{ "sheeple" } [ sheeple-test ] unit-test
{ t } [ \ sheeple-test word-optimized? ] unit-test
{ t } [ object \ sheeple lookup-method \ sheeple-test compiled-use? ] unit-test
{ f } [ empty-mixin \ sheeple lookup-method \ sheeple-test compiled-use? ] unit-test
