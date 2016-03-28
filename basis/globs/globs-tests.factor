USING: globs io.directories io.files.temp io.files.unique
io.pathnames literals sequences tools.test ;
IN: globs.tests

{ f } [ "abd" "fdf" glob-matches? ] unit-test
{ f } [ "fdsafas" "?" glob-matches? ] unit-test
{ t } [ "fdsafas" "*as" glob-matches? ] unit-test
{ t } [ "fdsafas" "*a*" glob-matches? ] unit-test
{ t } [ "fdsafas" "*a?" glob-matches? ] unit-test
{ t } [ "fdsafas" "*?" glob-matches? ] unit-test
{ f } [ "fdsafas" "*s?" glob-matches? ] unit-test
{ t } [ "a" "[abc]" glob-matches? ] unit-test
{ f } [ "a" "[^abc]" glob-matches? ] unit-test
{ t } [ "d" "[^abc]" glob-matches? ] unit-test
{ f } [ "foo.java" "*.{xml,txt}" glob-matches? ] unit-test
{ t } [ "foo.txt" "*.{xml,txt}" glob-matches? ] unit-test
{ t } [ "foo.xml" "*.{xml,txt}" glob-matches? ] unit-test
{ f } [ "foo." "*.{xml,txt}" glob-matches? ] unit-test
{ t } [ "foo." "*.{,xml,txt}" glob-matches? ] unit-test
{ t } [ "foo.{" "*.{" glob-matches? ] unit-test
{ t } [ "foo" "[a-z]oo" glob-matches? ] unit-test
{ f } [ "foo" "[g-z]oo" glob-matches? ] unit-test

{ f } [ "foo" "bar" append-path "*" glob-matches? ] unit-test
{ t } [ "foo" "bar" append-path "*" "*" append-path glob-matches? ] unit-test
{ f } [ "foo" "bar" append-path "foo?bar" glob-matches? ] unit-test
{ t } [ "foo" "bar" append-path "fo?" "bar" append-path glob-matches? ] unit-test

{ f } [ "foo" glob-pattern? ] unit-test
{ t } [ "fo?" glob-pattern? ] unit-test
{ t } [ "fo*" glob-pattern? ] unit-test
{ t } [ "fo[mno]" glob-pattern? ] unit-test
{ t } [ "fo\\*" glob-pattern? ] unit-test
{ t } [ "fo{o,bro}" glob-pattern? ] unit-test

{
    { "a" }
    { "a" "a/b" "a/b/c" "a/b/c/d" "a/b/h" "a/e" "a/e/g" }
    {
        "a" "a/b" "a/b/c" "a/b/c/d" "a/b/c/d/e" "a/b/c/f"
        "a/b/g" "a/b/h" "a/b/h/e" "a/e" "a/e/f" "a/e/g"
        "a/e/g/e"
    }
    {
        "a" "a/b" "a/b/c" "a/b/c/d" "a/b/c/d/e" "a/b/c/f"
        "a/b/g" "a/b/h" "a/b/h/e" "a/e" "a/e/f" "a/e/g"
        "a/e/g/e"
    }
    { "a/b" }
    { "a/b/c/d/e" "a/b/h/e" "a/e" "a/e/g/e" }
    ! { "a/b/c/d/e" "a/b/h/e" "a/e" "a/e/g/e" }
    ! { "a/b/c/d/e" "a/b/h/e" "a/e" "a/e/g/e" }
    { "a/e/f" "a/e/g" }
    { "a/b" "a/e" }
} [

    [
        [
            "a" make-directory
            "a/b" make-directory
            "a/b/c" make-directory
            "a/b/c/d" make-directory
            "a/b/c/d/e" touch-file
            "a/b/c/f" touch-file
            "a/b/g" touch-file
            "a/b/h" make-directory
            "a/b/h/e" touch-file
            "a/e" make-directory
            "a/e/f" touch-file
            "a/e/g" make-directory
            "a/e/g/e" touch-file

            "**" glob-directory
            "**/" glob-directory
            "**/*" glob-directory
            "**/**" glob-directory
            "**/b" glob-directory
            "**/e" glob-directory
            ! "**//e" glob-directory
            ! "**/**/e" glob-directory
            "**/e/**" glob-directory
            "a/**" glob-directory
        ] cleanup-unique-directory
    ] with-temp-directory
] unit-test
