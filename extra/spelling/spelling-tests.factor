USING: spelling tools.test memoize ;
IN: spelling.tests

MEMO: test-dictionary ( -- assoc )
    "vocab:spelling/test.txt" load-dictionary ;

: test-correct ( word -- word/f )
    test-dictionary (correct) ;

[ "government" ] [ "goverment" test-correct ] unit-test
[ "government" ] [ "govxernment" test-correct ] unit-test
[ "government" ] [ "govermnent" test-correct ] unit-test
[ "government" ] [ "govxermnent" test-correct ] unit-test
[ "government" ] [ "govyrmnent" test-correct ] unit-test
