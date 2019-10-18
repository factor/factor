USING: io.encodings.ascii sequences strings io io.files accessors
tools.test kernel io.files.unique namespaces continuations
io.files.info io.pathnames io.directories ;
IN: io.files.unique.tests

[ 123 ] [
    "core" ".test" [
        [ [ 123 CHAR: a <string> ] dip ascii set-file-contents ]
        [ file-info size>> ] bi
    ] cleanup-unique-file
] unit-test

[ t ] [
    [ current-directory get file-info directory? ] cleanup-unique-directory
] unit-test

[ t ] [
    current-directory get
    [ [ "FAILDOG" throw ] cleanup-unique-directory ] [ drop ] recover
    current-directory get =
] unit-test

[ t ] [
    [
        "asdf" unique-file drop
        "asdf2" unique-file drop
        current-temporary-directory get directory-files length 2 =
    ] cleanup-unique-directory
] unit-test

[ t ] [
    [ ] with-unique-directory >boolean
] unit-test

[ t ] [
    [
        "asdf" unique-file drop
        "asdf" unique-file drop
        current-temporary-directory get directory-files length 2 =
    ] with-unique-directory drop
] unit-test
