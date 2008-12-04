USING: io.encodings.ascii sequences strings io io.files accessors
tools.test kernel io.files.unique namespaces continuations ;
IN: io.files.unique.tests

[ 123 ] [
    "core" ".test" [
        [ [ 123 CHAR: a <repetition> ] dip ascii set-file-contents ]
        [ file-info size>> ] bi
    ] with-unique-file
] unit-test

[ t ] [
    [ current-directory get file-info directory? ] with-unique-directory
] unit-test

[ t ] [
    current-directory get
    [ [ "FAILDOG" throw ] with-unique-directory ] [ drop ] recover
    current-directory get =
] unit-test
