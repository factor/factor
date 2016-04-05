USING: combinators io.directories io.directories.hierarchy
io.directories.search io.files.unique io.pathnames kernel
sequences sorting strings tools.test ;

{ t } [
    [
        10 [ "io.paths.test" "gogogo" unique-file ] replicate
        "." [ ] find-all-files [ natural-sort ] same?
    ] with-test-directory
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
        "the-head" "" unique-file drop
        "." t [ file-name "the-head" head? ] find-file string?
    ] with-test-directory
] unit-test

{ t } [
    [
        { "foo" "bar" } {
            [ [ make-directory ] each ]
            [ [ "abcd" append-path touch-file ] each ]
            [ [ file-name "abcd" = ] find-all-in-directories length 2 = ]
            [ [ delete-tree ] each ]
        } cleave
    ] with-test-directory
] unit-test

{ t } [
    "resource:core/math/integers/integers.factor"
    [ "math.factor" tail? ] find-up-to-root >boolean
] unit-test

{ f } [
    "resource:core/math/integers/integers.factor"
    [ drop f ] find-up-to-root
] unit-test
