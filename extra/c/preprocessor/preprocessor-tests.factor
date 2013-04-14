! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: tools.test c.preprocessor kernel accessors multiline
nested-comments ;
IN: c.preprocessor.tests

[ "vocab:c/tests/test1/test1.c" start-preprocess-file ]
[ include-nested-too-deeply? ] must-fail-with

[ "yo\n\n\n\nyo4\n" ]
[ "vocab:c/tests/test2/test2.c" start-preprocess-file nip ] unit-test

(*
[ "vocab:c/tests/test3/test3.c" start-preprocess-file ]
[ "\"BOO\"" = ] must-fail-with
*)

[ V{ "\"omg\"" "\"lol\"" } ]
[ "vocab:c/tests/test4/test4.c" start-preprocess-file drop warnings>> ] unit-test


(*
f(2 * (y+1)) + f(2 * (f(2 * (z[0])))) % f(2 * (0)) + t(1); 
f(2 * (2+(3,4)-0,1)) | f(2 * (~ 5)) & f(2 * (0,1))^m(0,1); 
int i[] = { 1, 23, 4, 5, }; 
char c[2][6] = { "hello", "" }; 
*)
