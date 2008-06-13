IN: compiler.tests
USING: compiler compiler.units tools.test math parser kernel
sequences sequences.private classes.mixin generic definitions
arrays words assocs ;

DEFER: blah

[ ] [ "USE: sequences USE: kernel IN: compiler.tests TUPLE: blah ; M: blah nth 2drop 3 ; INSTANCE: blah sequence" eval ] unit-test

[ t ] [ blah new sequence? ] unit-test

[ 3 ] [ 0 blah new nth-unsafe ] unit-test

[ ] [ [ blah sequence remove-mixin-instance ] with-compilation-unit ] unit-test

[ f ] [ blah new sequence? ] unit-test

[ 0 blah new nth-unsafe ] must-fail
