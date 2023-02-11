! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: tools.test c.preprocessor kernel accessors multiline ;
IN: c.preprocessor.tests

[ "vocab:c/tests/test1/test1.c" start-preprocess-file ]
[ include-nested-too-deeply? ] must-fail-with

{ "yo\n\n\n\nyo4\n" }
[ "vocab:c/tests/test2/test2.c" start-preprocess-file nip ] unit-test

/*
[ "vocab:c/tests/test3/test3.c" start-preprocess-file ]
[ "\"BOO\"" = ] must-fail-with
*/

{ V{ "\"omg\"" "\"lol\"" } }
[ "vocab:c/tests/test4/test4.c" start-preprocess-file drop warnings>> ] unit-test
