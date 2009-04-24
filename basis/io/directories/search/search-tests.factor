USING: combinators.smart io.directories
io.directories.hierarchy io.directories.search io.files
io.files.unique io.pathnames kernel namespaces sequences
sorting strings tools.test ;
IN: io.directories.search.tests

[ t ] [
    [
        10 [ "io.paths.test" "gogogo" make-unique-file ] replicate
        current-temporary-directory get [ ] find-all-files
    ] cleanup-unique-directory [ natural-sort ] bi@ =
] unit-test

[ f ] [
    { "omg you shoudnt have a directory called this" "or this" }
    t
    [ "asdfasdfasdfasdfasdf" tail? ] find-in-directories
] unit-test

[ f ] [
    { } t [ "asdfasdfasdfasdfasdf" tail? ] find-in-directories
] unit-test

[ t ] [
    [
        current-temporary-directory get
        "the-head" unique-file drop t
        [ file-name "the-head" head? ] find-file string?
    ] cleanup-unique-directory
] unit-test

[ t ] [
    [ unique-directory unique-directory ] output>array
    [ [ "abcd" append-path touch-file ] each ]
    [ [ file-name "abcd" = ] find-all-in-directories length 2 = ]
    [ [ delete-tree ] each ] tri
] unit-test
