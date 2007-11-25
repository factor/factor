USING: regexp tools.test ;
IN: regexp-tests

[ f ] [ "b" "a*" matches? ] unit-test
[ t ] [ "" "a*" matches? ] unit-test
[ t ] [ "a" "a*" matches? ] unit-test
[ t ] [ "aaaaaaa" "a*" matches? ] unit-test
[ f ] [ "ab" "a*" matches? ] unit-test

[ t ] [ "abc" "abc" matches? ] unit-test
[ t ] [ "a" "a|b|c" matches? ] unit-test
[ t ] [ "b" "a|b|c" matches? ] unit-test
[ t ] [ "c" "a|b|c" matches? ] unit-test
[ f ] [ "c" "d|e|f" matches? ] unit-test

[ f ] [ "aa" "a|b|c" matches? ] unit-test
[ f ] [ "bb" "a|b|c" matches? ] unit-test
[ f ] [ "cc" "a|b|c" matches? ] unit-test
[ f ] [ "cc" "d|e|f" matches? ] unit-test

[ f ] [ "" "a+" matches? ] unit-test
[ t ] [ "a" "a+" matches? ] unit-test
[ t ] [ "aa" "a+" matches? ] unit-test

[ t ] [ "" "a?" matches? ] unit-test
[ t ] [ "a" "a?" matches? ] unit-test
[ f ] [ "aa" "a?" matches? ] unit-test

[ f ] [ "" "." matches? ] unit-test
[ t ] [ "a" "." matches? ] unit-test
[ t ] [ "." "." matches? ] unit-test

[ f ] [ "" ".+" matches? ] unit-test
[ t ] [ "a" ".+" matches? ] unit-test
[ t ] [ "ab" ".+" matches? ] unit-test

[ t ] [ "" "a|b*|c+|d?" matches? ] unit-test
[ t ] [ "a" "a|b*|c+|d?" matches? ] unit-test
[ t ] [ "c" "a|b*|c+|d?" matches? ] unit-test
[ t ] [ "cc" "a|b*|c+|d?" matches? ] unit-test
[ f ] [ "ccd" "a|b*|c+|d?" matches? ] unit-test
[ t ] [ "d" "a|b*|c+|d?" matches? ] unit-test

[ t ] [ "foo" "foo|bar" matches? ] unit-test
[ t ] [ "bar" "foo|bar" matches? ] unit-test
[ f ] [ "foobar" "foo|bar" matches? ] unit-test

[ f ] [ "" "(a)" matches? ] unit-test
[ t ] [ "a" "(a)" matches? ] unit-test
[ f ] [ "aa" "(a)" matches? ] unit-test
[ t ] [ "aa" "(a*)" matches? ] unit-test

[ f ] [ "aababaaabbac" "(a|b)+" matches? ] unit-test
[ t ] [ "ababaaabba" "(a|b)+" matches? ] unit-test

[ f ] [ "" "a{1}" matches? ] unit-test
[ t ] [ "a" "a{1}" matches? ] unit-test
[ f ] [ "aa" "a{1}" matches? ] unit-test

[ f ] [ "a" "a{2,}" matches? ] unit-test
[ t ] [ "aaa" "a{2,}" matches? ] unit-test
[ t ] [ "aaaa" "a{2,}" matches? ] unit-test
[ t ] [ "aaaaa" "a{2,}" matches? ] unit-test

[ t ] [ "" "a{,2}" matches? ] unit-test
[ t ] [ "a" "a{,2}" matches? ] unit-test
[ t ] [ "aa" "a{,2}" matches? ] unit-test
[ f ] [ "aaa" "a{,2}" matches? ] unit-test
[ f ] [ "aaaa" "a{,2}" matches? ] unit-test
[ f ] [ "aaaaa" "a{,2}" matches? ] unit-test

[ f ] [ "" "a{1,3}" matches? ] unit-test
[ t ] [ "a" "a{1,3}" matches? ] unit-test
[ t ] [ "aa" "a{1,3}" matches? ] unit-test
[ t ] [ "aaa" "a{1,3}" matches? ] unit-test
[ f ] [ "aaaa" "a{1,3}" matches? ] unit-test

