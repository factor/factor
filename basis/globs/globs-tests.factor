USING: globs io.pathnames literals sequences tools.test ;
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

[ f ] [ "foo" glob-pattern? ] unit-test
[ t ] [ "fo?" glob-pattern? ] unit-test
[ t ] [ "fo*" glob-pattern? ] unit-test
[ t ] [ "fo[mno]" glob-pattern? ] unit-test
[ t ] [ "fo\\*" glob-pattern? ] unit-test
[ t ] [ "fo{o,bro}" glob-pattern? ] unit-test

${ { "foo" "bar" } path-separator join }
[ { "foo" "bar" "ba?" } path-separator join glob-parent-directory ] unit-test

[ "foo" ]
[ { "foo" "b?r" "bas" } path-separator join glob-parent-directory ] unit-test

[ "" ]
[ { "f*" "bar" "bas" } path-separator join glob-parent-directory ] unit-test
