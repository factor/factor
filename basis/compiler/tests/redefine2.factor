IN: compiler.tests
USING: compiler compiler.units tools.test math parser kernel
sequences sequences.private classes.mixin generic definitions
arrays words assocs eval words.symbol ;

DEFER: redefine2-test

[ ] [ "USE: sequences USE: kernel IN: compiler.tests TUPLE: redefine2-test ; M: redefine2-test nth 2drop 3 ; INSTANCE: redefine2-test sequence" eval ] unit-test

[ t ] [ \ redefine2-test symbol? ] unit-test

[ t ] [ redefine2-test new sequence? ] unit-test

[ 3 ] [ 0 redefine2-test new nth-unsafe ] unit-test

[ ] [ [ redefine2-test sequence remove-mixin-instance ] with-compilation-unit ] unit-test

[ f ] [ redefine2-test new sequence? ] unit-test

[ 0 redefine2-test new nth-unsafe ] must-fail
