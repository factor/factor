USING: sequences.interleaved strings tools.test ;

{ "" } [ "" CHAR: _ <interleaved> >string ] unit-test
{ "a" } [ "a" CHAR: _ <interleaved> >string ] unit-test
{ "a_b" } [ "ab" CHAR: _ <interleaved> >string ] unit-test
{ "a_b_c" } [ "abc" CHAR: _ <interleaved> >string ] unit-test
{ "a_b_c_d" } [ "abcd" CHAR: _ <interleaved> >string ] unit-test
