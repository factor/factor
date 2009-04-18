IN: compiler.tests
USING: io.streams.string kernel tools.test eval ;

: declaration-test-1 ( -- a ) 3 ; flushable

: declaration-test ( -- ) declaration-test-1 drop ;

[ "" ] [ [ declaration-test ] with-string-writer ] unit-test

[ ] [ "IN: compiler.tests USE: io : declaration-test-1 ( -- a ) \"X\" write f ;" eval( -- ) ] unit-test

[ "X" ] [ [ declaration-test ] with-string-writer ] unit-test
