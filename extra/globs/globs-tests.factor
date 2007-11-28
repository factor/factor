IN: temporary
USING: tools.test globs ;

[ f ] [ "abd" "fdf" glob-matches? ] unit-test
[ f ] [ "fdsafas" "?" glob-matches? ] unit-test
[ t ] [ "fdsafas" "*as" glob-matches? ] unit-test
[ t ] [ "fdsafas" "*a*" glob-matches? ] unit-test
[ t ] [ "fdsafas" "*a?" glob-matches? ] unit-test
[ t ] [ "fdsafas" "*?" glob-matches? ] unit-test
[ f ] [ "fdsafas" "*s?" glob-matches? ] unit-test
[ t ] [ "a" "[abc]" glob-matches? ] unit-test
[ f ] [ "a" "[^abc]" glob-matches? ] unit-test
[ t ] [ "d" "[^abc]" glob-matches? ] unit-test
[ f ] [ "foo.java" "*.{xml,txt}" glob-matches? ] unit-test
[ t ] [ "foo.txt" "*.{xml,txt}" glob-matches? ] unit-test
[ t ] [ "foo.xml" "*.{xml,txt}" glob-matches? ] unit-test
[ f ] [ "foo." "*.{,xml,txt}" glob-matches? ] unit-test
[ t ] [ "foo.{" "*.{" glob-matches? ] unit-test
