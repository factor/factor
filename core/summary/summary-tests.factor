USING: combinators continuations kernel summary tools.test ;
IN: summary.tests

{ "array with 2 elements" } [ { 1 2 } summary ] unit-test
{ "string with 5 code points" } [ "hello" summary ] unit-test
{ "hash-set with 3 members" } [ HS{ 1 2 3 } summary ] unit-test
{ "hashtable with 1 entries" } [ H{ { 3 4 } } summary ] unit-test
{ "Quotation's stack effect does not match call site" } [
    [ [ ] f wrong-values ] [ ] recover summary
] unit-test

TUPLE: ooga-booga ;
{ "ooga-booga" } [ ooga-booga boa summary ] unit-test
