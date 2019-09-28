USING: sequences.interleaved strings tools.test ;

{ "" } [ "" char: _ <interleaved> >string ] unit-test
{ "a" } [ "a" char: _ <interleaved> >string ] unit-test
{ "a_b" } [ "ab" char: _ <interleaved> >string ] unit-test
{ "a_b_c" } [ "abc" char: _ <interleaved> >string ] unit-test
{ "a_b_c_d" } [ "abcd" char: _ <interleaved> >string ] unit-test
