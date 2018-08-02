USING: accessors compiler.units definitions eval kernel
tools.test vocabs vocabs.parser words ;
IN: vocabs.parser.tests

[ "FROM: kernel => doesnotexist ;" eval( -- ) ]
[ error>> T{ no-word-in-vocab { word "doesnotexist" } { vocab "kernel" } } = ]
must-fail-with

[ "RENAME: doesnotexist kernel => newname" eval( -- ) ]
[ error>> T{ no-word-in-vocab { word "doesnotexist" } { vocab "kernel" } } = ]
must-fail-with

: aaa ( -- ) ;

[
    [ ] [ "aaa" "vocabs.parser.tests" "uutt" add-renamed-word ] unit-test

    [ ] [ "vocabs.parser.tests" dup add-qualified ] unit-test

    [ aaa ] [ "uutt" search ] unit-test
    [ aaa ] [ "vocabs.parser.tests:aaa" search ] unit-test

    [ ] [ [ "bbb" "vocabs.parser.tests" create-word drop ] with-compilation-unit ] unit-test

    [ "bbb" ] [ "vocabs.parser.tests:bbb" search name>> ] unit-test

    [ ] [ [ \ aaa forget ] with-compilation-unit ] unit-test

    [ ] [ [ "bbb" "vocabs.parser.tests" lookup-word forget ] with-compilation-unit ] unit-test

    [ f ] [ "uutt" search ] unit-test

    [ f ] [ "vocabs.parser.tests:aaa" search ] unit-test

    [ ] [ "vocabs.parser.tests.foo" set-current-vocab ] unit-test

    [ ] [ [ "bbb" current-vocab create-word drop ] with-compilation-unit ] unit-test

    [ t ] [ "bbb" search >boolean ] unit-test

    [ ] [ [ "vocabs.parser.tests.foo" forget-vocab ] with-compilation-unit ] unit-test

    [ [ "bbb" current-vocab create-word drop ] with-compilation-unit ] [ error>> no-current-vocab-error? ] must-fail-with

    [ begin-private ] [ error>> no-current-vocab-error? ] must-fail-with

    [ end-private ] [ error>> no-current-vocab-error? ] must-fail-with

    [ f ] [ "bbb" search >boolean ] unit-test

] with-manifest
