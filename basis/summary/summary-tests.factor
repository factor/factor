USING: summary tools.test ;
IN: summary.tests

{ "string with 5 elements" } [ "hello" summary ] unit-test
{ "hash-set with 3 members" } [ HS{ 1 2 3 } summary ] unit-test
