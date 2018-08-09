USING: sequences.interleaved strings tools.test ;

{ "" } [ "" ch'_ <interleaved> >string ] unit-test
{ "a" } [ "a" ch'_ <interleaved> >string ] unit-test
{ "a_b" } [ "ab" ch'_ <interleaved> >string ] unit-test
{ "a_b_c" } [ "abc" ch'_ <interleaved> >string ] unit-test
{ "a_b_c_d" } [ "abcd" ch'_ <interleaved> >string ] unit-test
