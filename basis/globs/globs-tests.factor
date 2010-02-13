USING: tools.test globs io.pathnames ;
IN: globs.tests

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
[ f ] [ "foo." "*.{xml,txt}" glob-matches? ] unit-test
[ t ] [ "foo." "*.{,xml,txt}" glob-matches? ] unit-test
[ t ] [ "foo.{" "*.{" glob-matches? ] unit-test

[ f ] [ "foo" "bar" append-path "*" glob-matches? ] unit-test
[ t ] [ "foo" "bar" append-path "*" "*" append-path glob-matches? ] unit-test
[ f ] [ "foo" "bar" append-path "foo?bar" glob-matches? ] unit-test
[ t ] [ "foo" "bar" append-path "fo?" "bar" append-path glob-matches? ] unit-test
