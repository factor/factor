USING: kernel tools.test regexp2.backend regexp2 ;
IN: regexp2.parser

: test-regexp ( string -- )
    default-regexp parse-regexp ;

: test-regexp2 ( string -- regexp )
    default-regexp dup parse-regexp ;

[ "(" ] [ unmatched-parentheses? ] must-fail-with

[ ] [ "a|b" test-regexp ] unit-test
[ ] [ "a.b" test-regexp ] unit-test
[ ] [ "a|b|c" test-regexp ] unit-test
[ ] [ "abc|b" test-regexp ] unit-test
[ ] [ "a|bcd" test-regexp ] unit-test
[ ] [ "a|(b)" test-regexp ] unit-test
[ ] [ "(a)|b" test-regexp ] unit-test
[ ] [ "(a|b)" test-regexp ] unit-test
[ ] [ "((a)|(b))" test-regexp ] unit-test

[ ] [ "(?:a)" test-regexp ] unit-test
[ ] [ "(?i:a)" test-regexp ] unit-test
[ ] [ "(?-i:a)" test-regexp ] unit-test
[ "(?z:a)" test-regexp ] [ bad-option? ] must-fail-with
[ "(?-z:a)" test-regexp ] [ bad-option? ] must-fail-with

[ ] [ "(?=a)" test-regexp ] unit-test

[ ] [ "[abc]" test-regexp ] unit-test
[ ] [ "[a-c]" test-regexp ] unit-test
[ ] [ "[^a-c]" test-regexp ] unit-test
[ "[^]" test-regexp ] must-fail

[ ] [ "|b" test-regexp ] unit-test
[ ] [ "b|" test-regexp ] unit-test
[ ] [ "||" test-regexp ] unit-test
