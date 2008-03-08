USING: kernel singleton tools.test ;
IN: singleton.tests

[ ] [ SINGLETON: bzzt ] unit-test
[ t ] [ bzzt bzzt? ] unit-test
[ t ] [ bzzt bzzt eq? ] unit-test
GENERIC: zammo ( obj -- )
[ ] [ M: bzzt zammo drop "yes!" ; ] unit-test
[ "yes!" ] [ bzzt zammo ] unit-test
