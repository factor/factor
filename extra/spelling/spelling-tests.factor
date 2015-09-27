USING: kernel sequences spelling tools.test memoize ;
IN: spelling.tests

{ { "bc" "ac" "ab" } } [ "abc" deletes ] unit-test
{ { "bac" "acb" } } [ "abc" transposes ] unit-test
{ t } [ "a" replaces concat ALPHABET = ] unit-test
{ 104 } [ "abc" inserts length ] unit-test

MEMO: test-dictionary ( -- assoc )
    "vocab:spelling/test.txt" load-dictionary ;

: test-correct ( word -- word/f )
    test-dictionary (correct) ;

{ "government" } [ "goverment" test-correct ] unit-test
{ "government" } [ "govxernment" test-correct ] unit-test
{ "government" } [ "govermnent" test-correct ] unit-test
{ "government" } [ "govxermnent" test-correct ] unit-test
{ "government" } [ "govyrmnent" test-correct ] unit-test
