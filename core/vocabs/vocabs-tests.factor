! Unit tests for vocabs vocabulary
USING: vocabs tools.test ;
IN: vocabs.tests

[ f ] [ "kernel" vocab-main ] unit-test

[ t ] [ "" "" child-vocab? ] unit-test
[ t ] [ "" "io.files" child-vocab? ] unit-test
[ t ] [ "io" "io.files" child-vocab? ] unit-test
[ f ] [ "io.files" "io" child-vocab? ] unit-test

[ t ] [ "io.files" "io" parent-vocab? ] unit-test
[ f ] [ "io" "io.files" parent-vocab? ] unit-test

[ "math" ] [ "resource:core/math" normalized-vocab-name ] unit-test
[ "math" ] [ "resource:core.math" normalized-vocab-name ] unit-test
[ "math" ] [ "math" normalized-vocab-name ] unit-test

[ "" ] [ "resource:core" normalized-vocab-name ] unit-test

