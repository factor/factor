USING: combinators.smart io.directories
io.directories.hierarchy io.directories.search io.files
io.files.unique io.pathnames kernel namespaces sequences
sorting strings tools.test ;
IN: io.directories.search.tests

{ t } [
    [
        [
            10 [ "io.paths.test" "gogogo" unique-file ] replicate
            "." [ ] find-all-files
        ] cleanup-unique-directory [ natural-sort ] same?
    ] with-temp-directory
] unit-test

{ f } [
    { "omg you shoudnt have a directory called this" "or this" }
    t
    [ "asdfasdfasdfasdfasdf" tail? ] find-in-directories
] unit-test

{ f } [
    { } t [ "asdfasdfasdfasdfasdf" tail? ] find-in-directories
] unit-test

{ t } [
    [
        [
            "the-head" "" unique-file drop
            "." t [ file-name "the-head" head? ] find-file string?
        ] cleanup-unique-directory
    ] with-temp-directory
] unit-test

{ t } [
    [
        [
            [ unique-directory unique-directory ] output>array
            [ [ "abcd" append-path touch-file ] each ]
            [ [ file-name "abcd" = ] find-all-in-directories length 2 = ]
            [ [ delete-tree ] each ] tri
        ] cleanup-unique-directory
    ] with-temp-directory
] unit-test

{ t } [
    "resource:core/math/integers/integers.factor"
    [ "math.factor" tail? ] find-up-to-root >boolean
] unit-test

{ f } [
    "resource:core/math/integers/integers.factor"
    [ drop f ] find-up-to-root
] unit-test
